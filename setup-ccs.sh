#!/bin/bash

echo "=== CCS Setup Script ==="
echo "This script will setup CCS with 4 models (GLM, Haiku, Sonnet, Opus)"
echo

# 1. Install CCS
echo "1. Installing CCS..."
git clone https://github.com/kaiitran/ccs.git ~/.ccs-tool
cd ~/.ccs-tool
npm install
npm link
echo "✓ CCS installed"

# 2. Create config directory
echo
echo "2. Creating config directory..."
mkdir -p ~/.ccs
cd ~/.ccs

# 3. Create config files
echo
echo "3. Creating config files..."

# Main config
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

echo "✓ Config files created"

# 4. Add bash functions to ~/.bashrc
echo
echo "4. Adding bash functions to ~/.bashrc..."

# Backup existing bashrc first
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)

# Add CCS functions
cat >> ~/.bashrc << 'EOF'

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

# API Keys (Update these!)
export ANTHROPIC_API_KEY="sk-ant-xxxxxx"
export ZAI_API_KEY="your_zai_key"
EOF

echo "✓ Bash functions added"

# 5. Reload bashrc
echo
echo "5. Reloading ~/.bashrc..."
source ~/.bashrc

# 6. Verification
echo
echo "6. Verification..."
echo "CCS version: $(ccs --version 2>/dev/null || echo 'Not found')"
echo "CCS location: $(which ccs 2>/dev/null || echo 'Not found')"

echo
echo "=== Setup Complete! ==="
echo
echo "Next steps:"
echo "1. Update your API keys:"
echo "   - nano ~/.ccs/glm.settings.json    # Update ZAI_API_KEY"
echo "   - nano ~/.ccs/sonnet.settings.json # Update ANTHROPIC_API_KEY"
echo
echo "2. Update environment variables in ~/.bashrc:"
echo "   - nano ~/.bashrc"
echo "   - Find ANTHROPIC_API_KEY and ZAI_API_KEY"
echo
echo "3. Test the setup:"
echo "   - source ~/.bashrc"
echo "   - ccs-list"
echo "   - glm -p \"Hello\""
echo
echo "API Key sources:"
echo "   - ZAI: https://open.bigmodel.cn/"
echo "   - Anthropic: https://console.anthropic.com/"