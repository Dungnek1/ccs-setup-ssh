#!/bin/bash

echo "=== FIXED SETUP SCRIPT ==="
echo "Setting up Claude Code + CCS"
echo "==========================="
echo

# 1. Install Claude Code CLI
echo "1. Installing Claude Code CLI..."
HAS_CLAUDE=$(command -v claude)
if [ -z "$HAS_CLAUDE" ]; then
    echo "Claude not found, installing..."
    curl -fsSL https://claude.ai/install.sh | sh
    export PATH="$PATH:$HOME/.local/bin"
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
    echo "✅ Claude Code CLI installed"
else
    echo "✅ Claude Code CLI already found: $HAS_CLAUDE"
fi

# 2. Install CCS (fix repo URL)
echo
echo "2. Installing CCS..."
HAS_CCS=$(command -v ccs)
if [ -z "$HAS_CCS" ]; then
    echo "CCS not found, installing..."
    rm -rf ~/.ccs-tool
    git clone https://github.com/Dungnek1/ccs.git ~/.ccs-tool
    cd ~/.ccs-tool
    npm install
    npm link
    cd ~
    echo "✅ CCS installed"
else
    echo "✅ CCS already found: $HAS_CCS"
fi

# 3. Create directories
echo
echo "3. Creating directories..."
mkdir -p ~/.ccs
mkdir -p ~/.claude

# 4. Create CCS config
echo
echo "4. Creating CCS config..."
cat > ~/.ccs/config.json << 'EOF'
{
  "profiles": {
    "glm": {
      "model": "glm-4-6",
      "settingsFile": "~/.ccs/glm.settings.json",
      "systemPrompt": "You are GLM 4.6, an AI assistant optimized for quick tasks."
    },
    "haiku": {
      "model": "claude-3-5-haiku-20241022",
      "settingsFile": "~/.ccs/haiku.settings.json",
      "systemPrompt": "You are Claude Haiku, fast and efficient."
    },
    "sonnet": {
      "model": "claude-sonnet-4-5-20250929",
      "settingsFile": "~/.ccs/sonnet.settings.json",
      "systemPrompt": "You are Claude Sonnet, balanced and capable."
    },
    "opus": {
      "model": "claude-opus-4-20250514",
      "settingsFile": "~/.ccs/opus.settings.json",
      "systemPrompt": "You are Claude Opus, powerful and thorough."
    }
  },
  "defaultProfile": "sonnet"
}
EOF

# 5. Create model settings
echo "5. Creating model settings..."

# GLM
cat > ~/.ccs/glm.settings.json << 'EOF'
{
  "api_key": "YOUR_ZAI_API_KEY",
  "base_url": "https://open.bigmodel.cn/api/paas/v4",
  "model": "glm-4-6",
  "max_tokens": 8192,
  "temperature": 0.7
}
EOF

# Haiku
cat > ~/.ccs/haiku.settings.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-3-5-haiku-20241022",
  "max_tokens": 8192,
  "temperature": 1.0
}
EOF

# Sonnet
cat > ~/.ccs/sonnet.settings.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 8192,
  "temperature": 1.0
}
EOF

# Opus
cat > ~/.ccs/opus.settings.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-opus-4-20250514",
  "max_tokens": 8192,
  "temperature": 1.0
}
EOF

# 6. Create Claude config
echo "6. Creating Claude config..."
cat > ~/.claude/config.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 8192
}
EOF

# 7. Add functions to bashrc
echo
echo "7. Adding functions to ~/.bashrc..."
cat >> ~/.bashrc << 'EOF'

# Claude & CCS Functions
export PATH="$PATH:$HOME/.local/bin"

ccs() {
    local profile="${1:-sonnet}"
    shift
    command ccs "$profile" "$@"
}

glm() { ccs glm "$@"; }
haiku() { ccs haiku "$@"; }
sonnet() { ccs sonnet "$@"; }
opus() { ccs opus "$@"; }

ccs-switch() {
    local model="$1"
    [ -z "$model" ] && { echo "Usage: ccs-switch [glm|haiku|sonnet|opus]"; return 1; }
    sed -i "s/\"defaultProfile\": \".*\"/\"defaultProfile\": \"$model\"/" ~/.ccs/config.json
    echo "✓ Switched to: $model"
}

ccs-list() {
    echo "=== CCS Profiles ==="
    echo "glm, haiku, sonnet, opus"
    echo "Default: $(grep defaultProfile ~/.ccs/config.json | cut -d'"' -f4)"
}

# API Keys - UPDATE THESE!
export ANTHROPIC_API_KEY="sk-ant-xxxxxx"
export ZAI_API_KEY="your_zai_key"
EOF

# 8. Reload bashrc
echo
echo "8. Reloading ~/.bashrc..."
source ~/.bashrc

# 9. Test
echo
echo "9. Testing..."
HAS_CLAUDE=$(command -v claude)
HAS_CCS=$(command -v ccs)

if [ -n "$HAS_CLAUDE" ]; then
    echo "✅ Claude CLI: $HAS_CLAUDE"
else
    echo "❌ Claude CLI not found"
fi

if [ -n "$HAS_CCS" ]; then
    echo "✅ CCS: $HAS_CCS"
else
    echo "❌ CCS not found"
fi

echo
echo "🎉 SETUP COMPLETE!"
echo "=================="
echo
echo "⚠️ UPDATE API KEYS:"
echo "1. nano ~/.claude/config.json"
echo "2. nano ~/.ccs/glm.settings.json"
echo "3. nano ~/.ccs/haiku.settings.json"
echo "4. nano ~/.ccs/sonnet.settings.json"
echo "5. nano ~/.ccs/opus.settings.json"
echo "6. nano ~/.bashrc (find ANTHROPIC_API_KEY and ZAI_API_KEY)"
echo
echo "Then run: source ~/.bashrc"
echo
echo "Test with:"
echo "- claude --version"
echo "- ccs-list"
echo "- haiku -p \"test\""