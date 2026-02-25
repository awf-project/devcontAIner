# devcontAIner Implementation Plan

**Goal:** Create a reusable devcontainer template that runs AI CLI agents inside a Debian container with host configuration bind-mounted read/write, using Dev Container Features for standard runtimes and a Dockerfile for custom tooling.

**Architecture:** Hybrid Features + Dockerfile. Features handle standard runtimes (Node.js, Python, Bun, gh CLI, Claude Code, Gemini CLI, Playwright, ripgrep, bat, uv). Dockerfile handles bespoke tooling (ast-grep, git-delta, eza, GrepAI, tree-sitter grammars, fd, tree, fzf).

**Tech Stack:** Docker BuildKit, devcontainer spec v0.3, mcr.microsoft.com/devcontainers/base:bookworm, 11 Dev Container Features

---

## Completed Tasks

### Task 1: Create project skeleton

- Created `docker/devcontainer/` and `.devcontainer/` directories
- Initialized git repo

### Task 2: Write the Dockerfile

**File:** `docker/devcontainer/Dockerfile`

Layers (in order):
1. Base image: `mcr.microsoft.com/devcontainers/base:bookworm`
2. Build deps: `build-essential`, `xz-utils`, `unzip`, `curl`, `jq`
3. Agent tools via apt: `fd-find`, `tree`, `fzf`
4. Agent tools from GitHub releases: `ast-grep` (sg), `git-delta`, `eza` (multi-arch: amd64/arm64)
5. GrepAI from GitHub releases (multi-arch)
6. Tree-sitter grammars: dart, go, php, python, typescript (git clone)
7. Tree-sitter config for vscode user
8. Switch to `USER vscode`

### Task 3: Write devcontainer.json

**File:** `.devcontainer/devcontainer.json`

Configuration:
- Build context pointing to `../docker/devcontainer/Dockerfile`
- Features (11):
  - `docker-outside-of-docker:1` — host Docker daemon access
  - `node:1` (v22) — Node.js, pnpm via corepack
  - `github-cli:1` — gh CLI
  - `python:1` — Python runtime
  - `bun:1` — Bun runtime
  - `claude-code:1` — Claude Code AI agent
  - `gemini-cli:0` — Gemini CLI AI agent
  - `playwright:0` — Playwright + Chromium
  - `ripgrep:1` — Fast regex search
  - `bat:1` — File viewer with syntax highlighting
  - `uv:1` — Python package manager (for Serena MCP server)
- Bind mounts:
  - `~/.claude` -> Claude Code config, credentials, plugins, sessions
  - `~/.claude.json` -> Claude Code authentication
  - `~/.claude-mem` -> Claude memory database
  - `~/.gemini` -> Gemini CLI config and auth
  - `~/.gitconfig` -> git settings
  - `~/.ssh` -> SSH keys
  - `~/.1password/agent.sock` -> 1Password SSH agent forwarding
  - AWF CLI: config (`~/.config/awf`), data (`~/.local/share/awf`), binary (`/usr/local/bin/awf`, read-only)
- Remote env: `SSH_AUTH_SOCK` set to 1Password agent socket, `OLLAMA_HOST` for local AI
- VS Code extensions: Claude Code, Markdown Mermaid, Docker, Markdown Preview Enhanced
- `onCreateCommand`: `npm install -g tree-sitter-cli`
- `postCreateCommand`: version checks for all tools

### Task 4: Migrate to Features-first architecture

Migrated standard runtimes from Dockerfile to Dev Container Features:
- Removed from Dockerfile: Node.js, gh CLI, corepack/pnpm, Claude Code, Gemini CLI, Playwright, Bun, ripgrep, bat, uv/uvx
- Added 8 new Features to devcontainer.json
- Moved tree-sitter-cli to `onCreateCommand` (needs Node.js from Feature)
- Dockerfile reduced from ~170 to ~88 lines (-48%)

### Task 5: Smoke test

Manual verification via VS Code Dev Containers:
1. Open project in VS Code
2. Command Palette -> Dev Containers: Reopen in Container
3. Verify mounts: `ls /home/vscode/.claude/`
4. Verify Feature tools: `node --version`, `pnpm --version`, `bun --version`, `gh --version`, `python3 --version`, `claude --version`, `gemini --version`, `rg --version`, `bat --version`, `uv --version`
5. Verify Dockerfile tools: `sg --version`, `delta --version`, `eza --version`, `fd --version`, `fzf --version`, `grepai version`, `tree-sitter --version`
6. Verify auth: `claude -p "Say: container OK"`
7. Verify Playwright: `npx playwright --version`

### Task 6: Write documentation

- `README.md`: architecture overview, tool inventory (Features vs Dockerfile), mount table, usage
- `docs/plans/2026-02-25-devcontainer-design.md`: architecture decisions, trade-offs, build order
- `docs/plans/2026-02-25-devcontainer-impl.md`: this file

---

## Final Structure

```
devcontAIner/
├── .devcontainer/
│   └── devcontainer.json
├── docker/
│   └── devcontainer/
│       └── Dockerfile
├── docs/
│   └── plans/
│       ├── 2026-02-25-devcontainer-design.md
│       └── 2026-02-25-devcontainer-impl.md
└── README.md
```
