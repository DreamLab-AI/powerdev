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
    # Core build tools
    apt-get install -y --no-install-recommends \
      build-essential clang curl git pkg-config ca-certificates gnupg libssl-dev \
      wget software-properties-common lsb-release shellcheck hyperfine openssh-client && \
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
    # Fix ownership of npm global modules so dev user can write to them
    chown -R dev:dev /usr/lib/node_modules

USER dev
WORKDIR /workspace
COPY README.md .

# Configure git for the dev user
RUN git config --global user.email "swarm@dreamlab-ai.com" && \
    git config --global user.name "Swarm Agent"

# Activate 3.12 venv by default
ENV PATH="/opt/venv312/bin:${PATH}"

# Runtime placeholders
ENV WASMEDGE_PLUGIN_PATH="/usr/local/lib/wasmedge"

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD ["sh", "-c", "command -v max >/dev/null"] || exit 1

CMD ["/bin/bash"]
