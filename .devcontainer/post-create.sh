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

# Codex config — gegenereerd via envsubst uit template; auto-refresh bij elke nieuwe terminal
mkdir -p ~/.codex
CODEX_TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/codex-config.toml.template"
echo "[ -n \"\$AZURE_OPENAI_ENDPOINT\" ] && export AZURE_OPENAI_BASE_URL=\"\${AZURE_OPENAI_ENDPOINT%/}/openai/v1\" && envsubst '\$AZURE_OPENAI_BASE_URL' < \"$CODEX_TEMPLATE\" > ~/.codex/config.toml" >> ~/.bashrc

# Global Claude Code instructies — geldt voor alle repo's in deze container
mkdir -p ~/.claude
cat > ~/.claude/CLAUDE.md << 'EOF'
## Codex delegatie (token-besparing)

De Codex CLI is beschikbaar in deze container. Delegeer zware codetaken proactief aan Codex om Claude-tokens te besparen: een Codex-aanroep kost Claude ~200 tokens ongeacht de grootte van de taak.

### Wanneer delegeren aan Codex

Delegeer **altijd** aan Codex (zonder expliciet te vragen) bij:

- Analyse van een codebase of meerdere bestanden tegelijk
- Refactoring van meer dan ~50 regels code
- Repetitieve code-transformaties (hernoemen, patronen toepassen)
- Taken waarbij je zelf meer dan ~1000 tokens zou verbruiken aan redeneren + output

Doe het **zelf** (zonder Codex) bij:

- Kleine fixes (< 20 regels, 1-2 bestanden)
- Vragen over code uitleg of architectuur
- Git-operaties, shell-commando's, configuratiewijzigingen

### Hoe delegeren

Gebruik de Codex skill (`/codex`). De deployment in deze omgeving is `gpt-5.2` op Azure.

De sandbox is geconfigureerd via `~/.codex/config.toml` (`approval_policy = "never"`, `sandbox_mode = "danger-full-access"`). Geen extra flags nodig — werkt zowel in CLI als VS Code extension.
EOF

# Pi (coding agent) — installeer Willma extension
mkdir -p ~/.pi/agent/extensions
cp "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/willma-extension.ts" ~/.pi/agent/extensions/willma.ts

# Source .env file on shell startup (fallback for secrets not set on host)
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
echo "[ -f \"$ENV_FILE\" ] && set -a && source \"$ENV_FILE\" && set +a" >> ~/.bashrc

# onboard alias for manual re-runs
ONBOARD_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/onboard.sh"
echo "alias onboard='bash $ONBOARD_SCRIPT'" >> ~/.bashrc

echo "Post-create complete."
