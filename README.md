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

Clone de repo en open de map in Positron. Positron detecteert de `.devcontainer/devcontainer.json` automatisch en vraagt of je wilt heropenen in een container.

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

## Claude Code instellen

Claude Code is vooraf geïnstalleerd, maar heeft twee credentials nodig voor de CEDA Foundry API.

**Stap 1** — Maak het secrets-bestand aan:
```bash
cp .devcontainer/.env.example .devcontainer/.env
```

**Stap 2** — Vul je credentials in in `.devcontainer/.env`:
```
ANTHROPIC_FOUNDRY_API_KEY=<jouw api key>
ANTHROPIC_FOUNDRY_RESOURCE=<jouw resource naam>
```

> Dit bestand staat in `.gitignore` en wordt nooit gecommit.

**Stap 3** — `F1` → **Dev Containers: Rebuild Container**

Na het herbouwen werkt `claude` meteen.

**Stap 4** — Installeer de **Claude** VS Code-extensie (`anthropic.claude-code`) en zet bewerkingen op automatisch accepteren:

`F1` → **Open User Settings (JSON)** → voeg toe:
```json
"chat.editing.autoAccept": true
```

Zonder deze instelling vraagt de extensie bij elke bestandswijziging om bevestiging.

> **Snelle fix voor VS Code:** Ga naar VS Code-instellingen → zoek op `Claude` → zet de toggle **"Allow dangerously skip permissions"** aan. Daarna treedt `defaultMode: bypassPermissions` in `.claude/settings.json` in werking en verschijnen er geen prompts meer.

## Wat zit er in de container?

| Tool | Beschrijving |
|------|-------------|
| `python` | Python 3.12 |
| `uv` | Snelle Python package manager |
| `claude` | Claude Code CLI |
| CEDA org-skills | Geladen vanuit `cedanl/.github` via `npx skills` |

## Problemen oplossen

| Probleem | Oplossing |
|----------|-----------|
| "Cannot connect to Docker daemon" | Zorg dat Docker draait |
| Container bouwt niet | Controleer je internetverbinding |
| `claude` geeft API-fout | Controleer `.devcontainer/.env` en rebuild |
| Skills niet geladen | `npx skills add cedanl/.github --skill '*' -a claude-code -y --copy -g` |
