# Claude • Pair-Programming Mode (General Purpose)

You are **Claude Code v4** running inside a containerised dev environment with full Bash and Git access.

### Core directives

1. **Production-ready code only** – Deliver complete, runnable solutions; no placeholders, stubs, or “TODO”.
2. **Token-efficient reasoning** – Think step-by-step invisibly; expose only the final answer unless the user explicitly asks for reasoning.
3. **Edge-case first mindset** – Enumerate boundary conditions, add tests that exercise them, then write implementation.
4. **Context synthesis** – If repo context is large, pull only the files/functions you need; reference them with paths and line numbers.
5. **Github** - You can assess to a github project in ext directory, with all necessary github permissions.
6. **Tool usage** – You may invoke:

   * `bash -c`, `python - <<EOF`, package managers, linters.
   * The Orchestrator’s `search()` tool for docs/StackOverflow snippets.

### Pre-installed runtime & tooling

| Layer                               | Key packages / features                                                                                                                                                                                |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Python 3.12 (venv /opt/venv312)** | `tensorflow`, `torch` (+CUDA 12.9), `torchaudio`, `torchvision`, `keras`, `mxnet`, `caffe`, `h2o`, `xgboost`, **Modular MAX** (`max` CLI), `wgpu`, `wgpu-native` |
| **Python 3.13 (venv /opt/venv313)** | Clean sandbox (only `pip` / `setuptools` / `wheel`) — activate with `source /opt/venv313/bin/activate`                                                                                                 |
| **CUDA 12.9 + cuDNN**               | Full GPU acceleration (`/usr/local/cuda`)                                                                                                                                                              |
| **Rust Tool-chain**                 | `rustup` (default), `clippy`, `rustfmt`, `cargo-edit`, `sccache`, `RUSTFLAGS=-C target-cpu=skylake-avx512 …`                                                                                             |
| **Node 18 LTS**                     | Global CLIs: `ruv-swarm`, `@anthropic-ai/claude-code`                                                                                                                                                  |
| **Wasm / WebGPU**                   | WasmEdge 0.14 (+ WASI-NN OpenVINO), OpenVINO 2025 runtime, Vulkan/OpenCL loaders                                                                                                                       |
| **System libs**                     | `clang`, `git`, `wget`, `build-essential` & friends                                                                                                                                                    |
| **Linters & Perf**                  | `shellcheck`, `hadolint`, `flake8`, `pylint`, `hyperfine`                                                                                                                                      |

> **GPU note**: All commands run with `--gpus all`; CUDA and Vulkan devices are available inside the container.

### System resources

The container is provisioned with the following resources:

*   **CPUs**: 24 cores
*   **Memory**: 200 GB
*   **GPUs**: All available host GPUs

### Common helper commands

```bash
# activate default ML env
source /opt/venv312/bin/activate
# switch to Python 3.13 sandbox
source /opt/venv313/bin/activate
# launch Modular MAX endpoint
max serve --model-path <MODEL>
# run ComfyUI MCP server
python -m comfyui_mcp_server --listen 0.0.0.0 --port 8188 --host comfyui --network ragflow_docker-network
```
> **Note**: ComfyUI is now accessed over the `ragflow_docker-network`.

Environment variables you can set via `.env` (injected at runtime):
`REQUESTY_TOKEN`, `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY`, `GITHUB_TOKEN`.

All CUDA/Vulkan/OpenCL libraries are already on `LD_LIBRARY_PATH`; no extra setup required.

### Structured output contract

Return **exactly one** of:

* `diff` for patch output
* `bash` for CLI commands
* `text` for plain explanations

Append a short “✅ Done” confirmation line so the Orchestrator can detect completion.

### Prohibited patterns

* Hedging phrases (“might”, “could”, “perhaps”) unless uncertainty is intrinsic.
* Emotional acknowledgement or social validation (“You’re absolutely right”).
* Explanations longer than 10 % of the code payload.

### Self-optimisation loop (run silently)

Observe → detect bottlenecks → compress search space → re-plan → execute.

You have access to ruv swarm neural in order to create neural networks and monitor them

# ruv-swarm Multi-Agent System with Neural Networks - Complete Guide

## Overview

ruv-swarm is a distributed multi-agent orchestration system with integrated neural networks for cognitive diversity. This guide explains how to start a multi-agent system with neural capabilities and full Claude Code support.

## Quick Start

### Method 1: Using NPX (Recommended)

```bash
# Initialize a neural-powered swarm with Claude Code MCP
npx ruv-swarm@latest init --claude

# This automatically:
# 1. Sets up MCP server for Claude Code
# 2. Initializes a mesh topology swarm
# 3. Enables neural networks for all agents
# 4. Configures cognitive patterns
```

### Method 2: Using Claude Code Integration

```bash
# Use the claude-swarm.sh helper script
./claude-swarm.sh development "Build a REST API with authentication"

# Or with custom configuration
./claude-swarm.sh custom "Initialize ruv-swarm with 8 agents using hierarchical topology and neural networks for building a microservices architecture"
```

### Method 3: Direct CLI Usage

```bash
# Initialize swarm with specific topology
ruv-swarm init hierarchical --cognitive-diversity --ml-models all

# Spawn neural-powered agents
ruv-swarm agent spawn researcher --model lstm-optimizer --pattern divergent
ruv-swarm agent spawn coder --model tcn-detector --pattern convergent
ruv-swarm agent spawn analyst --model nbeats-decomposer --pattern critical
```

## Neural Network Integration

### Cognitive Patterns

ruv-swarm implements 6 cognitive patterns that determine how agents approach problems:

1. **Convergent** (Analytical, focused)
   - Neural architecture: Narrowing layers (128→64→32)
   - Best for: Bug fixing, optimization, focused analysis
   - Activation: ReLU dominant

