#!/bin/bash

echo "=== CLAUDE CLI INSTALLATION ==="
echo "Installing Claude Code CLI only"
echo "==============================="
echo

# Method 1: Try npm global install
echo "Method 1: Installing via npm..."
if command -v npm &> /dev/null; then
    npm install -g @anthropic-ai/claude-cli
    if command -v claude &> /dev/null; then
        echo "✅ Claude CLI installed via npm"
        echo "Version: $(claude --version)"
        exit 0
    fi
fi

# Method 2: Try downloading binary directly
echo
echo "Method 2: Downloading binary directly..."
mkdir -p ~/bin
cd ~/bin

# Detect architecture
ARCH=$(uname -m)
OS=$(uname -s)

if [[ "$OS" == "Linux" ]]; then
    if [[ "$ARCH" == "x86_64" ]]; then
        curl -L -o claude "https://github.com/anthropics/claude-cli/releases/latest/download/claude-linux-x86_64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        curl -L -o claude "https://github.com/anthropics/claude-cli/releases/latest/download/claude-linux-aarch64"
    else
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
    fi
else
    echo "❌ Unsupported OS: $OS"
    exit 1
fi

chmod +x claude

# Add to PATH
echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc
export PATH="$PATH:$HOME/bin"

if command -v claude &> /dev/null; then
    echo "✅ Claude CLI installed via binary"
    echo "Version: $(claude --version)"
else
    echo "❌ Failed to install Claude CLI"
    exit 1
fi

echo
echo "Creating config directory..."
mkdir -p ~/.claude

echo
echo "Creating config file..."
cat > ~/.claude/config.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 8192
}
EOF

echo "✅ Config created at ~/.claude/config.json"

echo
echo "🎉 Claude CLI installation complete!"
echo
echo "⚠️ UPDATE YOUR API KEY:"
echo "nano ~/.claude/config.json"
echo "Replace YOUR_ANTHROPIC_API_KEY with your actual key"
echo
echo "Then test with:"
echo "claude --version"
echo "claude -p \"Hello\""