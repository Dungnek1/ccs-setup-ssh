#!/bin/bash

echo "=== CLAUDE CLI BINARY INSTALLATION ==="
echo "Downloading and installing Claude CLI binary"
echo "=========================================="
echo

# Create bin directory
mkdir -p ~/bin
cd ~/bin

# Detect architecture
ARCH=$(uname -m)
echo "Architecture: $ARCH"

# Download appropriate binary
echo "Downloading Claude CLI..."
if [[ "$ARCH" == "x86_64" ]]; then
    echo "Downloading for x86_64..."
    curl -L -o claude "https://github.com/anthropics/claude-cli/releases/latest/download/claude-linux-x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
    echo "Downloading for aarch64..."
    curl -L -o claude "https://github.com/anthropics/claude-cli/releases/latest/download/claude-linux-aarch64"
else
    echo "❌ Unsupported architecture: $ARCH"
    echo "Trying alternative method..."
    # Try downloading from alternative source
    wget -O claude "https://cdn.claude.ai/cli/latest/linux-x64"
fi

# Check if download succeeded
if [ ! -f claude ]; then
    echo "❌ Download failed. Trying alternative..."
    # Alternative download URL
    curl -o claude "https://storage.googleapis.com/claude-cli-releases/latest/claude-linux-x86_64"
fi

if [ ! -f claude ]; then
    echo "❌ All download methods failed"
    exit 1
fi

# Make executable
echo "Making executable..."
chmod +x claude

# Add to PATH
echo "Adding to PATH..."
echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc
export PATH="$PATH:$HOME/bin"

# Test
echo
echo "Testing installation..."
./claude --version

if command -v claude &> /dev/null; then
    echo "✅ Claude CLI installed successfully!"
    echo "Location: $(which claude)"
    echo "Version: $(claude --version)"
else
    echo "❌ Installation failed"
    exit 1
fi

# Create config
echo
echo "Creating config..."
mkdir -p ~/.claude
cat > ~/.claude/config.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 8192
}
EOF

echo "✅ Config created at ~/.claude/config.json"

echo
echo "🎉 Installation complete!"
echo
echo "⚠️ IMPORTANT: Update your API key:"
echo "nano ~/.claude/config.json"
echo "Replace YOUR_ANTHROPIC_API_KEY with your actual key"
echo
echo "Then test with:"
echo "claude --version"
echo "claude -p \"Hello\""