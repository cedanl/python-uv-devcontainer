#!/usr/bin/env bash
# onboard.sh — First-run credential check
# Runs automatically on first terminal open via ~/.bashrc

set -uo pipefail

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

_done()  { echo -e "  ${GREEN}✔${RESET}  $*"; }
_error() { echo -e "  ${RED}✖${RESET}  $*"; }
_info()  { echo -e "  ${CYAN}ℹ${RESET}  $*"; }

ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
SENTINEL="$HOME/.claude/.onboarded"

_vars_in_env() {
  [[ -n "${ANTHROPIC_FOUNDRY_API_KEY:-}" && -n "${ANTHROPIC_FOUNDRY_RESOURCE:-}" ]]
}

_env_file_filled() {
  [[ -f "$ENV_FILE" ]] \
    && grep -qE 'ANTHROPIC_FOUNDRY_API_KEY=.+' "$ENV_FILE" \
    && grep -qE 'ANTHROPIC_FOUNDRY_RESOURCE=.+' "$ENV_FILE"
}

_mark_done() {
  mkdir -p "$(dirname "$SENTINEL")"
  touch "$SENTINEL"
}

_write_codex_config() {
  if [[ -z "${AZURE_OPENAI_ENDPOINT:-}" ]]; then
    _error "AZURE_OPENAI_ENDPOINT niet gevonden — ~/.codex/config.toml niet aangemaakt"
    return
  fi
  # AZURE_OPENAI_ENDPOINT = volledige URL, bijv. https://resource.cognitiveservices.azure.com/
  # Codex vereist /openai/v1 als pad — dit verschilt van ANTHROPIC_FOUNDRY_RESOURCE
  # (dat alleen de resourcenaam is, zonder URL of pad).
  local CODEX_TEMPLATE
  CODEX_TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/codex-config.toml.template"
  mkdir -p ~/.codex
  export AZURE_OPENAI_BASE_URL="${AZURE_OPENAI_ENDPOINT%/}/openai/v1"
  envsubst '$AZURE_OPENAI_BASE_URL' < "$CODEX_TEMPLATE" > ~/.codex/config.toml
  _done "Codex config bijgewerkt  — ~/.codex/config.toml"
}

main() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${CYAN}║         Claude — credential check            ║${RESET}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${RESET}"
  echo ""

  if _vars_in_env; then
    _done "ANTHROPIC_FOUNDRY_API_KEY  — gevonden"
    _done "ANTHROPIC_FOUNDRY_RESOURCE — gevonden"
    _write_codex_config
    echo ""
    _info "Claude is klaar voor gebruik."
    _mark_done
    echo ""
    return 0
  fi

  _error "ANTHROPIC_FOUNDRY_API_KEY  — niet gevonden"
  _error "ANTHROPIC_FOUNDRY_RESOURCE — niet gevonden"
  echo ""

  if _env_file_filled; then
    _info "Waarden gevonden in .devcontainer/.env — sourcen..."
    set -a && source "$ENV_FILE" && set +a
    _done "Vars geladen voor deze sessie."
    _write_codex_config
    echo ""
    _info "CLI:       je bent klaar, open een nieuwe terminal."
    _info "Extension: rebuild je devcontainer."
    _info "  ${DIM}Ctrl+Shift+P → Dev Containers: Rebuild Container${RESET}"
    _mark_done
    echo ""
    return 0
  fi

  _info "Vul je Foundry credentials in. Worden opgeslagen in .devcontainer/.env"
  echo ""

  read -r -p "$(echo -e "  ${YELLOW}?${RESET}  ANTHROPIC_FOUNDRY_API_KEY:  ")" api_key
  read -r -p "$(echo -e "  ${YELLOW}?${RESET}  ANTHROPIC_FOUNDRY_RESOURCE: ")" resource
  echo ""

  if [[ -z "$api_key" || -z "$resource" ]]; then
    _error "Lege waarde — .env niet bijgewerkt. Run 'onboard' opnieuw."
    echo ""
    return 1
  fi

  printf 'ANTHROPIC_FOUNDRY_API_KEY=%s\nANTHROPIC_FOUNDRY_RESOURCE=%s\n' "$api_key" "$resource" > "$ENV_FILE"

  set -a && source "$ENV_FILE" && set +a
  _done "Credentials opgeslagen in .devcontainer/.env"
  _write_codex_config
  echo ""
  _info "CLI:       je bent klaar."
  _info "Extension: rebuild je devcontainer."
  _info "  ${DIM}Ctrl+Shift+P → Dev Containers: Rebuild Container${RESET}"
  _mark_done
  echo ""
}

main "$@"
