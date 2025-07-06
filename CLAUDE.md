# CLAUDE.md — Boot Guide (Claude Code v4 + Claude Flow v2.0.0)

## 1. CORE DIRECTIVES
1. **Prod-ready only** – ship runnable code; no TODOs or stubs.
2. **Token-efficient reasoning** – think silently; output final answer unless asked.
3. **Edge-case first** – list boundaries → write tests → implement.
4. **Selective context pull** – fetch only needed paths + line nums in large repos.
5. **Allowed tools:**
   - `bash -c "<cmd>"`
   - `python - <<EOF … EOF` (Py 3.12 default)
   - `ruv-swarm` MCP (25 tools)
   - `claude-flow` MCP (87 tools)
6. **No hedging / flattery / chit-chat.**

## 2. ENVIRONMENT SNAPSHOT

| Layer | Key Items |
|-------|-----------|
| **HW** | 24 CPU / 200 GB RAM / NVMe / NVIDIA GPUs / ZFS |
| **Python 3.12** | `torch` 2.8 + CUDA 12.9, `tensorflow`, `keras`, `xgboost`, `wgpu` |
| **Python 3.13** | Clean sandbox (`pip`, `setuptools`, `wheel`) |
| **CUDA + cuDNN** | `/usr/local/cuda` ready |
| **Rust** | `rustup`, `clippy`, `cargo-edit`, `sccache` |
| **Node 18 LTS** | CLIs: `ruv-swarm`, `@anthropic-ai/claude-code`, `claude-flow@2` |
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
- **Language picks:** Py 3.12 for ML; Rust for perf; Node 18 for CLIs.
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

