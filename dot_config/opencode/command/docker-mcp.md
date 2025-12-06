---
description: Find, add, or manage Docker MCP servers dynamically
---

# Docker MCP Dynamic Tool Workflow

You have access to Docker MCP Gateway, which provides dynamic tool discovery and management. Instead of having all MCP tools loaded at once (bloating context), you can find and add tools on-demand.

## Your Task

**Action:** $1
**Target:** $2

If an action and target are provided, execute that action immediately using the workflow below. Valid actions:
- `find` - Search for servers matching the target query
- `add` - Add the target server to the session
- `remove` - Remove the target server from the session
- `config` - Configure the target server (use $3 for key and $4 for value)

If no arguments provided, explain the workflow and ask what the user needs.

## Available Primordial Tools

These tools are always available through the `MCP_DOCKER` server:

| Tool | Purpose |
|------|---------|
| `mcp-find` | Search the Docker MCP Catalog for servers by name or description |
| `mcp-add` | Add a server to the current session (pulls image, starts container, loads tools) |
| `mcp-remove` | Remove a server from the current session |
| `mcp-config-set` | Set configuration values for a server (API keys, settings) |
| `mcp-exec` | Execute a tool from a dynamically added server |

## Workflow

### 1. Find a Server

When you need tools for a specific task, search the catalog:

```
mcp-find query="github"
mcp-find query="database postgres"
mcp-find query="browser automation"
mcp-find query="slack notifications"
```

This returns matching servers with their names, descriptions, and required secrets.

### 2. Add the Server

Once you find what you need, add it to the session:

```
mcp-add name="github-official" activate=true
mcp-add name="playwright" activate=true
```

Setting `activate=true` makes the tools immediately available. Cursor will refresh and show the new tools.

### 3. Configure if Needed

Some servers require configuration (API keys, settings):

```
mcp-config-set server="slack" key="api_token" value="xoxb-..."
mcp-config-set server="neon" key="api_key" value="..."
```

### 4. Use the Tools

After adding, the server's tools appear in your available tools. Use them normally.

### 5. Clean Up

When done, remove servers to keep the session lean:

```
mcp-remove name="github-official"
```

## Example Session

User asks: "I need to create a GitHub issue for a bug I found"

```
# 1. Find GitHub server
mcp-find query="github"
# Returns: github-official, github, github-chat, etc.

# 2. Add the official GitHub server
mcp-add name="github-official" activate=true
# Returns: Successfully added 40 tools in server 'github-official'

# 3. Now use GitHub tools (issue_write, create_pull_request, etc.)
# Tools are available in the session

# 4. When done, clean up
mcp-remove name="github-official"
```

## Pre-Enabled vs Dynamic Servers

**Pre-enabled servers** (via `docker mcp server enable`):
- Tools load automatically when gateway starts
- Always available but bloat context
- Good for frequently-used tools

**Dynamic servers** (via `mcp-add`):
- Added on-demand during conversation
- Keep context lean
- Removed when session ends (not persistent)

## Common Servers in the Catalog

| Server | Tools | Use Case |
|--------|-------|----------|
| `github-official` | 40 | GitHub API, issues, PRs, repos |
| `playwright` | 21 | Browser automation, screenshots |
| `neon` | 19 | Postgres database management |
| `slack` | ~15 | Slack messaging |
| `linear` | ~20 | Project management, issues |
| `sequentialthinking` | 1 | Step-by-step reasoning |

## Known Issues

### Ref MCP Server
The `ref` server in Docker MCP is currently broken (issue #35). The Dockerfile sets `ENV TRANSPORT=http` but Docker MCP Gateway expects stdio. Use the direct npx config instead:

```json
"Ref": {
  "command": "npx",
  "args": ["ref-tools-mcp@latest"],
  "env": { "REF_API_KEY": "your-key" }
}
```

### OAuth Servers
Some servers require OAuth authorization before use:
```bash
docker mcp oauth authorize github
docker mcp oauth authorize linear
```

## Best Practices

1. **Start lean** - Don't pre-enable everything, use dynamic discovery
2. **Search first** - Use `mcp-find` to discover what's available
3. **Clean up** - Remove servers when done to keep context small
4. **Check secrets** - `mcp-find` results show `required_secrets` - configure before adding
5. **Activate immediately** - Use `activate=true` with `mcp-add` so tools are ready

