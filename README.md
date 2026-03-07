# devcontAIner

Reusable devcontainer template for AI-assisted development with Claude Code and Gemini CLI.

## Architecture

Hybrid approach: standard runtimes and tools are declared as **Dev Container Features** (applied after image build), while bespoke tooling is installed in the **Dockerfile** (cached as Docker layers).

```
devcontainer.json (Features)     Dockerfile (custom tooling)
├── Node.js 25 + pnpm           ├── build-essential, shellcheck (apt)
├── Python                      ├── xz-utils, unzip, curl (apt)
├── Bun                         ├── fd, tree (apt)
├── gh CLI                      ├── ast-grep (GitHub release)
├── Claude Code                 └── git-delta (GitHub release)
├── Gemini CLI
├── Playwright + Chromium
├── ripgrep
├── bat
├── fzf
├── jq-likes (jq, yq, xq)
├── eza
├── uv/uvx
├── GrepAI
├── RTK
└── Docker-outside-of-Docker
```

## What's included

### Dev Container Features (declarative, in devcontainer.json)

| Feature | GHCR ID |
|---------|---------|
| Docker-outside-of-Docker | `ghcr.io/devcontainers/features/docker-outside-of-docker:1` |
| Node.js 25 + pnpm | `ghcr.io/devcontainers/features/node:1` |
| GitHub CLI | `ghcr.io/devcontainers/features/github-cli:1` |
| Python | `ghcr.io/devcontainers/features/python:1` |
| Bun | `ghcr.io/devcontainers-extra/features/bun:1` |
| Claude Code | `ghcr.io/stu-bell/devcontainer-features/claude-code:0` |
| Gemini CLI | `ghcr.io/stu-bell/devcontainer-features/gemini-cli:0` |
| Playwright + Chromium | `ghcr.io/schlich/devcontainer-features/playwright:0` |
| ripgrep | `ghcr.io/jungaretti/features/ripgrep:1` |
| bat | `ghcr.io/jsburckhardt/devcontainer-features/bat:1` |
| uv/uvx | `ghcr.io/jsburckhardt/devcontainer-features/uv:1` |
| fzf | `ghcr.io/devcontainers-extra/features/fzf:1` |
| jq-likes (jq, yq, xq) | `ghcr.io/eitsupi/devcontainer-features/jq-likes:2` |
| eza | `ghcr.io/devcontainers-extra/features/eza:1` |
| GrepAI | `ghcr.io/awf-project/devcontainer-features/grepai:1` |
| RTK | `ghcr.io/awf-project/devcontainer-features/rtk:1` |

### Dockerfile (custom tooling, cached as Docker layers)

| Tool | Binary | Install method | Purpose |
|------|--------|----------------|---------|
| fd-find | `fd` | apt | Fast file finder |
| tree | `tree` | apt | Directory structure viewer |
| ast-grep | `sg` | GitHub release | AST-based code search |
| git-delta | `delta` | GitHub release | Enhanced git diffs |
| build-essential | — | apt | Compilation toolchain |
| shellcheck | `shellcheck` | apt | Shell script linter |
| xz-utils, unzip, curl | — | apt | Archive extraction and downloads |

### Lifecycle commands

All hooks are delegated to `run-lifecycle.sh`, which executes a versioned base script and then an optional personal overlay (`.local.sh`, gitignored).

```
docker/devcontainer/
├── Dockerfile
├── run-lifecycle.sh          # hook runner (base + local overlay)
├── lifecycle/
│   ├── on-create.sh          # gitconfig seed from host mount
│   ├── post-create.sh        # version checks, RTK + Claude setup
│   └── post-start.sh         # JetBrains XDG symlinks
└── scripts/
    ├── claude/
    │   ├── setup.sh           # Claude post-create configuration
    │   └── statusline.sh      # Claude statusline helper
    └── rtk/
        └── setup.sh           # RTK post-create configuration
```

| Phase | Base script | Runs |
|-------|-------------|------|
| `onCreateCommand` | `lifecycle/on-create.sh` | Once at container creation |
| `postCreateCommand` | `lifecycle/post-create.sh` | After create and rebuilds |
| `postStartCommand` | `lifecycle/post-start.sh` | Every container start |

#### Customizing lifecycle hooks

Create a `.local.sh` file next to the base script to extend it without touching versioned files:

```bash
# Example: add personal git config after on-create base
cat > docker/devcontainer/lifecycle/on-create.local.sh << 'EOF'
#!/bin/bash
git config --global alias.co checkout
EOF
chmod +x docker/devcontainer/lifecycle/on-create.local.sh
```

The `.local.sh` files are gitignored — they will never be committed accidentally.

### Bind mounts (host -> container)

| Host path | Container path | Purpose |
|-----------|----------------|---------|
| `~/.claude.json` | `/home/vscode/.claude.json` | Claude Code authentication |
| `~/.claude/.credentials.json` | `/home/vscode/.claude/.credentials.json` | Claude Code credentials |
| `~/.gemini` | `/home/vscode/.gemini` | Gemini CLI config and auth |
| `~/.gitconfig` | `/home/vscode/.gitconfig.host` | Git configuration (seeded into container on create) |
| `~/.ssh` | `/home/vscode/.ssh` | SSH keys |

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

- `~/.claude.json` and `~/.claude/.credentials.json` are bind-mounted for authentication
- `~/.gemini` is bind-mounted read/write: config and auth are shared with the host
- `~/.gitconfig` is mounted as `.gitconfig.host` and copied into the container on create to avoid bind-mount conflicts
- SSH keys are bind-mounted directly from the host
- Agent tools from GitHub releases (ast-grep, delta) are fetched at latest version during build; may hit GitHub API rate limits without auth
- Features are applied after the Dockerfile build; the Dockerfile cannot use tools installed by Features
- Community Features (v0.x) may break; fallback is to move the install back into the Dockerfile
