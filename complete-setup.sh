#!/bin/bash

echo "=== COMPLETE SETUP SCRIPT ==="
echo "Setting up Claude Code + CCS with 4 models"
echo "========================================"
echo

# Check Node.js
echo "1. Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
else
    echo "✅ Node.js $(node --version) found"
fi

# Check Git
echo
echo "2. Checking Git..."
if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Installing Git..."
    apt-get update && apt-get install -y git
else
    echo "✅ Git $(git --version) found"
fi

# Install Claude Code CLI
echo
echo "3. Installing Claude Code CLI..."
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/install.sh | sh
    export PATH="$PATH:$HOME/.local/bin"
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
    echo "✅ Claude Code CLI installed"
else
    echo "✅ Claude Code CLI already installed: $(claude --version)"
fi

# Install CCS
echo
echo "4. Installing CCS..."
if ! command -v ccs &> /dev/null; then
    git clone https://github.com/kaiitran/ccs.git ~/.ccs-tool
    cd ~/.ccs-tool
    npm install
    npm link
    echo "✅ CCS installed"
else
    echo "✅ CCS already installed: $(ccs --version)"
fi

# Create config directory
echo
echo "5. Setting up configurations..."
mkdir -p ~/.ccs
mkdir -p ~/.claude
cd ~/.ccs

# Create CCS main config
echo "Creating CCS config..."
cat > config.json << 'EOF'
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

# Create CCS model settings
echo "Creating model settings..."

# GLM settings
cat > glm.settings.json << 'EOF'
{
  "api_key": "YOUR_ZAI_API_KEY",
  "base_url": "https://open.bigmodel.cn/api/paas/v4",
  "model": "glm-4-6",
  "max_tokens": 8192,
  "temperature": 0.7
}
EOF

# Haiku settings
cat > haiku.settings.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-3-5-haiku-20241022",
  "max_tokens": 8192,
  "temperature": 1.0
}
EOF

# Sonnet settings
cat > sonnet.settings.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 8192,
  "temperature": 1.0
}
EOF

# Opus settings
cat > opus.settings.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-opus-4-20250514",
  "max_tokens": 8192,
  "temperature": 1.0
}
EOF

# Create Claude config
echo "Creating Claude config..."
cd ~/.claude
cat > config.json << 'EOF'
{
  "api_key": "YOUR_ANTHROPIC_API_KEY",
  "model": "claude-sonnet-4-5-20250929",
  "max_tokens": 8192
}
EOF

# Add all functions to bashrc
echo
echo "6. Adding functions to ~/.bashrc..."
cat >> ~/.bashrc << 'EOF'

# ===== Claude & CCS Setup =====
export PATH="$PATH:$HOME/.local/bin"

# Claude Code CLI
alias claude='claude --model sonnet'

# CCS Functions
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

# Quick aliases
alias ask="claude -p"
alias chat="claude --model sonnet -p"
alias quick="haiku -p"

# API Keys (UPDATE THESE!)
export ANTHROPIC_API_KEY="sk-ant-xxxxxx"
export ZAI_API_KEY="your_zai_key"
EOF

echo "✅ Functions added to ~/.bashrc"

# Reload bashrc
echo
echo "7. Reloading configuration..."
source ~/.bashrc

# Create shortcuts
echo
echo "8. Creating shortcuts..."
cat > ~/ai-tools << 'EOF'
#!/bin/bash
echo "=== AI Tools Menu ==="
echo "1. Claude Code CLI: claude"
echo "2. CCS Models:"
echo "   - glm -p \"prompt\""
echo "   - haiku -p \"prompt\""
echo "   - sonnet -p \"prompt\""
echo "   - opus -p \"prompt\""
echo "3. Utilities:"
echo "   - ccs-list (list profiles)"
echo "   - ccs-switch [model] (switch default)"
echo "   - ask \"prompt\" (quick claude)"
echo "   - chat \"prompt\" (claude sonnet)"
echo "   - quick \"prompt\" (haiku)"
echo
echo "API Keys to update:"
echo "   ~/.claude/config.json"
echo "   ~/.ccs/*.settings.json"
echo "   ANTHROPIC_API_KEY in ~/.bashrc"
echo "   ZAI_API_KEY in ~/.bashrc"
EOF

chmod +x ~/ai-tools

# Verification
echo
echo "9. Verification..."
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Git: $(git --version)"
echo "Claude CLI: $(command -v claude && claude --version || echo 'Not found')"
echo "CCS: $(command -v ccs && ccs --version || echo 'Not found')"

echo
echo "🎉 SETUP COMPLETE! 🎉"
echo "==================="
echo
echo "⚠️  IMPORTANT: Update your API keys:"
echo
echo "1. Claude Code CLI:"
echo "   nano ~/.claude/config.json"
echo "   Replace YOUR_ANTHROPIC_API_KEY"
echo
echo "2. CCS GLM:"
echo "   nano ~/.ccs/glm.settings.json"
echo "   Replace YOUR_ZAI_API_KEY"
echo
echo "3. CCS Claude models:"
echo "   nano ~/.ccs/haiku.settings.json"
echo "   nano ~/.ccs/sonnet.settings.json"
echo "   nano ~/.ccs/opus.settings.json"
echo "   Replace YOUR_ANTHROPIC_API_KEY"
echo
echo "4. Environment variables:"
echo "   nano ~/.bashrc"
echo "   Find ANTHROPIC_API_KEY and ZAI_API_KEY"
echo
echo "5. Reload after updating:"
echo "   source ~/.bashrc"
echo
echo "✅ Testing commands:"
echo "   claude --version"
echo "   ccs-list"
echo "   haiku -p \"Hello\""
echo "   sonnet -p \"Test connection\""
echo
echo "📖 Help menu: ~/ai-tools"