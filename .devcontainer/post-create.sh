#!/usr/bin/env bash
set -euo pipefail

echo "Starting post-create setup..."

# Install Python dependencies
uv sync

# Install org-wide Claude/OpenCode skills from cedanl/.github
npx --yes skills add cedanl/.github --skill '*' -a claude-code -a opencode -a pi -y --copy -g

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

# context-mode — MCP + hooks voor Claude Code, Codex en Pi
CM_ROOT=$(node -e "console.log(require.resolve('context-mode/package.json').replace('/package.json',''))" 2>/dev/null || true)
if [[ -n "$CM_ROOT" ]]; then
  # Claude Code: MCP server + hooks via settings.json
  python3 - <<PYEOF
import json, os

settings_path = os.path.expanduser('~/.claude/settings.json')
cm_root = "$CM_ROOT"

settings = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)

settings.setdefault('mcpServers', {})['context-mode'] = {'command': 'context-mode', 'args': []}

hooks = settings.setdefault('hooks', {})

def add_hook(event, matcher, cmd):
    entries = hooks.setdefault(event, [])
    if not any('context-mode' in str(e) and e.get('matcher', '') == matcher for e in entries):
        entries.append({'matcher': matcher, 'hooks': [{'type': 'command', 'command': cmd}]})

add_hook('PostToolUse',
    'Bash|Read|Write|Edit|NotebookEdit|Glob|Grep|TodoWrite|TaskCreate|TaskUpdate|EnterPlanMode|ExitPlanMode|Skill|Agent|AskUserQuestion|EnterWorktree|mcp__',
    f'node "{cm_root}/hooks/posttooluse.mjs"')
add_hook('PreCompact', '', f'node "{cm_root}/hooks/precompact.mjs"')
for matcher in ['Bash', 'WebFetch', 'Read', 'Grep']:
    add_hook('PreToolUse', matcher, f'node "{cm_root}/hooks/pretooluse.mjs"')
add_hook('UserPromptSubmit', '', f'node "{cm_root}/hooks/userpromptsubmit.mjs"')
add_hook('SessionStart', '', f'node "{cm_root}/hooks/sessionstart.mjs"')

os.makedirs(os.path.dirname(settings_path), exist_ok=True)
with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
print('  ✔ Claude Code: context-mode MCP + hooks geconfigureerd')
PYEOF

  # Pi: symlink zodat relatieve import in index.ts naar CM_ROOT/build/ verwijst
  mkdir -p ~/.pi/agent/extensions
  ln -sf "${CM_ROOT}/.pi/extensions/context-mode" ~/.pi/agent/extensions/context-mode
  echo "  ✔ Pi: context-mode extension geïnstalleerd"

  # Codex: hooks
  cp "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/context-mode-codex-hooks.json" ~/.codex/hooks.json
  echo "  ✔ Codex: context-mode hooks geconfigureerd"
fi

# Gebruiker-specifieke configuratie (optioneel)
# Stel USER_CONFIG_REPO in in .devcontainer/.env — zie .env.example voor de repo-structuur.
if [[ -n "${USER_CONFIG_REPO:-}" ]]; then
  REPO_URL="${USER_CONFIG_REPO}"
  [[ "$REPO_URL" != https://* ]] && REPO_URL="https://github.com/${REPO_URL}"
  echo "Gebruikersconfig toepassen van ${REPO_URL}..."

  if git clone --depth 1 "$REPO_URL" /tmp/user-config 2>/dev/null; then
    # CLAUDE.md — toegevoegd aan globale Claude instructies
    if [[ -f /tmp/user-config/CLAUDE.md ]]; then
      echo "" >> ~/.claude/CLAUDE.md
      cat /tmp/user-config/CLAUDE.md >> ~/.claude/CLAUDE.md
      echo "  ✔ CLAUDE.md toegevoegd"
    fi

    # Claude skills
    if [[ -d /tmp/user-config/skills ]]; then
      mkdir -p ~/.claude/skills
      cp -r /tmp/user-config/skills/. ~/.claude/skills/
      echo "  ✔ Claude skills gekopieerd"
    fi

    # Pi extensions
    if [[ -d /tmp/user-config/pi-extensions ]]; then
      mkdir -p ~/.pi/agent/extensions
      cp -r /tmp/user-config/pi-extensions/. ~/.pi/agent/extensions/
      echo "  ✔ Pi extensions gekopieerd"
    fi

    # Eigen post-create script — draait als laatste
    if [[ -f /tmp/user-config/post-create.sh ]]; then
      bash /tmp/user-config/post-create.sh \
        && echo "  ✔ Eigen post-create.sh uitgevoerd" \
        || echo "  ✖ Eigen post-create.sh mislukt — container gaat door"
    fi

    rm -rf /tmp/user-config
  else
    echo "  ✖ Kon USER_CONFIG_REPO niet clonen: ${REPO_URL} — overgeslagen"
  fi
fi

# Source .env file on shell startup (fallback for secrets not set on host)
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
echo "[ -f \"$ENV_FILE\" ] && set -a && source \"$ENV_FILE\" && set +a" >> ~/.bashrc

# onboard alias for manual re-runs
ONBOARD_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/onboard.sh"
echo "alias onboard='bash $ONBOARD_SCRIPT'" >> ~/.bashrc

echo "Post-create complete."
