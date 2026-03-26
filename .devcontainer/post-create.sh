#!/usr/bin/env bash
set -euo pipefail

echo "Starting post-create setup..."

# Install Python dependencies
uv sync

# Install org-wide Claude/OpenCode skills from cedanl/.github
npx --yes skills add cedanl/.github --skill '*' -a claude-code -a opencode -y --copy -g

# Source .env file on shell startup (fallback for secrets not set on host)
ENV_FILE="/workspaces/python-uv-devcontainer/.devcontainer/.env"
echo "[ -f \"$ENV_FILE\" ] && set -a && source \"$ENV_FILE\" && set +a" >> ~/.bashrc

# Run onboard credential check on first terminal open
ONBOARD_SCRIPT="/workspaces/python-uv-devcontainer/.devcontainer/onboard.sh"
echo "[[ ! -f ~/.claude/.onboarded ]] && bash \"$ONBOARD_SCRIPT\"" >> ~/.bashrc

echo "Post-create complete."
