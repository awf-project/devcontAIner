# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=trixie

FROM mcr.microsoft.com/devcontainers/base:${DEBIAN_VERSION}

# Install build dependencies and tools needed by GitHub release scripts
RUN <<EOF
apt-get update
apt-get install -y build-essential xz-utils unzip curl shellcheck
rm -rf /var/lib/apt/lists/*
EOF

# Install agent tools via apt (fd, tree — no Feature available)
RUN <<EOF
apt-get update
apt-get install -y fd-find tree
ln -s /usr/bin/fdfind /usr/local/bin/fd
rm -rf /var/lib/apt/lists/*
EOF

# Install ast-grep (sg), git-delta from GitHub releases
RUN <<EOF
set -e
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64) TRIPLE="x86_64-unknown-linux-gnu" ;;
    arm64) TRIPLE="aarch64-unknown-linux-gnu" ;;
    *) echo "Unsupported arch: $ARCH" && exit 1 ;;
esac

# ast-grep (sg) - AST-based code search
LATEST=$(curl -fsSL "https://api.github.com/repos/ast-grep/ast-grep/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
WORK_DIR=$(mktemp -d)
curl -fsSL "https://github.com/ast-grep/ast-grep/releases/download/${LATEST}/app-${TRIPLE}.zip" \
    -o "$WORK_DIR/ast-grep.zip"
unzip -o "$WORK_DIR/ast-grep.zip" -d /usr/local/bin
rm -rf "$WORK_DIR"

# git-delta - enhanced git diffs
LATEST=$(curl -fsSL "https://api.github.com/repos/dandavison/delta/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
WORK_DIR=$(mktemp -d)
curl -fsSL "https://github.com/dandavison/delta/releases/download/${LATEST}/delta-${LATEST}-${TRIPLE}.tar.gz" \
    | tar -xz -C "$WORK_DIR"
mv "$WORK_DIR/delta-${LATEST}-${TRIPLE}/delta" /usr/local/bin/delta
rm -rf "$WORK_DIR"

chmod +x /usr/local/bin/sg /usr/local/bin/delta
EOF

USER vscode
