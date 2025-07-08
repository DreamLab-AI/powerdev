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

# ---- tunables (edit if you change the Dockerfile flags) ---------------------
RUN_OPTS=(
  --gpus all
  --cpus "${DOCKER_CPUS:-24}"          # Allow overriding via env var
  --memory "${DOCKER_MEMORY:-200g}"    # Allow overriding via env var
  --security-opt no-new-privileges:true
  --pids-limit 4096
  # Removed --read-only and related tmpfs mounts for more permissive development environment
  -u dev
  --env-file "${ENVFILE}"
  -v "${EXTERNAL_DIR:-/mnt/nvme/swarm-docker-environment/swarm-docker}:/workspace/ext"
  -v "${HOME}/docker_data:/home/dev/data"
  -v "${HOME}/docker_workspace:/home/dev/workspace"
  -v "${HOME}/.ssh:/home/dev/.ssh:ro"
  -v "${SSH_AUTH_SOCK:-/tmp/ssh-agent.sock}:/tmp/ssh-agent.sock"
  -e SSH_AUTH_SOCK=/tmp/ssh-agent.sock
  --network docker_ragflow
  -v /var/run/docker.sock:/var/run/docker.sock # Mount Docker socket for DinD
  --privileged # Required for Docker-in-Docker
)

ensure_dockerfile() {
  if [[ ! -f "Dockerfile" ]]; then
    echo "Dockerfile not found. Creating it..."
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
    npm install -g ruv-swarm @anthropic-ai/claude-code @openai/codex @google/gemini-cli

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
RUN userdel -r ubuntu && \
    groupadd -g ${GID} dev && \
    useradd -m -s /bin/bash -u ${UID} -g ${GID} dev && \
    # Add dev user to the docker group
    usermod -aG docker dev && \
    # Fix ownership of npm global modules so dev user can write to them
    chown -R dev:dev /usr/lib/node_modules

USER dev
WORKDIR /workspace
COPY README.md .
COPY CLAUDE-README.md .

# Configure git for the dev user
RUN git config --global user.email "swarm@dreamlab-ai.com" && \
    git config --global user.name "Swarm Agent"

# Activate 3.12 venv by default
ENV PATH="/opt/venv312/bin:${PATH}"

# Runtime placeholders
ENV WASMEDGE_PLUGIN_PATH="/usr/local/lib/wasmedge"

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD ["sh", "-c", "command -v max >/dev/null"] || exit 1

CMD ["/bin/bash", "-c", "tmux new-session -d -s mcp 'ruv-swarm mcp start --protocol=stdio'; /bin/bash"]
DOCKERFILE_EOF
    echo "Dockerfile created successfully."
  fi
}

ensure_claude_md() {
  if [[ ! -f "CLAUDE-README.md" ]]; then
    echo "CLAUDE-README.md not found. Creating it..."
    cat > CLAUDE-README.md <<'CLAUDE_MD_EOF'
# CLAUDE-README.md – Project Boot Guide for Claude Code v4

## 1  Core Directives
1. **Production‑ready only.** Deliver runnable code; no TODOs or stubs.
2. **Token‑efficient reasoning.** Think silently; reveal only final answer unless asked.
3. **Edge‑case first.** Enumerate boundary conditions → write tests → implement.
4. **Context pull rules.** If repo is large, fetch only needed fragments with paths + line numbers.
5. **Tool usage.** Allowed:
   * `bash -c "<command>"`
   * `python - <<EOF … EOF` (v3.12 default)
   * `ruv‑swarm` MCP tools (see §3)
6. **No hedging / flattery / chit‑chat.**

## 2  Environment Snapshot
| Layer | Key Items |
|-------|-----------|
| **HW** | 24 CPU cores, 200 GB RAM, NVMe, NVIDIA GPUs, ZFS storage |
| **Python 3.12** | `torch` 2.8 + CUDA 12.9, `tensorflow`, `keras`, `xgboost`, `wgpu` |
| **Python 3.13** | Clean sandbox (`pip`, `setuptools`, `wheel`) |
| **CUDA/Drivers** | `/usr/local/cuda` visible, cuDNN installed |
| **Rust** | `rustup`, `clippy`, `cargo-edit`, `sccache` |
| **Node 18 LTS** | Global CLIs inc. `ruv-swarm`, `@anthropic-ai/claude-code` |
| **Linters** | `shellcheck`, `flake8`, `pylint`, `hadolint` |
| **Utilities** | `tmux`, `hyperfine` |
| **Containerization** | `docker`, `containerd` |
| **Wasm/AI Runtimes** | `WasmEdge`, `OpenVINO`, `Modular MAX` |
Path helpers:
```bash
source /opt/venv312/bin/activate   # default ML env
source /opt/venv313/bin/activate   # Python 3.13 sandbox


ruv mcp server is running in a tmux session. you can use and manage tmux sessions.

a useful ruv swarm command to start with is:
```bash
ruv-swarm init hierarchical 5 --cognitive-diversity --ml-models all
```
CLAUDE_MD_EOF
    echo "CLAUDE-README.md created successfully."
  fi
}

help() {
  cat <<EOF
Usage: $0 {build|start|exec|logs|health|stop|rm|restart|watch}

  build        Build the Docker image:
                 $0 build

  start        Run or start the container with hardened flags:
                 $0 start

  exec CMD     Run a command inside the running container:
                 $0 exec bash

  logs         Tail container logs:
                 $0 logs

  health       Show container health status:
                 $0 health

  stop         Stop the container:
                 $0 stop

  rm           Remove the container:
                 $0 rm

  restart      Restart the container:
                 $0 restart

  watch        Loop, checking health every 60s and restarting if unhealthy:
                 $0 watch
EOF
}

build() {
  ensure_dockerfile
  ensure_claude_md
  export DOCKER_BUILDKIT=1
  docker build \
    --progress=plain \
    --secret id=GH_TOKEN,env=GH_TOKEN \
    -t "$IMAGE" . "${@:2}"
}

start() {
  if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
    docker start -ai "$NAME"
  else
    docker run "${RUN_OPTS[@]}" --name "$NAME" -it "$IMAGE"
  fi
}

exec() {
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

watch() {
  echo "Watching health for ${NAME}…"
  while sleep 60; do
    status=$(health || echo "none")
    if [[ "$status" != "healthy" ]]; then
      echo "$(date)  –  container unhealthy ($status), restarting…"
      # Use docker restart here as well for consistency
      restart
    fi
  done
}

# Entry point
if [[ $# -eq 0 ]]; then
  help
  exit 1
fi

case $1 in
  build|start|exec|logs|health|stop|rm|restart|watch)
    "$@"
    ;;
  *)
    help
    ;;
esac