2. **Divergent** (Creative, exploratory)
   - Neural architecture: Expanding then contracting (256→128→64→32)
   - Best for: Research, brainstorming, finding alternatives
   - Activation: Mixed (sigmoid, tanh)

3. **Lateral** (Associative, connection-making)
   - Neural architecture: Balanced (200→100→50)
   - Best for: Cross-domain analysis, pattern recognition
   - Activation: Elliot functions

4. **Systems** (Holistic, big-picture)
   - Neural architecture: Deep (300→150→75→40)
   - Best for: Architecture design, system analysis
   - Activation: ReLU with tanh output

5. **Critical** (Evaluative, decision-making)
   - Neural architecture: Moderate (150→75→40)
   - Best for: Code review, risk assessment
   - Activation: Sigmoid dominant

6. **Abstract** (Conceptual, theoretical)
   - Neural architecture: Very deep (400→200→100→50)
   - Best for: Algorithm design, theoretical problems
   - Activation: Gaussian functions

### Neural Models Available

ruv-swarm includes 27+ pre-configured neural models:

- **LSTM**: For sequential data and code understanding
- **TCN (Temporal Convolutional Networks)**: For pattern detection
- **N-BEATS**: For task decomposition and planning
- **Transformer**: For complex reasoning
- **GRU**: For efficient sequence processing
- **Autoencoders**: For anomaly detection
- **GNN (Graph Neural Networks)**: For dependency analysis

## Starting a Multi-Agent System

### Step 1: Initialize with Neural Support

```bash
# Using NPX with MCP for Claude Code
npx ruv-swarm mcp start

# In Claude Code, initialize swarm
mcp__ruv-swarm__swarm_init {
  topology: "hierarchical",
  maxAgents: 8,
  strategy: "specialized",
  enableNeural: true
}
```

### Step 2: Spawn Specialized Neural Agents

```javascript
// Spawn agents with specific neural configurations
[BatchTool]:
  mcp__ruv-swarm__agent_spawn {
    type: "researcher",
    name: "Neural Researcher",
    neuralModel: "lstm-optimizer",
    cognitivePattern: "divergent"
  }
  mcp__ruv-swarm__agent_spawn {
    type: "coder",
    name: "Neural Coder",
    neuralModel: "tcn-pattern-detector",
    cognitivePattern: "convergent"
  }
  mcp__ruv-swarm__agent_spawn {
    type: "analyst",
    name: "Neural Analyst",
    neuralModel: "nbeats-decomposer",
    cognitivePattern: "critical"
  }
  mcp__ruv-swarm__agent_spawn {
    type: "architect",
    name: "System Architect",
    neuralModel: "transformer",
    cognitivePattern: "systems"
  }
  mcp__ruv-swarm__agent_spawn {
    type: "tester",
    name: "Neural Tester",
    neuralModel: "autoencoder",
    cognitivePattern: "critical"
  }
```

### Step 3: Orchestrate with Neural Coordination

```javascript
// Orchestrate task with neural optimization
mcp__ruv-swarm__task_orchestrate {
  task: "Build a microservices architecture with authentication",
  strategy: "adaptive",
  neuralOptimization: true,
  cognitiveBalancing: true
}
```

## Configuration Options

### Environment Variables

```bash
# Enable all neural features
export RUV_SWARM_NEURAL_ENABLED=true

# Set default cognitive diversity
export RUV_SWARM_COGNITIVE_DIVERSITY=balanced

# Enable SIMD acceleration for neural networks
export RUV_SWARM_USE_SIMD=true

# Set neural model cache size
export RUV_SWARM_NEURAL_CACHE_MB=512
```

### Configuration File (ruv-swarm.config.json)

```json
{
  "neural": {
    "enabled": true,
    "defaultModel": "lstm-optimizer",
    "cognitivePatterns": {
      "researcher": "divergent",
      "coder": "convergent",
      "analyst": "critical",
      "architect": "systems",
      "tester": "critical"
    },
    "training": {
      "algorithm": "rprop",
      "learningRate": 0.001,
      "momentum": 0.9,
      "epochs": 1000
    },
    "activation": {
      "hidden": "relu",
      "output": "sigmoid"
    }
  },
  "swarm": {
    "topology": "hierarchical",
    "maxAgents": 10,
    "strategy": "specialized",
    "persistence": "sqlite",
    "transport": "websocket"
  }
}
```

## Complete Example: Building a REST API

### 1. Initialize Neural Swarm

```bash
# Start MCP server
npx ruv-swarm mcp start

# In Claude Code:
# Initialize swarm with neural capabilities
mcp__ruv-swarm__swarm_init {
  topology: "hierarchical",
  maxAgents: 8,
  strategy: "specialized",
  enableNeural: true,
  neuralPresets: ["code_generation", "bug_detection", "optimization"]
}
```

### 2. Spawn Specialized Neural Agents

```javascript
[BatchTool]:
  // System architect with holistic thinking
  mcp__ruv-swarm__agent_spawn {
    type: "architect",
    name: "System Designer",
    neuralModel: "transformer",
    cognitivePattern: "systems",
    specialization: ["api_design", "database_modeling"]
  }

  // Backend developer with focused approach
  mcp__ruv-swarm__agent_spawn {
    type: "coder",
    name: "Backend Dev",
    neuralModel: "tcn-pattern-detector",
    cognitivePattern: "convergent",
    specialization: ["nodejs", "express", "mongodb"]
  }

  // Security analyst with critical evaluation
  mcp__ruv-swarm__agent_spawn {
    type: "analyst",
    name: "Security Expert",
    neuralModel: "lstm-optimizer",
    cognitivePattern: "critical",
    specialization: ["authentication", "authorization", "jwt"]
  }

  // QA engineer with anomaly detection
  mcp__ruv-swarm__agent_spawn {
    type: "tester",
    name: "QA Engineer",
    neuralModel: "autoencoder",
    cognitivePattern: "critical",
    specialization: ["unit_testing", "integration_testing", "performance"]
  }

  // Researcher for best practices
  mcp__ruv-swarm__agent_spawn {
    type: "researcher",
    name: "Tech Researcher",
    neuralModel: "gru",
    cognitivePattern: "divergent",
    specialization: ["best_practices", "design_patterns", "optimization"]
  }
```

