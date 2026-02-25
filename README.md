# devcontAIner

Reusable devcontainer template for AI-assisted development with Claude Code and Gemini CLI.

## Architecture

Hybrid approach: standard runtimes and tools are declared as **Dev Container Features** (applied after image build), while bespoke tooling is installed in the **Dockerfile** (cached as Docker layers).

```
devcontainer.json (Features)     Dockerfile (custom tooling)
├── Node.js 22 + pnpm           ├── build-essential, curl, jq
├── Python                      ├── fd, tree, fzf (apt)
├── Bun                         ├── ast-grep, git-delta, eza (GitHub releases)
├── gh CLI                      ├── GrepAI (GitHub release)
├── Claude Code                 ├── tree-sitter grammars
├── Gemini CLI                  └── tree-sitter config
├── Playwright + Chromium
├── ripgrep
├── bat
├── uv/uvx
└── Docker-outside-of-Docker
```

## What's included

### Dev Container Features (declarative, in devcontainer.json)

| Feature | GHCR ID |
|---------|---------|
| Docker-outside-of-Docker | `ghcr.io/devcontainers/features/docker-outside-of-docker:1` |
| Node.js 22 + pnpm | `ghcr.io/devcontainers/features/node:1` |
| GitHub CLI | `ghcr.io/devcontainers/features/github-cli:1` |
| Python | `ghcr.io/devcontainers/features/python:1` |
| Bun | `ghcr.io/devcontainers-extra/features/bun:1` |
| Claude Code | `ghcr.io/devcontainers-extra/features/claude-code:1` |
| Gemini CLI | `ghcr.io/stu-bell/devcontainer-features/gemini-cli:0` |
| Playwright + Chromium | `ghcr.io/schlich/devcontainer-features/playwright:0` |
| ripgrep | `ghcr.io/jungaretti/features/ripgrep:1` |
| bat | `ghcr.io/jsburckhardt/devcontainer-features/bat:1` |
| uv/uvx | `ghcr.io/jsburckhardt/devcontainer-features/uv:1` |

### Dockerfile (custom tooling, cached as Docker layers)

Search and navigation:

| Tool | Binary | Purpose |
|------|--------|---------|
| fd-find | `fd` | Fast file finder |
| ast-grep | `sg` | AST-based code search |
| fzf | `fzf` | Fuzzy finder |
| tree | `tree` | Directory structure viewer |

Display and diffs:

| Tool | Binary | Purpose |
|------|--------|---------|
| eza | `eza` | Modern `ls` with git status |
| git-delta | `delta` | Enhanced git diffs |

AI tooling:

| Tool | Binary | Purpose |
|------|--------|---------|
| GrepAI | `grepai` | Semantic code search |
| tree-sitter | `tree-sitter` | Incremental parsing (installed via onCreateCommand) |

### Lifecycle commands

| Phase | Command |
|-------|---------|
| `onCreateCommand` | `npm install -g tree-sitter-cli` (needs Node.js Feature) |
| `postCreateCommand` | Version checks for all tools |

### Bind mounts (host -> container)

| Host path | Container path | Purpose |
|-----------|----------------|---------|
| `~/.claude` | `/home/vscode/.claude` | Claude Code config, credentials, plugins, sessions |
| `~/.claude.json` | `/home/vscode/.claude.json` | Claude Code authentication |
| `~/.claude-mem` | `/home/vscode/.claude-mem` | Claude memory database |
| `~/.gemini` | `/home/vscode/.gemini` | Gemini CLI config and auth |
| `~/.gitconfig` | `/home/vscode/.gitconfig` | Git configuration |
| `~/.ssh` | `/home/vscode/.ssh` | SSH keys |
| `~/.1password/agent.sock` | `/home/vscode/.1password/agent.sock` | 1Password SSH agent |
| `~/.config/awf` | `/home/vscode/.config/awf` | AWF CLI config |
| `~/.local/share/awf` | `/home/vscode/.local/share/awf` | AWF CLI data |
| `/usr/local/bin/awf` | `/usr/local/bin/awf` | AWF binary (read-only) |

## Usage in a new project

Copy the devcontainer files into your project:

```bash
cp -r path/to/devcontAIner/.devcontainer /path/to/your-project/
cp -r path/to/devcontAIner/docker /path/to/your-project/
```

Open your project in VS Code and run:
**Command Palette -> Dev Containers: Reopen in Container**

## Add language runtimes

Use [devcontainer Features](https://containers.dev/features) in `devcontainer.json`:

```json
"features": {
  "ghcr.io/devcontainers/features/php:1": { "version": "8.3" },
  "ghcr.io/devcontainers/features/go:1": { "version": "latest" },
  "ghcr.io/devcontainers/features/rust:1": { "version": "latest" }
}
```

## Notes

- `~/.claude` is bind-mounted read/write: sessions, memories, and plugins are shared with the host
- `~/.gemini` is bind-mounted read/write: config and auth are shared with the host
- SSH authentication uses 1Password agent forwarding via socket mount
- Agent tools from GitHub releases (ast-grep, delta, eza, grepai) are fetched at latest version during build; may hit GitHub API rate limits without auth
- Features are applied after the Dockerfile build; the Dockerfile cannot use tools installed by Features
- Community Features (v0.x) may break; fallback is to move the install back into the Dockerfile
