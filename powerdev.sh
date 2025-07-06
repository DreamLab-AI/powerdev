#!/usr/bin/env bash
# powerdev.sh  –  helper for the GPU- & Wasm-powered “powerdev” container
set -euo pipefail

IMAGE=powerdev:latest
NAME=swarm_container
ENVFILE=.env     # ← update to match your actual env file

# Source the .env file to make variables available to the script
if [[ -f "${ENVFILE}" ]]; then
  source "${ENVFILE}"
fi

# ---- Resource detection and validation ---------------------
detect_resources() {
  AVAILABLE_CPUS=$(nproc)
  AVAILABLE_MEM=$(free -g | awk '/^Mem:/{print $2}')

  # Set sensible defaults based on available resources
  DEFAULT_CPUS=$((AVAILABLE_CPUS > 24 ? 24 : AVAILABLE_CPUS))
  DEFAULT_MEM=$((AVAILABLE_MEM > 200 ? 200 : AVAILABLE_MEM > 10 ? AVAILABLE_MEM-10 : 4))

  # Apply user overrides or use calculated defaults
  DOCKER_CPUS=${DOCKER_CPUS:-$DEFAULT_CPUS}
  DOCKER_MEMORY=${DOCKER_MEMORY:-${DEFAULT_MEM}g}

  # Validate resources don't exceed available
  if [[ $DOCKER_CPUS -gt $AVAILABLE_CPUS ]]; then
    echo "Warning: Requested CPUs ($DOCKER_CPUS) exceeds available ($AVAILABLE_CPUS)"
    DOCKER_CPUS=$AVAILABLE_CPUS
  fi
}

# ---- Runtime options setup (called after resource detection) ---------------------
setup_run_opts() {
  RUN_OPTS=(
    --gpus all
    --cpus "${DOCKER_CPUS}"
    --memory "${DOCKER_MEMORY}"
    --security-opt no-new-privileges:true
    --pids-limit 4096
    # Removed --read-only and related tmpfs mounts for more permissive development environment
    -u dev
    --env-file "${ENVFILE}"
    -v "${EXTERNAL_DIR:-/mnt/nvme/swarm-docker-environment/swarm-docker}:/workspace/ext"
    -v "${HOME}/docker_data:/home/dev/data"
    -v "${HOME}/docker_workspace:/home/dev/workspace"
    -v "${HOME}/docker_analysis:/home/dev/analysis"
    -v "${HOME}/docker_logs:/home/dev/logs"
    -v "${HOME}/docker_output:/home/dev/output"
    -v "${HOME}/.ssh:/home/dev/.ssh:ro"
    -v "${SSH_AUTH_SOCK:-/tmp/ssh-agent.sock}:/tmp/ssh-agent.sock"
    -e SSH_AUTH_SOCK=/tmp/ssh-agent.sock
    --network docker_ragflow
    -v /var/run/docker.sock:/var/run/docker.sock # Mount Docker socket for DinD
    --privileged # Required for Docker-in-Docker
    -p 3010:3010 # Expose Claude Flow web interface
  )
}

# ---- Pre-flight checks ---------------------
preflight() {
  # Check Docker daemon
  if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon not accessible"
    exit 1
  fi

  # Check NVIDIA Docker runtime
  if ! docker run --rm --gpus all nvidia/cuda:12.9.0-base-ubuntu24.04 nvidia-smi >/dev/null 2>&1; then
    echo "Warning: NVIDIA Docker runtime not available or no GPU detected"
  fi

  # Ensure required directories exist
  mkdir -p "${HOME}/docker_data" "${HOME}/docker_workspace"
  mkdir -p "${HOME}/docker_analysis" "${HOME}/docker_logs" "${HOME}/docker_output"

  echo "Created persistent directories:"
  echo "  - ${HOME}/docker_data (general data)"
  echo "  - ${HOME}/docker_workspace (workspace files)"
  echo "  - ${HOME}/docker_analysis (analysis outputs)"
  echo "  - ${HOME}/docker_logs (container logs)"
  echo "  - ${HOME}/docker_output (processing outputs)"

  # Create network if it doesn't exist
  if ! docker network inspect docker_ragflow >/dev/null 2>&1; then
    echo "Creating docker_ragflow network..."
    docker network create docker_ragflow
  fi

  # Validate config
  validate_config
}

