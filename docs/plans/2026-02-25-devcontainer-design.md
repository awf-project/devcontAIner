# devcontAIner — Design Document

**Date**: 2026-02-25
**Status**: Approved

## Problem

Claude Code and Gemini CLI configuration (CLAUDE.md, plugins, hooks, sessions, credentials) is shared across
multiple projects on the host. Each project needs an isolated development environment while
reusing the same AI CLI setup without duplication.

## Goal

A reusable devcontainer template (Dockerfile + devcontainer.json) that can be copied into any
project. Provides Claude Code and Gemini CLI inside the container with the host `~/.claude` and
`~/.gemini` bind-mounted read/write. Includes agent optimization tools for fast search, navigation,
and browser automation.

## Decision: Hybrid Features + Dockerfile

### Approach B — Custom Dockerfile + devcontainer.json (initial)

**Why not A (pure devcontainer.json):** Claude Code reinstalled on every `Rebuild Container`,
~1-2 min penalty each time.

**Why not C (published image):** Requires a registry and CI pipeline. Over-engineered for
personal use.

**Chosen:** Custom Dockerfile gives pinnable CLI versions and fast container start.
The `devcontainer.json` adds bind mounts and features at runtime.

### Evolution: Features-first architecture (current)

The initial Dockerfile (~170 lines) manually installed standard runtimes (Node.js, gh CLI, Python,
Bun, Playwright, Claude Code, Gemini CLI) that exist as Dev Container Features. This was migrated
to a hybrid approach:

- **Features** (declarative, in devcontainer.json): standard runtimes and tools with official or
  community Features — Node.js, Python, Bun, gh CLI, Claude Code, Gemini CLI, Playwright,
  ripgrep, bat, uv/uvx, Docker-outside-of-Docker
- **Dockerfile** (imperative, cached as Docker layers): bespoke tooling without Features —
  ast-grep, git-delta, eza, GrepAI, tree-sitter grammars, fd, tree, fzf, build dependencies

**Why:** Reduces Dockerfile from ~170 to ~88 lines (-48%), delegates runtime management to
community-maintained Features, improves readability by separating declarative from imperative.

**Trade-off:** Depends on 4 community Features (v0.x) — Claude Code, Gemini CLI, Playwright, bat.
If one breaks, fallback is to move the install back into the Dockerfile.

## Architecture

```
devcontAIner/
├── .devcontainer/
│   └── devcontainer.json        # Features + bind mounts + lifecycle commands
├── docker/
│   └── devcontainer/
│       └── Dockerfile           # Custom tooling only (no runtimes)
├── docs/
│   └── plans/
└── README.md
```

### Build order

1. `docker build` — Dockerfile produces base image with custom tooling
2. Features — applied as additional Docker layers (Node.js, Python, etc.)
3. `onCreateCommand` — one-time setup needing Feature tools (tree-sitter-cli via npm)
4. `postCreateCommand` — version checks for all tools

### Usage in a target project

Copy the template files:
```bash
cp -r ~/Sites/pocky/devcontAIner/.devcontainer .devcontainer
cp -r ~/Sites/pocky/devcontAIner/docker .
```

Then open the project folder in VS Code and select "Reopen in Container".

## Components

### Dockerfile (`docker/devcontainer/Dockerfile`)

- Base: `mcr.microsoft.com/devcontainers/base:bookworm` (Debian 12, user `vscode` pre-configured)
- Build deps: `build-essential`, `xz-utils`, `unzip`, `curl`, `jq`
- Agent tools (apt): `fd-find`, `tree`, `fzf`
- Agent tools (GitHub releases): `ast-grep` (sg), `git-delta`, `eza`
- AI tooling (GitHub release): GrepAI
- Tree-sitter grammars: dart, go, php, python, typescript (git clone)
- Tree-sitter config for vscode user
- Multi-arch support: amd64 and arm64 for GitHub release binaries
- Final user: `vscode` (non-root)

### devcontainer.json (`.devcontainer/devcontainer.json`)

- `build.dockerfile`: points to `../docker/devcontainer/Dockerfile`
- `features` (11): Docker-outside-of-Docker, Node.js 22, gh CLI, Python, Bun, Claude Code,
  Gemini CLI, Playwright, ripgrep, bat, uv/uvx
- `mounts`:
  - `${localEnv:HOME}/.claude` -> `/home/vscode/.claude` (Claude Code config, credentials, plugins)
  - `${localEnv:HOME}/.claude.json` -> `/home/vscode/.claude.json` (Claude Code authentication)
  - `${localEnv:HOME}/.claude-mem` -> `/home/vscode/.claude-mem` (Claude memory database)
  - `${localEnv:HOME}/.gemini` -> `/home/vscode/.gemini` (Gemini CLI config, auth)
  - `${localEnv:HOME}/.gitconfig` -> `/home/vscode/.gitconfig` (git settings)
  - `${localEnv:HOME}/.ssh` -> `/home/vscode/.ssh` (SSH keys)
  - `${localEnv:HOME}/.1password/agent.sock` -> socket mount (SSH agent forwarding)
- `remoteUser`: `vscode`
- `remoteEnv`: `SSH_AUTH_SOCK` set to 1Password agent socket, `OLLAMA_HOST` for local AI
- VS Code extensions: Claude Code, Markdown Mermaid, Docker, Markdown Preview Enhanced
- `onCreateCommand`: installs tree-sitter-cli (needs Node.js from Feature)
- `postCreateCommand`: version checks for all tools

## Trade-offs

| Choice | Cost |
|--------|------|
| Bind mount read/write | Container changes ~/.claude and ~/.gemini affect the host — desired behavior |
| Features for runtimes | Depends on community Features (some v0.x); fallback to Dockerfile if broken |
| GitHub API calls at build time | Fetches latest tool versions; may hit rate limits without auth |
| Playwright via Feature | Delegates browser install to community Feature; less control over browser selection |
| No language stack in base image | Each project adds via devcontainer Features — keeps base lean |
| 1Password socket mount | Couples to 1Password; remove mount if using different SSH agent |
| tree-sitter-cli in onCreateCommand | Not cached as Docker layer; ~3s install on each container creation |

## Out of Scope

- Language runtimes (PHP, Go, Rust) — added per-project via devcontainer Features
- Published registry image (ghcr.io) — deferred until multiple teams share the template
- Firefox/WebKit browsers — only Chromium included; add if needed