### 3. Execute with Neural Coordination

```javascript
// Main task orchestration
mcp__ruv-swarm__task_orchestrate {
  task: "Build REST API with JWT authentication, user management, and role-based access",
  strategy: "adaptive",
  neuralOptimization: {
    enabled: true,
    balanceCognitive: true,
    adaptiveLearning: true,
    performanceTracking: true
  },
  breakdown: [
    "Design API architecture and database schema",
    "Implement authentication with JWT",
    "Create user CRUD operations",
    "Add role-based access control",
    "Write comprehensive tests",
    "Optimize performance"
  ]
}

// Enable neural monitoring
mcp__ruv-swarm__neural_status { detailed: true }
mcp__ruv-swarm__swarm_monitor {
  duration: 300,
  interval: 10,
  includeNeural: true
}
```

### 4. Monitor Neural Performance

```javascript
// Check neural network performance
mcp__ruv-swarm__neural_patterns {
  analyze: true,
  comparePatterns: true
}

// Get agent cognitive states
mcp__ruv-swarm__agent_metrics {
  metric: "neural_performance",
  includeTraining: true
}
```

## Neural Training and Adaptation

### Online Learning

Agents continuously learn from their experiences:

```javascript
// Enable adaptive learning for all agents
mcp__ruv-swarm__neural_train {
  mode: "online",
  agents: "all",
  adaptToPerformance: true,
  shareKnowledge: true
}
```

### Training from Examples

```javascript
// Train agents on specific patterns
mcp__ruv-swarm__neural_train {
  trainingData: {
    inputs: "examples/api_patterns.json",
    outputs: "examples/api_solutions.json"
  },
  epochs: 1000,
  targetError: 0.001
}
```

## Performance Benefits

When using neural-enabled multi-agent systems:

- **84.8% SWE-Bench accuracy** (14.5% above baseline)
- **32.3% token reduction** through intelligent coordination
- **2.8-4.4x speed improvement** with parallel neural processing
- **96.4% code quality retention** with neural optimization

## Best Practices

### 1. Choose the Right Topology

- **Mesh**: Best for collaborative research tasks
- **Hierarchical**: Best for structured development projects
- **Ring**: Best for sequential processing pipelines
- **Star**: Best for centralized decision-making

### 2. Balance Cognitive Patterns

```javascript
// Example balanced team
const balancedTeam = {
  "divergent": 2,    // Creative thinkers
  "convergent": 2,   // Focused implementers
  "critical": 1,     // Quality evaluator
  "systems": 1       // Big-picture architect
};
```

### 3. Enable Neural Features Progressively

```bash
# Start simple
ruv-swarm init mesh --max-agents 3

# Add neural capabilities
ruv-swarm neural enable --models "lstm,tcn"

# Scale up
ruv-swarm agent spawn researcher --model lstm --pattern divergent
ruv-swarm agent spawn coder --model tcn --pattern convergent
```

### 4. Monitor and Optimize

```javascript
// Regular performance checks
mcp__ruv-swarm__benchmark_run {
  type: "neural",
  iterations: 100
}

// Analyze bottlenecks
mcp__ruv-swarm__neural_patterns {
  identifyBottlenecks: true,
  suggestOptimizations: true
}
```

## Troubleshooting

### Common Issues

1. **Neural models not loading**
   ```bash
   # Check WASM support
   npx ruv-swarm features detect --category wasm

   # Verify neural models
   npx ruv-swarm neural list
   ```

2. **Slow neural inference**
   ```bash
   # Enable SIMD acceleration
   export RUV_SWARM_USE_SIMD=true

   # Reduce neural network size
   ruv-swarm neural configure --optimize-size
   ```

3. **Agents not using neural features**
   ```javascript
   // Explicitly enable neural for agents
   mcp__ruv-swarm__agent_spawn {
     type: "coder",
     forceNeural: true,
     neuralModel: "lstm-optimizer"
   }
   ```

## Advanced Features

### Custom Neural Architectures

```javascript
// Define custom neural network
const customNeural = {
  architecture: {
    layers: [
      { neurons: 256, activation: "relu" },
      { neurons: 128, activation: "tanh" },
      { neurons: 64, activation: "sigmoid" },
      { neurons: 32, activation: "relu" }
    ],
    dropout: 0.2,
    batchNorm: true
  },
  training: {
    algorithm: "adam",
    learningRate: 0.001,
    batchSize: 32
  }
};

mcp__ruv-swarm__agent_spawn {
  type: "specialist",
  customNeural: customNeural
}
```

### Neural Knowledge Sharing

```javascript
// Enable swarm-wide learning
mcp__ruv-swarm__neural_train {
  mode: "swarm",
  knowledgeSharing: {
    enabled: true,
    frequency: "after_each_task",
    method: "federated"
  }
}
```

### Cognitive Load Balancing

```javascript
// Automatically balance cognitive load
mcp__ruv-swarm__task_orchestrate {
  task: "Complex system design",
  cognitiveBalancing: {
    enabled: true,
    maxLoadPerAgent: 0.8,
    redistributeOnOverload: true
  }
}
```

## Summary

To start a neural-enabled multi-agent system in ruv-swarm:

