# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=trixie

FROM mcr.microsoft.com/devcontainers/base:${DEBIAN_VERSION}

# Install build dependencies and tools needed by GitHub release scripts
RUN <<EOF
apt-get update
apt-get install -y build-essential xz-utils unzip curl
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

# Install GrepAI from GitHub releases
RUN <<EOF
set -e
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64) GREPAI_ARCH="amd64" ;;
    arm64) GREPAI_ARCH="arm64" ;;
    *) echo "Unsupported arch: $ARCH" && exit 1 ;;
esac

LATEST=$(curl -fsSL "https://api.github.com/repos/yoanbernabeu/grepai/releases/latest" | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
WORK_DIR=$(mktemp -d)
curl -fsSL "https://github.com/yoanbernabeu/grepai/releases/download/v${LATEST}/grepai_${LATEST}_linux_${GREPAI_ARCH}.tar.gz" \
    | tar -xz -C "$WORK_DIR"
mv "$WORK_DIR/grepai" /usr/local/bin/grepai 
chmod +x /usr/local/bin/grepai
rm -rf "$WORK_DIR"
EOF

# Install tree-sitter grammars (dart, go, php, python, typescript)
RUN <<EOF
set -e
GRAMMAR_DIR=/usr/local/share/tree-sitter/grammars
mkdir -p "$GRAMMAR_DIR"

git clone --depth 1 https://github.com/UserNobody14/tree-sitter-dart.git "$GRAMMAR_DIR/tree-sitter-dart"
git clone --depth 1 https://github.com/tree-sitter/tree-sitter-go.git "$GRAMMAR_DIR/tree-sitter-go"
git clone --depth 1 https://github.com/tree-sitter/tree-sitter-php.git "$GRAMMAR_DIR/tree-sitter-php"
git clone --depth 1 https://github.com/tree-sitter/tree-sitter-python.git "$GRAMMAR_DIR/tree-sitter-python"
git clone --depth 1 https://github.com/tree-sitter/tree-sitter-typescript.git "$GRAMMAR_DIR/tree-sitter-typescript"
EOF

# Configure tree-sitter for vscode user
RUN <<EOF
set -e
mkdir -p /home/vscode/.config/tree-sitter
cat > /home/vscode/.config/tree-sitter/config.json <<'CONFIG'
{
  "parser-directories": [
    "/usr/local/share/tree-sitter/grammars"
  ]
}
CONFIG
chown -R vscode:vscode /home/vscode/.config/tree-sitter
EOF

USER vscode
