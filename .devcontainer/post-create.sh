#!/usr/bin/env bash
set -euo pipefail

echo "Starting post-create setup..."

# Install Python dependencies
uv sync

# Install org-wide Claude/OpenCode skills from cedanl/.github
npx --yes skills add cedanl/.github --skill '*' -a claude-code -a opencode -y --copy -g

# Install skill-codex (delegates work from Claude to Codex CLI)
git clone --depth 1 https://github.com/skills-directory/skill-codex.git /tmp/skill-codex \
  && mkdir -p ~/.claude/skills \
  && cp -r /tmp/skill-codex/plugins/skill-codex/skills/codex ~/.claude/skills/codex \
  && rm -rf /tmp/skill-codex

# Configure Codex CLI defaults (Azure deployment name as default model)
mkdir -p ~/.codex
cat > ~/.codex/config.toml << 'EOF'
model = "gpt-5.2"
EOF

# Source .env file on shell startup (fallback for secrets not set on host)
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
echo "[ -f \"$ENV_FILE\" ] && set -a && source \"$ENV_FILE\" && set +a" >> ~/.bashrc

# onboard alias for manual re-runs
ONBOARD_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/onboard.sh"
echo "alias onboard='bash $ONBOARD_SCRIPT'" >> ~/.bashrc

echo "Post-create complete."
