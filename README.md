# Python devcontainer met uv

Een kant-en-klare ontwikkelomgeving voor Python-projecten met [uv](https://github.com/astral-sh/uv) als package manager. Inclusief Claude Code CLI en CEDA org-skills.

## Vereisten

**Docker is verplicht** — zonder Docker werkt geen van onderstaande methoden.

- **Windows / macOS**: installeer [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux**: installeer [Docker Engine](https://docs.docker.com/engine/install/)

## Opstarten

### VS Code

1. Installeer de extensie **Dev Containers** (`ms-vscode-remote.remote-containers`)
2. Clone de repo en open de map:
   ```bash
   git clone https://github.com/cedanl/python-uv-devcontainer
   code python-uv-devcontainer
   ```
3. Klik op **"Reopen in Container"** rechtsonder, of `F1` → **Dev Containers: Reopen in Container**

### Positron

> **Vereiste instelling (experimenteel):** Ga naar Positron-instellingen → zoek op `Dev` → zet **DEV > Containers: Enable** aan. Zonder deze instelling werkt de devcontainer niet.

1. Installeer de extensie **Dev Containers** (`ms-vscode-remote.remote-containers`) via de Positron Extensions-zijbalk
2. Clone de repo en open de map:
   ```bash
   git clone https://github.com/cedanl/python-uv-devcontainer
   ```
3. Positron detecteert de `.devcontainer/devcontainer.json` automatisch en vraagt of je wilt heropenen in een container.

### DevPod

```bash
devpod up github.com/cedanl/python-uv-devcontainer
```

Of via de [DevPod UI](https://devpod.sh/): **Create Workspace** → voer de repository-URL in.

### Devcontainer CLI

```bash
npm install -g @devcontainers/cli
git clone https://github.com/cedanl/python-uv-devcontainer
devcontainer up --workspace-folder python-uv-devcontainer
```

## Credentials instellen

De container heeft drie credentials nodig: Anthropic Foundry API (voor Claude Code) en een GitHub token (voor `gh` CLI).

### Automatisch — via host shell config (aanbevolen)

Als deze variabelen al in je shell config staan (`.zshrc`, `.bashrc`, etc.), worden ze **automatisch doorgegeven** aan de container. Er is geen verdere setup nodig:

```bash
export ANTHROPIC_FOUNDRY_API_KEY=<jouw api key>
export ANTHROPIC_FOUNDRY_RESOURCE=<jouw resource naam>
export GITHUB_TOKEN=<jouw github token>
```

### Handmatig — via `.env` bestand (fallback)

Staan de variabelen niet in je shell config, dan kun je ze eenmalig invullen in een lokaal `.env` bestand:

**Stap 1** — Maak het secrets-bestand aan:
```bash
cp .devcontainer/.env.example .devcontainer/.env
```

**Stap 2** — Vul je credentials in in `.devcontainer/.env`:
```
ANTHROPIC_FOUNDRY_API_KEY=<jouw api key>
ANTHROPIC_FOUNDRY_RESOURCE=<jouw resource naam>
GITHUB_TOKEN=<jouw github token>
```

> Dit bestand staat in `.gitignore` en wordt nooit gecommit.

**Stap 3** — `F1` → **Dev Containers: Rebuild Container**

Na het herbouwen werkt `claude` en `gh` meteen.

### Bij eerste start

Als credentials nog niet beschikbaar zijn, start `onboard.sh` automatisch en vraagt om de Foundry credentials in te vullen. Je kunt dit ook handmatig opnieuw uitvoeren met:
```bash
onboard
```

## Claude Code extensie instellen

Installeer de **Claude** VS Code-extensie (`anthropic.claude-code`) en zet bewerkingen op automatisch accepteren:

`F1` → **Open User Settings (JSON)** → voeg toe:
```json
"chat.editing.autoAccept": true
```

Zonder deze instelling vraagt de extensie bij elke bestandswijziging om bevestiging.

> **Snelle fix voor VS Code:** Ga naar VS Code-instellingen → zoek op `Claude` → zet de toggle **"Allow dangerously skip permissions"** aan. Daarna treedt `defaultMode: bypassPermissions` in `.claude/settings.json` in werking en verschijnen er geen prompts meer.

## Persoonlijke instellingen via dotfiles

De container laadt automatisch gedeelde standaard-settings (formatter, linter, Claude Code). Wil je daar je eigen voorkeuren bovenop zetten — zoals shell aliases, git config of editor keybindings — dan kun je een dotfiles repo gebruiken.

**Eenmalig instellen in VS Code of Positron:**

`F1` → **Open User Settings (JSON)** → voeg toe:
```json
"dotfiles.repository": "https://github.com/<jouw-gebruikersnaam>/dotfiles"
```

Bij elke container start kloont de devcontainer jouw dotfiles repo automatisch en voert `install.sh` uit. Je beheert die repo zelf — het raakt deze repo niet.

> Nog geen dotfiles repo? GitHub heeft een [handleiding](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles) om er een aan te maken. De aanpak werkt ook buiten Codespaces in elke devcontainer.

## Wat zit er in de container?

| Tool | Beschrijving |
|------|-------------|
| `python` | Python 3.12 |
| `uv` | Snelle Python package manager |
| `claude` | Claude Code CLI |
| `gh` | GitHub CLI |
| `ruff` | Python formatter en linter |
| CEDA org-skills | Geladen vanuit `cedanl/.github` via `npx skills` |

## Problemen oplossen

| Probleem | Oplossing |
|----------|-----------|
| "Cannot connect to Docker daemon" | Zorg dat Docker draait |
| Container bouwt niet | Controleer je internetverbinding |
| `claude` geeft API-fout | Controleer `.devcontainer/.env` en rebuild |
| Skills niet geladen | `npx skills add cedanl/.github --skill '*' -a claude-code -y --copy -g` |
