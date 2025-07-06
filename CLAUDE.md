# CLAUDE.md – Project Boot Guide for Claude Code v4

## 1  Core Directives
1. **Production‑ready only.** Deliver runnable code; no TODOs or stubs.
2. **Token‑efficient reasoning.** Think silently; reveal only final answer unless asked.
3. **Edge‑case first.** Enumerate boundary conditions → write tests → implement.
4. **Context pull rules.** If repo is large, fetch only needed fragments with paths + line numbers.
5. **Tool usage.** Allowed:
   * `bash -c "<command>"`
   * `python - <<EOF … EOF` (v3.12 default)
   * `ruv‑swarm` MCP tools (see §3)
6. **No hedging / flattery / chit‑chat.**

## 2  Environment Snapshot
| Layer | Key Items |
|-------|-----------|
| **HW** | 24 CPU cores, 200 GB RAM, NVMe, NVIDIA GPUs, ZFS storage |
| **Python 3.12** | `torch` 2.8 + CUDA 12.9, `tensorflow`, `keras`, `xgboost`, `wgpu` |
| **Python 3.13** | Clean sandbox (`pip`, `setuptools`, `wheel`) |
| **CUDA/Drivers** | `/usr/local/cuda` visible, cuDNN installed |
| **Rust** | `rustup`, `clippy`, `cargo-edit`, `sccache` |
| **Node 18 LTS** | Global CLIs inc. `ruv-swarm`, `@anthropic-ai/claude-code` |
| **Linters** | `shellcheck`, `flake8`, `pylint`, `hadolint` |
| **Utilities** | `tmux`, `hyperfine` |
| **Containerization** | `docker`, `containerd` |
| **Wasm/AI Runtimes** | `WasmEdge`, `OpenVINO`, `Modular MAX` |
Path helpers:
```bash
source /opt/venv312/bin/activate   # default ML env
source /opt/venv313/bin/activate   # Python 3.13 sandbox


ruv mcp server is running in a tmux session. you can use and manage tmux sessions.

a useful ruv swarm command to start with is:
```bash
ruv-swarm init hierarchical 5 --cognitive-diversity --ml-models all
```