# ---- Config validation ---------------------
validate_config() {
  if [[ ! -f "$ENVFILE" ]]; then
    echo "Warning: $ENVFILE not found - using environment variables only"
  fi

  if [[ -z "$EXTERNAL_DIR" ]]; then
    echo "Warning: EXTERNAL_DIR not set - using default path"
  fi
}

ensure_dockerfile() {
  # Always remove the old Dockerfile to ensure it's up-to-date
  rm -f Dockerfile
  echo "Creating/updating Dockerfile..."
  cat > Dockerfile <<'DOCKERFILE_EOF'
################################################################################
# Stage 0 – CUDA 12.9 + cuDNN (official NVIDIA image)
################################################################################
FROM nvidia/cuda:12.9.0-cudnn-devel-ubuntu24.04 AS base

################################################################################
# Stage 1 – OS deps, Python 3.12 & 3.13 venvs, Rust, Node, ML stack, WasmEdge
################################################################################
ARG DEBIAN_FRONTEND=noninteractive

# ---------- Core build tools, Linters, Python, Node, Wasm deps ----------
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    # Install Docker dependencies
    apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    # Core build tools, Linters, Python, Node, Wasm deps, and Docker
    apt-get install -y --no-install-recommends \
      build-essential clang curl git pkg-config ca-certificates gnupg libssl-dev \
      wget software-properties-common lsb-release shellcheck hyperfine openssh-client tmux \
      docker-ce docker-ce-cli containerd.io && \
    # Add Deadsnakes PPA for newer Python versions
    add-apt-repository -y ppa:deadsnakes/ppa && \
    # Add NodeSource repository for up-to-date NodeJS (v22+)
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    # Install Python, Node, and GPU/Wasm dependencies
    apt-get install -y --no-install-recommends \
      python3.12 python3.12-venv python3.12-dev \
      python3.13 python3.13-venv python3.13-dev \
      nodejs \
      libvulkan1 vulkan-tools ocl-icd-libopencl1 && \
    # Linters
    wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 && \
    chmod +x /usr/local/bin/hadolint && \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

# ---------- Create Python virtual environments & install global node packages ----------
RUN python3.12 -m venv /opt/venv312 && \
    /opt/venv312/bin/pip install --upgrade pip wheel setuptools && \
    python3.13 -m venv /opt/venv313 && \
    /opt/venv313/bin/pip install --upgrade pip wheel setuptools && \
    # Install all global CLI tools here
    npm install -g claude-flow@2.0.0 ruv-swarm

# ---------- Install Python ML & AI libraries into the 3.12 venv ----------
# Install in logical, separate groups to prevent "dependency hell" and resolver timeouts.
# STEP 1: Install wgpu separately and pin its version.
RUN /opt/venv312/bin/pip install --no-cache-dir wgpu==0.22.2

# STEP 2: Install the core, heavy ML frameworks.
RUN /opt/venv312/bin/pip install --no-cache-dir \
    tensorflow \
    torch torchvision torchaudio \
    keras

# STEP 3: Install other common data science libraries.
RUN /opt/venv312/bin/pip install --no-cache-dir \
    h2o xgboost

# STEP 4: Install linters.
RUN /opt/venv312/bin/pip install --no-cache-dir \
    flake8 pylint

# STEP 5: Install the Modular MAX runtime last. As a pre-release, it's best
# installed on its own to avoid influencing the resolution of stable packages.
RUN /opt/venv312/bin/pip install --no-cache-dir --pre modular

# ---------- Rust tool-chain (AVX‑512) ----------
ENV PATH="/root/.cargo/bin:${PATH}"
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile default && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> /etc/profile.d/rust.sh && \
    cargo install cargo-edit
ENV RUSTFLAGS="-C target-cpu=skylake-avx512 -C target-feature=+avx2,+avx512f,+avx512bw,+avx512dq"

# ---------- GPU‑accelerated Wasm stack (WasmEdge) ----------
RUN curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | \
    bash -s -- -p /usr/local --plugins wasi_nn-openvino && ldconfig

# ---------- OpenVINO from official APT repository ----------
RUN wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
    gpg --dearmor --output /etc/apt/trusted.gpg.d/intel.gpg && \
    echo "deb https://apt.repos.intel.com/openvino ubuntu24 main" > /etc/apt/sources.list.d/intel-openvino.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openvino-2025.2.0 && \
    rm -rf /var/lib/apt/lists/*

################################################################################
# Stage 2 – Non‑root user, health‑check, env placeholders
################################################################################
ARG UID=1000
ARG GID=1000
# Remove the existing ubuntu user and replace it with the dev user
# This ensures there's no UID conflict and the dev user is properly used
RUN (id ubuntu &>/dev/null && userdel -r ubuntu) || true && \
    groupadd -g ${GID} dev && \
    useradd -m -s /bin/bash -u ${UID} -g ${GID} dev && \
    # Add dev user to the docker group
    usermod -aG docker dev && \
    # Fix ownership of npm global modules so dev user can write to them
    chown -R dev:dev /usr/lib/node_modules && \
    # Create python symlink for convenience
    ln -s /usr/bin/python3.12 /usr/local/bin/python

USER dev
WORKDIR /workspace
COPY README.md .
COPY CLAUDE.md .

# Configure git for the dev user
RUN git config --global user.email "swarm@dreamlab-ai.com" && \
    git config --global user.name "Swarm Agent"

# Activate 3.12 venv by default
ENV PATH="/opt/venv312/bin:${PATH}"

# Runtime placeholders
ENV WASMEDGE_PLUGIN_PATH="/usr/local/lib/wasmedge"

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD ["sh", "-c", "command -v max >/dev/null"] || exit 1

CMD ["/bin/bash", "-c", "tmux new-session -d -s mcp 'ruv-swarm mcp start --protocol=stdio' && tmux new-session -d -s claude-flow 'npx claude-flow@2.0.0 start --ui --port 3010' && /bin/bash"]
DOCKERFILE_EOF
    echo "Dockerfile created successfully."
}

ensure_claude_md() {
  if [[ ! -f "CLAUDE.md" ]]; then
    echo "CLAUDE.md not found. Creating it..."
    cat > CLAUDE.md <<'CLAUDE_MD_EOF'
# CLAUDE.md — Boot Guide (Claude Code v4 + Claude Flow v2.0.0)

## 1. CORE DIRECTIVES
1. **Prod-ready only** – ship runnable code; no TODOs or stubs.
2. **Token-efficient reasoning** – think silently; output final answer unless asked.
3. **Edge-case first** – list boundaries → write tests → implement.
4. **Selective context pull** – fetch only needed paths + line nums in large repos.
5. **Allowed tools:**
   - `bash -c "<cmd>"`
   - `python - <<EOF … EOF` (Py 3.12 default)
   - `ruv-swarm` MCP (placeholder implementation)
   - `claude-flow` MCP (placeholder implementation)
6. **No hedging / flattery / chit-chat.**

## 2. ENVIRONMENT SNAPSHOT

| Layer | Key Items |
|-------|-----------|
| **HW** | Auto-detected CPU/RAM / NVMe / NVIDIA GPUs |
| **Python 3.12** | `torch` 2.8 + CUDA 12.9, `tensorflow`, `keras`, `xgboost`, `wgpu` |
| **Python 3.13** | Clean sandbox (`pip`, `setuptools`, `wheel`) |
| **CUDA + cuDNN** | `/usr/local/cuda` ready |
| **Rust** | `rustup`, `clippy`, `cargo-edit`, `sccache` |
| **Node 22 LTS** | CLIs: `ruv-swarm`, `claude-flow` |
| **Linters** | `shellcheck`, `flake8`, `pylint`, `hadolint` |
| **Extras** | `tmux`, `hyperfine`, `docker`, `WasmEdge`, `OpenVINO`, `Modular MAX` |
| **Web UI** | Claude-Flow UI → http://localhost:3010 |

### Quick env switches:
```bash
source /opt/venv312/bin/activate   # ML env
source /opt/venv313/bin/activate   # Py 3.13 sandbox
```

## 3. PRIMARY TOOLS & SYNTAX

### 3.1 ruv-swarm MCP (excerpt)
```javascript
mcp__ruv-swarm__swarm_init       { topology:"hierarchical", maxAgents:5, enableNeural:true }
mcp__ruv-swarm__agent_spawn      { type:"coder", model:"tcn-detector", pattern:"convergent" }
mcp__ruv-swarm__task_orchestrate { task:"Build REST API", strategy:"adaptive" }
```
Full list: see `docs/ruv-swarm-cheatsheet.md`.

### 3.2 Claude-Flow MCP (excerpt)
```javascript
mcp__claude-flow__swarm_init        { topology:"mesh", maxAgents:8, queen:"strategic" }
mcp__claude-flow__hive_mind         { objective:"Enterprise microservices" }
mcp__claude-flow__neural_train      { mode:"online", shareKnowledge:true }
mcp__claude-flow__performance_report { timeframe:"24h", format:"detailed" }
```
Web UI at port 3010 mirrors these calls.

### 3.3 Slash-Commands (Claude Code)
`/config` `/status` `/review` `/mcp` `/doctor` `/cost` `/init` `/hive-mind` `/neural` ...

## 4. STRUCTURED OUTPUT CONTRACT
Return one of:
- **diff** – patch for `git apply`
- **bash** – shell commands
- **text** – plain explanation

Always end with **✅ Done** so orchestrator can detect completion.

## 5. CODING & STYLE STANDARDS
- **Language picks:** Py 3.12 for ML; Rust for perf; Node 22 for CLIs.
- **Tests:** `pytest -q`, `cargo test`, edge cases mandatory.
- **Formatters:** `black`, `ruff`, `rustfmt`, `prettier`.
- **Docs:** Public APIs need docstrings + one example.
- **Forbidden:** long apologies, empty sections, unexplained "maybe".

## 6. COMMON WORKFLOWS

| Goal | One-liner |
|------|-----------|
| Full Claude-Flow init | `npx claude-flow@2 init --webui` |
| Spawn 8-agent hive mind | `npx claude-flow@2 hive-mind spawn "Build microservices"` |
| Start ruv-swarm MCP srv | `ruv-swarm mcp start` |
| GPU benchmark | `hyperfine --warmup 3 'python bench.py'` |
| Attach Claude-Flow tmux | `tmux attach -t claude-flow` |

## 7. TMUX SESSION HINTS
- **List sessions:** `tmux ls`
- **Attach:** `tmux attach -t <name>`
- **New window:** `tmux new-window -t <name>`
- **Cheat sheet:** https://tmuxcheatsheet.com/

## 8. UPDATE RULES
- Keep file ≤ 350 lines; prune every quarter.
- Update Environment Snapshot on image changes.
- Append new MCP tools under §3 when Flow/Swarm versions bump.

---

### Next steps
1. Commit this *CLAUDE.md* to your repo root.
2. Link deeper docs (e.g., `docs/flow/` and `docs/ruv-swarm/`) so Claude can open them on demand.
3. Review quarterly to ensure environment versions and tool counts stay current.

CLAUDE_MD_EOF
    echo "CLAUDE.md created successfully."
  fi
}

help() {
  cat <<EOF
Usage: $0 {build|start|daemon|exec|logs|health|stop|rm|restart|watch|status|cleanup|persist}

  build        Build the Docker image:
                 $0 build

  start        Run or start the container with hardened flags (interactive):
                 $0 start

  daemon       Run the container in background mode (detached):
                 $0 daemon

  exec CMD     Run a command inside the running container:
                 $0 exec bash

  logs         Tail container logs:
                 $0 logs

  health       Show container health status:
                 $0 health

  status       Show detailed container status:
                 $0 status

  stop         Stop the container:
                 $0 stop

  rm           Remove the container:
                 $0 rm

  restart      Restart the container:
                 $0 restart

  watch        Loop, checking health every 60s and restarting if unhealthy:
                 $0 watch

  cleanup      Clean up Docker resources (system and volume prune):
                 $0 cleanup

  persist      Save analysis outputs to persistent storage:
                 $0 persist

Data Persistence:
  - Analysis outputs: ~/docker_analysis/
  - Container logs: ~/docker_logs/
  - Processing outputs: ~/docker_output/
  - Workspace files: ~/docker_workspace/
  - General data: ~/docker_data/
EOF
}

build() {
  preflight
  detect_resources
  ensure_dockerfile
  ensure_claude_md

  # Validate Dockerfile if hadolint is available
  if command -v hadolint >/dev/null 2>&1; then
    echo "Linting Dockerfile..."
    hadolint Dockerfile || echo "Warning: Dockerfile linting failed"
  fi

  export DOCKER_BUILDKIT=1
  docker build \
    --progress=plain \
    --secret id=GH_TOKEN,env=GH_TOKEN \
    -t "$IMAGE" . "${@:2}"
}

start() {
  detect_resources
  setup_run_opts

  if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
    docker start -ai "$NAME"
  else
    docker run "${RUN_OPTS[@]}" --name "$NAME" -it "$IMAGE"
  fi
}

daemon() {
  detect_resources
  setup_run_opts

  if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
    echo "Starting existing container in background..."
    docker start "$NAME"
  else
    echo "Creating new container in background..."
    docker run "${RUN_OPTS[@]}" --name "$NAME" -d "$IMAGE"
  fi

  echo "Container '$NAME' running in background"
  echo "Access with: $0 exec bash"
  echo "View logs with: $0 logs"
  echo "Web UI available at: http://localhost:3010"
}

persist() {
  if ! docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
    echo "Error: Container '$NAME' is not running"
    return 1
  fi

  echo "Saving analysis outputs to persistent storage..."

  # Create timestamped backup directory
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BACKUP_DIR="${HOME}/docker_analysis/backup_${TIMESTAMP}"
  mkdir -p "$BACKUP_DIR"

  # Copy container analysis data
  docker cp "$NAME:/home/dev/analysis/." "$BACKUP_DIR/" 2>/dev/null || echo "No analysis data found"
  docker cp "$NAME:/home/dev/output/." "${HOME}/docker_output/" 2>/dev/null || echo "No output data found"

  # Export container logs
  docker logs "$NAME" > "${HOME}/docker_logs/container_${TIMESTAMP}.log"

  # Export container state
  docker inspect "$NAME" > "${BACKUP_DIR}/container_state.json"

  echo "Data saved to:"
  echo "  - Analysis: $BACKUP_DIR/"
  echo "  - Outputs: ${HOME}/docker_output/"
  echo "  - Logs: ${HOME}/docker_logs/container_${TIMESTAMP}.log"
  echo "  - State: $BACKUP_DIR/container_state.json"
}

exec() {
  if ! docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
    echo "Error: Container '$NAME' is not running"
    return 1
  fi
  docker exec -it -u dev "$NAME" "${@:2}"
}

logs() {
  docker logs -f "$NAME"
}

health() {
  docker inspect --format='{{.State.Health.Status}}' "$NAME"
}

stop() {
  docker stop "$NAME"
}

rm() {
  docker rm "$NAME"
}

restart() {
  # Use docker restart for idempotency. It works if the container is running or stopped.
  docker restart "$NAME"
}

status() {
  if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
    echo "Container Status:"
    docker ps -a --filter "name=^${NAME}$" --format "table {{.Names}}\t{{.Status}}\t{{.State}}"
    echo -e "\nHealth: $(health || echo 'N/A')"
    echo "Ports: $(docker port "$NAME" 2>/dev/null || echo 'None')"
    echo "Image: $(docker inspect --format='{{.Config.Image}}' "$NAME" 2>/dev/null || echo 'N/A')"
    echo "Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" "$NAME" 2>/dev/null || echo "  Stats not available"
  else
    echo "Container '$NAME' does not exist"
  fi
}

cleanup() {
  echo "Cleaning up Docker resources..."
  docker system prune -f
  docker volume prune -f
  echo "Cleanup complete"
}

watch() {
  echo "Watching health for ${NAME}…"
  while sleep 60; do
    if ! docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
      echo "$(date) - Container not found, exiting watch"
      break
    fi
    status_check=$(health || echo "none")
    if [[ "$status_check" != "healthy" ]]; then
      echo "$(date) - Container unhealthy ($status_check), restarting…"
      restart
      sleep 10  # Give container time to start
    fi
  done
}

# ---- Shell completion ---------------------
_powerdev_completion() {
  COMPREPLY=($(compgen -W "build start daemon exec logs health status stop rm restart watch cleanup persist" -- "${COMP_WORDS[COMP_CWORD]}"))
}
complete -F _powerdev_completion powerdev.sh

# ---- Graceful shutdown handler ---------------------
trap 'echo "Shutting down..."; stop 2>/dev/null; exit' SIGINT SIGTERM

# Entry point
if [[ $# -eq 0 ]]; then
  help
  exit 1
fi

case $1 in
  build|start|daemon|exec|logs|health|status|stop|rm|restart|watch|cleanup|persist)
    "$@"
    ;;
  *)
    help
    ;;
esac