# Antigravity CLI (`agy`) Commands

A comprehensive reference for DevOps engineers and automation workflows using the Antigravity CLI (`agy`).

---

## 1. Quick Start & Execution Modes

```bash
# Launch interactive Antigravity CLI session
agy

# Auto-approve all tool permission requests without prompting (ideal for automated CI/CD runs & trusted scripts)
agy --dangerously-skip-permissions

# Launch with Terminal Sandbox restrictions enabled (safer for untrusted environments)
agy --sandbox

# Start session in a specific execution mode (plan, auto, accept-edits)
agy --mode plan
agy --mode auto
agy --mode accept-edits

# Set reasoning effort level (low | medium | high | xhigh | max)
agy --effort high

# Specify model for the current CLI session
agy --model gemini-3.8-flash
```

---

## 2. Non-Interactive / Scripting / CI-CD Automation

```bash
# Run a single prompt non-interactively and print response to stdout (-p / --print)
agy --print "Analyze the terraform plan output in tfplan.txt and summarize risks"

# Combine non-interactive run with auto-approval for fully headless automation
agy --print "Run pytest and fix any failing unit tests" --dangerously-skip-permissions

# Set a timeout for non-interactive execution (e.g. 5m, 300s; 0 waits indefinitely)
agy --print "Audit Dockerfile for security vulnerabilities" --print-timeout 180s

# Output structured JSON output
agy --print "List all deprecated Kubernetes APIs in ./k8s/" --output-format json

# Enforce structured output via JSON schema
agy --print "Extract database credentials needed from config.yaml" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"user":{"type":"string"},"host":{"type":"string"}}}'

# Stream NDJSON message input/output (for pipeline streaming integrations)
echo '{"prompt": "Check cluster health"}' | agy --input-format stream-json --output-format stream-json

# Disable slash command and skill expansion during print mode
agy -p "Evaluate regex pattern" --disable-slash-commands
```

---

## 3. Session & Conversation Resumption

```bash
# Continue the most recent conversation (-c / --continue)
agy -c

# Resume a specific previous conversation by conversation ID
agy --conversation 93b0cd58-6244-45b6-b014-0701fb3db908

# Start an initial prompt interactively and keep the session active
agy -i "Review recent git commits and check deployment readiness"

# Work with multiple directories in a single workspace session
agy --add-dir /home/ubuntu/project-backend --add-dir /home/ubuntu/project-frontend

# Create a new project workspace for this session
agy --new-project --project "infra-migration"
```

---

## 4. Models & Agents Inspection

```bash
# List available models
agy models

# List available agent types
agy agents
agy agent

# Specify a specialized agent type
agy --agent research
```

---

## 5. Model Context Protocol (MCP) Management

```bash
# List configured MCP servers
agy mcp list

# Add a new MCP server (e.g., PostgreSQL, GitHub, AWS)
agy mcp add postgresql -- npx -y @modelcontextprotocol/server-postgres postgresql://user:pass@localhost:5432/mydb

# Enable / Disable an MCP server
agy mcp enable postgresql
agy mcp disable postgresql

# Remove an MCP server
agy mcp remove postgresql
```

---

## 6. Plugins & Extensions

```bash
# List installed plugins
agy plugin list

# Install a plugin
agy plugin install <plugin-name-or-path>

# Enable or disable a plugin
agy plugin enable <plugin-name>
agy plugin disable <plugin-name>

# Uninstall a plugin
agy plugin uninstall <plugin-name>
```

---

## 7. Remote Control & Daemon

```bash
# Check status of the remote-control background daemon
agy remote-control status

# Start remote-control daemon
agy remote-control start

# Stop remote-control daemon
agy remote-control stop

# Launch CLI session with a remote connection attached
agy --remote-control
```

---

## 8. Essential Interactive TUI Slash Commands

Inside an interactive `agy` session, use slash commands for workflow automation:

| Slash Command | DevOps Purpose |
| :--- | :--- |
| `/help` | Display all available CLI commands and help documentation |
| `/plan` | Generate a comprehensive step-by-step implementation plan before touching code |
| `/goal` | Execute long-running autonomous tasks without stopping until the objective is met |
| `/schedule` | Run a task on a recurring cron schedule or set a one-time reminder |
| `/compact` | Compress conversation context history to free up token window during long debugging sessions |
| `/clear` | Clear the current terminal / chat view |
| `/browser` | Launch browser automation & web testing tasks |
| `/boost` | Deep reasoning, strategic architectural planning, and rigorous verification |
| `/learn` | Persist custom instructions, fixes, or configurations for future sessions |
| `/exit` or `/quit` | Exit the CLI session (`Ctrl+D Ctrl+D`) |