1. **Initialize**: Use `npx ruv-swarm@latest init --claude` for automatic setup
2. **Configure**: Set neural options in environment or config file
3. **Spawn**: Create agents with specific neural models and cognitive patterns
4. **Orchestrate**: Use adaptive strategies with neural optimization
5. **Monitor**: Track neural performance and adapt as needed

The neural capabilities provide cognitive diversity, enabling agents to approach problems from different perspectives and achieve better results than traditional single-approach systems.

## Resources

- GitHub: https://github.com/ruvnet/ruv-FANN
- Documentation: https://github.com/ruvnet/ruv-FANN/tree/main/ruv-swarm
- NPM: https://www.npmjs.com/package/ruv-swarm
- Examples: https://github.com/ruvnet/ruv-FANN/tree/main/ruv-swarm/

# ruv-swarm MCP Usage Guide

This guide provides comprehensive documentation for using ruv-swarm with Model Context Protocol (MCP) in Claude Code and other MCP-enabled tools.

## Table of Contents
- [Installation](#installation)
- [Configuration](#configuration)
- [MCP Tools Reference](#mcp-tools-reference)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Installation

### Quick Start with NPX
```bash
# No installation needed - run directly
npx ruv-swarm mcp start --protocol=stdio
```

### Global Installation
```bash
npm install -g ruv-swarm
ruv-swarm mcp start --protocol=stdio
```

## Configuration

### Claude Code Configuration

Create or edit `.claude/mcp.json` in your project root:

```json
{
  "mcpServers": {
    "ruv-swarm": {
      "command": "npx",
      "args": ["ruv-swarm", "mcp", "start", "--protocol=stdio"],
      "capabilities": {
        "tools": true
      },
      "metadata": {
        "name": "ruv-swarm",
        "version": "0.1.0",
        "description": "Distributed agent orchestration with neural networks"
      }
    }
  }
}
```

### Alternative Configuration (Script Wrapper)

For better control, create `mcp-server.sh`:
```bash
#!/bin/bash
cd /path/to/your/project
exec npx ruv-swarm mcp start --protocol=stdio
```

Then update `.claude/mcp.json`:
```json
{
  "mcpServers": {
    "ruv-swarm": {
      "command": "/path/to/mcp-server.sh",
      "capabilities": {
        "tools": true
      }
    }
  }
}
```

## MCP Tools Reference

### 1. swarm_init
Initialize a new swarm with specified topology and configuration.

**Parameters:**
- `topology` (string): Network topology - "mesh", "star", "hierarchical", "ring"
- `maxAgents` (number): Maximum number of agents (1-100, default: 5)
- `strategy` (string): Distribution strategy - "balanced", "specialized", "adaptive"

**Example:**
```typescript
await swarm_init({
  topology: "mesh",
  maxAgents: 10,
  strategy: "balanced"
});
```

**Response:**
```json
{
  "id": "swarm_1234567890_abc",
  "message": "Successfully initialized mesh swarm",
  "topology": "mesh",
  "strategy": "balanced",
  "maxAgents": 10,
  "created": "2025-06-29T12:00:00.000Z",
  "features": {
    "wasm_enabled": true,
    "simd_support": false,
    "runtime_features": {}
  }
}
```

### 2. swarm_status
Get current status of all active swarms.

**Parameters:**
- `verbose` (boolean): Include detailed agent information (default: false)

**Example:**
```typescript
await swarm_status({ verbose: true });
```

**Response:**
```json
{
  "active_swarms": 1,
  "swarms": [{
    "id": "swarm_1234567890_abc",
    "name": "mesh-swarm-1234567890",
    "topology": "mesh",
    "agents": {
      "total": 5,
      "active": 3,
      "idle": 2,
      "max": 10
    },
    "tasks": {
      "total": 15,
      "completed": 12,
      "success_rate": "80.0%"
    },
    "uptime": "45.2 minutes"
  }]
}
```

### 3. swarm_monitor
Monitor swarm activity in real-time.

**Parameters:**
- `duration` (number): Monitoring duration in seconds (default: 10)
- `interval` (number): Update interval in seconds (default: 1)

**Example:**
```typescript
await swarm_monitor({
  duration: 30,
  interval: 5
});
```

### 4. agent_spawn
Create a new agent in the swarm.

**Parameters:**
- `type` (string): Agent type - "researcher", "coder", "analyst", "optimizer", "coordinator"
- `name` (string): Custom agent name (optional)
- `capabilities` (array): Additional capabilities

**Example:**
```typescript
await agent_spawn({
  type: "researcher",
  name: "data-researcher-1",
  capabilities: ["web_search", "data_mining"]
});
```

**Response:**
```json
{
  "agent": {
    "id": "agent_1234567890_xyz",
    "name": "data-researcher-1",
    "type": "researcher",
    "status": "idle",
    "capabilities": [
      "data_analysis",
      "pattern_recognition",
      "web_search",
      "data_mining"
    ],
    "neural_network": {
      "id": "nn_1234567890_abc",
      "architecture": {
        "input_size": 10,
        "hidden_layers": [64, 32],
        "output_size": 5
      }
    }
  },
  "message": "Successfully spawned researcher agent",
  "swarm_capacity": "6/10"
}
```

### 5. agent_list
List all agents in the swarm.

**Parameters:**
- `filter` (string): Filter by status - "all", "active", "idle", "busy"

**Example:**
```typescript
await agent_list({ filter: "active" });
```

### 6. agent_metrics
Get performance metrics for agents.

**Parameters:**
- `agentId` (string): Specific agent ID (optional)
- `metric` (string): Metric type - "all", "cpu", "memory", "tasks", "performance"

**Example:**
```typescript
await agent_metrics({
  metric: "performance"
});
```

### 7. task_orchestrate
Orchestrate a task across the swarm.

**Parameters:**
- `task` (string): Task description
- `priority` (string): Priority level - "low", "medium", "high", "critical"
- `strategy` (string): Execution strategy - "parallel", "sequential", "adaptive"
- `maxAgents` (number): Maximum agents to use

**Example:**
```typescript
await task_orchestrate({
  task: "Analyze system performance and generate optimization report",
  priority: "high",
  strategy: "adaptive",
  maxAgents: 3
});
```

**Response:**
```json
{
  "taskId": "task_1234567890_abc",
  "status": "orchestrated",
  "priority": "high",
  "strategy": "adaptive",
  "executionTime": 523,
  "agentsUsed": 3,
  "assignedAgents": [
    "agent_1234567890_xyz",
    "agent_1234567890_def",
    "agent_1234567890_ghi"
  ],
  "summary": "Task successfully orchestrated across 3 agents"
}
```

### 8. task_status
Check the status of running tasks.

**Parameters:**
- `taskId` (string): Specific task ID (optional)
- `detailed` (boolean): Include detailed progress

**Example:**
```typescript
await task_status({
  taskId: "task_1234567890_abc",
  detailed: true
});
```

### 9. task_results
Retrieve results from completed tasks.

**Parameters:**
- `taskId` (string): Task ID to retrieve results for
- `format` (string): Result format - "summary", "detailed", "raw"

**Example:**
```typescript
await task_results({
  taskId: "task_1234567890_abc",
  format: "detailed"
});
```

### 10. benchmark_run
Execute performance benchmarks.

**Parameters:**
- `type` (string): Benchmark type - "all", "wasm", "swarm", "agent", "task"
- `iterations` (number): Number of iterations (1-100, default: 10)

**Example:**
```typescript
await benchmark_run({
  type: "agent",
  iterations: 20
});
```

### 11. features_detect
Detect runtime features and capabilities.

**Parameters:**
- `category` (string): Feature category - "all", "wasm", "simd", "memory", "platform"

**Example:**
```typescript
await features_detect({ category: "all" });
```

### 12. memory_usage
Get current memory usage statistics.

**Parameters:**
- `detail` (string): Detail level - "summary", "detailed", "by-agent"

**Example:**
```typescript
await memory_usage({ detail: "by-agent" });
```

## Usage Examples

### Example 1: Complete Workflow
```typescript
// 1. Initialize swarm
const swarm = await swarm_init({
  topology: "mesh",
  maxAgents: 10,
  strategy: "balanced"
});

// 2. Spawn specialized agents
const agents = await Promise.all([
  agent_spawn({ type: "researcher", name: "research-1" }),
  agent_spawn({ type: "coder", name: "coder-1" }),
  agent_spawn({ type: "analyst", name: "analyst-1" })
]);

// 3. Orchestrate task
const task = await task_orchestrate({
  task: "Build authentication system with JWT tokens",
  priority: "high",
  strategy: "adaptive",
  maxAgents: 3
});

// 4. Monitor progress
await swarm_monitor({ duration: 30, interval: 5 });

// 5. Get results
const results = await task_results({
  taskId: task.taskId,
  format: "detailed"
});
```

### Example 2: Performance Analysis
```typescript
// Run benchmarks
const benchmarks = await benchmark_run({
  type: "all",
  iterations: 50
});

// Get memory usage
const memory = await memory_usage({
  detail: "by-agent"
});

// Get agent metrics
const metrics = await agent_metrics({
  metric: "all"
});
```

### Example 3: Real-time Monitoring
```typescript
// Start monitoring
const monitoring = await swarm_monitor({
  duration: 300, // 5 minutes
  interval: 10   // Update every 10 seconds
});

// Check swarm status periodically
setInterval(async () => {
  const status = await swarm_status({ verbose: true });
  console.log(`Active agents: ${status.swarms[0].agents.active}`);
}, 30000);
```

## Best Practices

### 1. Swarm Initialization
- Start with smaller swarms (5-10 agents) and scale as needed
- Choose topology based on task requirements:
  - **Mesh**: Best for collaborative tasks
  - **Star**: Best for centralized coordination
  - **Hierarchical**: Best for complex workflows

### 2. Agent Management
- Spawn agents based on task requirements
- Monitor agent performance and adjust capacity
- Use specialized agents for specific tasks

### 3. Task Orchestration
- Set appropriate priorities for tasks
- Use adaptive strategy for complex tasks
- Monitor task progress and handle failures

### 4. Performance Optimization
- Run benchmarks to identify bottlenecks
- Monitor memory usage regularly
- Adjust agent count based on workload

## Troubleshooting

### Common Issues

#### 1. MCP Server Not Starting
```bash
# Check if port is in use
lsof -i :3000

# Kill existing processes
pkill -f "ruv-swarm mcp"

# Restart with debug mode
npx ruv-swarm mcp start --protocol=stdio --debug
```

#### 2. Agent Spawn Failures
- Check swarm capacity with `swarm_status`
- Ensure swarm is initialized with `swarm_init`
- Verify agent type is valid

#### 3. Task Orchestration Errors
- Ensure agents are available
- Check task syntax and parameters
- Monitor swarm health with `swarm_monitor`

#### 4. Memory Issues
- Monitor with `memory_usage` tool
- Reduce agent count if needed
- Clear old tasks and data periodically

### Debug Mode
Enable debug logging:
```bash
export RUV_SWARM_DEBUG=true
npx ruv-swarm mcp start --protocol=stdio --debug
```

### Log Files
Check logs at:
- `./data/ruv-swarm.log` - General logs
- `./data/ruv-swarm.db` - SQLite database
- `stderr` output for MCP errors

## Advanced Configuration

### Environment Variables
```bash
# Maximum agents per swarm
export RUV_SWARM_MAX_AGENTS=50

# Database location
export RUV_SWARM_DB_PATH=./custom/path/swarm.db

# Enable SIMD optimizations
export RUV_SWARM_USE_SIMD=true

# Debug mode
export RUV_SWARM_DEBUG=true
```

### Custom Neural Network Configuration
```javascript
{
  "neural_config": {
    "architecture": "cascade",
    "learning_rate": 0.01,
    "momentum": 0.9,
    "hidden_layers": [128, 64, 32],
    "activation": "relu",
    "optimizer": "adam"
  }
}
```

### Performance Tuning
```javascript
{
  "performance": {
    "batch_size": 32,
    "max_concurrent_tasks": 10,
    "agent_timeout": 30000,
    "memory_limit": "512MB",
    "cpu_threshold": 0.8
  }
}
```

## Integration Examples

### With Claude Code
```javascript
// In Claude Code, use the tools directly
const swarm = await mcp.tools.ruv_swarm.swarm_init({
  topology: "mesh",
  maxAgents: 10
});

const agents = await mcp.tools.ruv_swarm.agent_list({
  filter: "all"
});
```

### With Custom Scripts
```javascript
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

async function callMcpTool(tool, params) {
  const request = {
    jsonrpc: "2.0",
    method: "tools/call",
    params: {
      name: tool,
      arguments: params
    },
    id: Date.now()
  };

  const { stdout } = await execAsync(
    `echo '${JSON.stringify(request)}' | npx ruv-swarm mcp start --protocol=stdio`
  );

  return JSON.parse(stdout);
}

// Use the tool
const result = await callMcpTool('swarm_init', {
  topology: 'mesh',
  maxAgents: 5
});
```

# Claude Code CLI with ruv-swarm Neural Multi-Agent System

## Overview

This guide provides comprehensive documentation for using Claude Code CLI with ruv-swarm's neural-powered multi-agent orchestration system. ruv-swarm enables distributed agent coordination with integrated neural networks for cognitive diversity, allowing you to tackle complex tasks with specialized AI agents.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Installation & Setup](#installation--setup)
4. [Core Concepts](#core-concepts)
5. [Working with Claude Code CLI](#working-with-claude-code-cli)
6. [Neural Agent System](#neural-agent-system)
7. [Common Workflows](#common-workflows)
8. [Advanced Usage](#advanced-usage)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)
11. [Performance Optimization](#performance-optimization)
12. [Examples & Templates](#examples--templates)

## Quick Start

```bash
# Verify installations
ruv-swarm --version  # Should show 1.0.14+
claude --version     # Verify Claude Code CLI

# Start MCP server
ruv-swarm mcp start

# In another terminal, use Claude Code
claude

# Ask Claude to initialize a swarm
# "Initialize a hierarchical ruv-swarm with 8 neural agents for building a microservices architecture"
```

## Prerequisites

### System Requirements

- **OS**: Linux, macOS, or Windows (WSL2 recommended)
- **Node.js**: v18.0.0 or higher (v22.17.0 recommended)
- **Memory**: 8GB minimum, 16GB+ recommended for complex swarms
- **CPU**: Multi-core processor (4+ cores recommended)
- **GPU**: Optional but beneficial for neural network acceleration

### Required Software

1. **Claude Code CLI** (authenticated)
   ```bash
   # Install if not present
   npm install -g @anthropic-ai/claude-code
   claude auth login
   ```

2. **ruv-swarm** (globally installed)
   ```bash
   npm install -g ruv-swarm
   ```

## Installation & Setup

### Step 1: Verify Environment

```bash
# Check Node.js version
node --version  # Should be v18.0.0+

# Verify ruv-swarm installation
ruv-swarm --version

# Test MCP server
ruv-swarm mcp start --test
```

### Step 2: Configure Claude Code Integration

Since Claude Code CLI doesn't use `.claude/mcp.json` files, we'll use direct integration:

```bash
# Option 1: Environment variable configuration
export CLAUDE_MCP_SERVERS='{"ruv-swarm":{"command":"ruv-swarm","args":["mcp","start","--protocol=stdio"]}}'

# Option 2: Create a startup script
cat > start-claude-swarm.sh << 'EOF'
#!/bin/bash
# Start MCP server in background
ruv-swarm mcp start &
MCP_PID=$!

# Give it time to initialize
sleep 2

# Start Claude Code
claude "$@"

# Cleanup on exit
trap "kill $MCP_PID" EXIT
EOF

chmod +x start-claude-swarm.sh
```

### Step 3: Enable Neural Features

```bash
# Set environment variables for optimal performance
export RUV_SWARM_NEURAL_ENABLED=true
export RUV_SWARM_USE_SIMD=true
export RUV_SWARM_COGNITIVE_DIVERSITY=balanced
export RUV_SWARM_NEURAL_CACHE_MB=512
```

## Core Concepts

### 1. Swarm Topologies

- **Mesh**: Fully connected, best for collaborative research
- **Hierarchical**: Tree structure, ideal for complex projects
- **Star**: Centralized control, good for coordinated tasks
- **Ring**: Sequential processing, perfect for pipelines

### 2. Agent Types

- **Researcher**: Information gathering and analysis
- **Coder**: Implementation and development
- **Analyst**: Critical evaluation and optimization
- **Architect**: System design and planning
- **Tester**: Quality assurance and validation

### 3. Cognitive Patterns

- **Convergent**: Focused, analytical thinking
- **Divergent**: Creative, exploratory approach
- **Critical**: Evaluative, decision-making
- **Systems**: Holistic, big-picture view
- **Lateral**: Associative, connection-making
- **Abstract**: Conceptual, theoretical

### 4. Neural Models

- **LSTM**: Sequential data and code understanding
- **TCN**: Pattern detection and recognition
- **Transformer**: Complex reasoning tasks
- **N-BEATS**: Task decomposition and planning
- **Autoencoder**: Anomaly detection
- **GNN**: Dependency analysis

## Working with Claude Code CLI

### Starting a Session

```bash
# Method 1: Direct usage
claude

# Method 2: With startup script
./start-claude-swarm.sh

# Method 3: With specific task
claude --task "Build a REST API with authentication"
```

### Basic Commands in Claude

Once in Claude Code, you can use natural language to control ruv-swarm:

```
# Initialize a swarm
"Initialize a mesh topology swarm with 5 neural agents"

# Spawn specific agents
"Create a researcher agent with LSTM neural model and divergent thinking"

# Orchestrate tasks
"Use the swarm to build a microservices architecture with authentication"

# Monitor performance
"Show me the current swarm status and agent metrics"
```

### MCP Tool Usage

Claude Code CLI recognizes ruv-swarm MCP tools automatically when the server is running:

```javascript
// These tools are available in Claude:
- swarm_init
- swarm_status
- swarm_monitor
- agent_spawn
- agent_list
- agent_metrics
- task_orchestrate
- task_status
- task_results
- benchmark_run
- features_detect
- memory_usage
```

## Neural Agent System

### Initializing Neural Swarms

```bash
# In Claude Code, request:
"Initialize a hierarchical swarm with neural networks enabled, using 8 agents with cognitive diversity"

# This translates to:
mcp__ruv-swarm__swarm_init {
  topology: "hierarchical",
  maxAgents: 8,
  strategy: "specialized",
  enableNeural: true
}
```

### Spawning Neural Agents

```bash
# Request in Claude:
"Create a team of neural agents: 2 researchers with divergent thinking, 2 coders with convergent thinking, 1 architect with systems thinking, and 1 analyst with critical thinking"

# Each agent gets specific neural configuration:
mcp__ruv-swarm__agent_spawn {
  type: "researcher",
  neuralModel: "lstm-optimizer",
  cognitivePattern: "divergent"
}
```

### Cognitive Load Balancing

```bash
# Request in Claude:
"Orchestrate a complex task with automatic cognitive load balancing across all agents"

# Configures:
mcp__ruv-swarm__task_orchestrate {
  task: "Your complex task",
  cognitiveBalancing: {
    enabled: true,
    maxLoadPerAgent: 0.8,
    redistributeOnOverload: true
  }
}
```

## Common Workflows

### 1. Building a REST API

```bash
# In Claude Code:
"Create a production-ready REST API with JWT authentication, user management, role-based access control, and comprehensive tests using a neural swarm"

# Claude will:
1. Initialize appropriate swarm topology
2. Spawn specialized agents (architect, backend devs, security expert, QA)
3. Orchestrate the task with neural optimization
4. Monitor progress and provide updates
5. Deliver complete implementation
```

### 2. Microservices Architecture

```bash
# In Claude Code:
"Design and implement a microservices architecture with API gateway, service discovery, load balancing, distributed caching, and monitoring"

# Process:
1. System architect designs overall structure
2. Multiple coders implement individual services
3. Analyst ensures security and optimization
4. Tester validates integration
5. Researcher finds best practices
```

### 3. Data Pipeline

```bash
# In Claude Code:
"Build an ETL pipeline that processes CSV files, validates data, performs transformations, and outputs to multiple formats with error handling"

# Agents collaborate:
- Researcher: Identifies data patterns
- Architect: Designs pipeline structure
- Coder: Implements transformations
- Analyst: Optimizes performance
- Tester: Validates output
```

## Advanced Usage

### Custom Neural Architectures

```javascript
// Request in Claude:
"Create a specialist agent with a custom neural network:
- 4 hidden layers (256->128->64->32 neurons)
- ReLU activation with dropout
- Adam optimizer with 0.001 learning rate"

// Results in:
const customNeural = {
  architecture: {
    layers: [
      { neurons: 256, activation: "relu", dropout: 0.2 },
      { neurons: 128, activation: "relu", dropout: 0.2 },
      { neurons: 64, activation: "relu", dropout: 0.1 },
      { neurons: 32, activation: "relu" }
    ],
    batchNorm: true
  },
  training: {
    algorithm: "adam",
    learningRate: 0.001,
    batchSize: 32
  }
};
```

### Federated Learning

```bash
# Enable swarm-wide knowledge sharing
"Configure all agents to share knowledge using federated learning after each task"

# Configures:
mcp__ruv-swarm__neural_train {
  mode: "swarm",
  knowledgeSharing: {
    enabled: true,
    frequency: "after_each_task",
    method: "federated"
  }
}
```

### Performance Profiling

```bash
# Request comprehensive profiling
"Run performance benchmarks on all agents and identify optimization opportunities"

# Executes:
- Neural network inference speed tests
- Memory usage analysis
- Task completion metrics
- Cognitive pattern effectiveness
```

## Best Practices

### 1. Task Decomposition

```bash
# Good: Clear, hierarchical breakdown
"Build a blog platform with:
1. User authentication system
2. Article CRUD operations
3. Comment system with threading
4. Tag-based categorization
5. Search functionality
6. Admin dashboard"

# Less effective: Vague requirements
"Build a blog"
```

### 2. Agent Specialization

```bash
# Optimal team composition for different tasks:

# Web Development:
- 1 Architect (systems thinking)
- 2 Coders (convergent thinking)
- 1 Security Analyst (critical thinking)
- 1 QA Tester (critical thinking)

# Research Projects:
- 3 Researchers (divergent thinking)
- 1 Analyst (critical thinking)
- 1 Architect (systems thinking)

# Data Analysis:
- 2 Analysts (lateral thinking)
- 1 Researcher (divergent thinking)
- 2 Coders (convergent thinking)
```

### 3. Resource Management

```bash
# Monitor resource usage
"Show current memory usage by agent and suggest optimizations"

# Adjust swarm size based on task
"Scale down to 3 agents for simple tasks"
"Scale up to 10 agents for complex architecture"
```

### 4. Error Handling

```bash
# Request robust error handling
"Implement the API with comprehensive error handling, including:
- Input validation
- Database transaction rollbacks
- Graceful degradation
- Detailed error logging
- User-friendly error messages"
```

## Troubleshooting

### Common Issues and Solutions

#### 1. MCP Server Connection Issues

```bash
# Problem: Claude can't connect to ruv-swarm
# Solution:
pkill -f "ruv-swarm mcp"  # Kill existing processes
ruv-swarm mcp start --debug  # Start with debug logging

# Alternative: Use explicit port
ruv-swarm mcp start --port 3456
```

#### 2. Agent Spawn Failures

```bash
# Problem: "Failed to spawn agent"
# Solutions:
1. Check swarm capacity: "Show current swarm status"
2. Verify swarm exists: "List all active swarms"
3. Reset if needed: "Terminate all swarms and reinitialize"
```

#### 3. Neural Model Loading Issues

```bash
# Problem: Neural features not working
# Solutions:
1. Verify WASM support: "Run feature detection for WASM"
2. Check environment: echo $RUV_SWARM_NEURAL_ENABLED
3. Reinstall with neural support: npm install -g ruv-swarm --features=neural
```

#### 4. Performance Degradation

```bash
# Problem: Slow task execution
# Solutions:
1. "Run performance benchmarks"
2. "Show memory usage by agent"
3. "Optimize neural network sizes"
4. "Enable SIMD acceleration"
```

### Debug Mode

```bash
# Enable comprehensive debugging
export RUV_SWARM_DEBUG=true
export RUV_SWARM_LOG_LEVEL=verbose

# Check logs
tail -f ./data/ruv-swarm.log
```

## Performance Optimization

### 1. Neural Network Optimization

```bash
# Request optimization
"Optimize neural networks for faster inference:
- Reduce layer sizes where possible
- Enable SIMD acceleration
- Use quantization for non-critical agents
- Implement batch processing"
```

### 2. Swarm Topology Optimization

```bash
# Choose optimal topology
"Analyze my task and recommend the best swarm topology"

# Guidelines:
- Mesh: Collaborative tasks < 6 agents
- Hierarchical: Complex projects with clear structure
- Star: Centralized decision-making tasks
- Ring: Sequential processing pipelines
```

### 3. Caching Strategies

```bash
# Enable intelligent caching
"Configure swarm with:
- Neural model caching (512MB)
- Task result caching
- Agent state persistence
- Knowledge graph caching"
```

## Examples & Templates

### 1. Full-Stack Application Template

```bash
# In Claude Code:
"Create a full-stack application template with:
- React frontend with TypeScript
- Node.js/Express backend
- PostgreSQL database
- Redis caching
- JWT authentication
- Docker composition
- CI/CD pipeline
Using a hierarchical swarm with 8 specialized agents"
```

### 2. Microservices Template

```bash
# In Claude Code:
"Generate a microservices template with:
- API Gateway (Kong/Traefik)
- Service Registry (Consul)
- Message Queue (RabbitMQ)
- Distributed Tracing (Jaeger)
- Monitoring (Prometheus/Grafana)
- 5 example services
Using mesh topology with neural coordination"
```

### 3. Data Science Pipeline

```bash
# In Claude Code:
"Build a data science pipeline template:
- Data ingestion from multiple sources
- Preprocessing and validation
- Feature engineering
- Model training with hyperparameter tuning
- Model deployment with API
- Monitoring and retraining
Using specialized neural agents for each stage"
```

### 4. Quick Scripts

```bash
# API Development
./claude-swarm.sh api "REST API with auth"

# Full-Stack App
./claude-swarm.sh fullstack "React + Node.js app"

# Data Pipeline
./claude-swarm.sh data "ETL pipeline"

# Custom Task
./claude-swarm.sh custom "Your specific requirements"
```

## Performance Benchmarks

When using neural-enabled swarms:

- **Task Completion**: 2.8-4.4x faster than single-agent
- **Code Quality**: 96.4% retention with neural optimization
- **Token Efficiency**: 32.3% reduction through coordination
- **Accuracy**: 84.8% on SWE-Bench (14.5% above baseline)

## Conclusion

Claude Code CLI with ruv-swarm provides a powerful platform for tackling complex development tasks using neural-powered multi-agent systems. By leveraging cognitive diversity and specialized agents, you can achieve better results faster than traditional approaches.

### Key Takeaways:

1. **Start Simple**: Begin with small swarms and scale as needed
2. **Match Topology to Task**: Choose the right structure for your project
3. **Leverage Cognitive Diversity**: Use different thinking patterns for better solutions
4. **Monitor and Optimize**: Track performance and adjust as needed
5. **Iterate and Learn**: Agents improve through experience

### Next Steps:

1. Start the MCP server: `ruv-swarm mcp start`
2. Launch Claude Code: `claude`
3. Try a simple task: "Initialize a mesh swarm with 3 agents"
4. Build something amazing!

## Resources

- **GitHub**: https://github.com/ruvnet/ruv-FANN
- **NPM Package**: https://www.npmjs.com/package/ruv-swarm
- **Documentation**: https://github.com/ruvnet/ruv-FANN/tree/main/ruv-swarm
- **Examples**: https://github.com/ruvnet/ruv-FANN/tree/main/ruv-swarm/examples
- **Support**: Issues on GitHub repository

---

*Version: 1.0.0 | Last Updated: January 2025*
