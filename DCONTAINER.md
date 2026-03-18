# Devcontainer Gebruikshandleiding

Een devcontainer biedt een kant-en-klare Python-ontwikkelomgeving in Docker. Je hoeft niets lokaal te installeren — Python, `uv`, Claude Code en de CEDA org-skills zijn allemaal vooraf geconfigureerd in de container.

## Vereisten

> **Docker is verplicht.** De container draait op Docker; zonder Docker werkt geen van onderstaande methoden.

- **Windows / macOS**: installeer [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux**: installeer [Docker Engine](https://docs.docker.com/engine/install/)

Zorg dat Docker draait voordat je een van de onderstaande stappen uitvoert.

---

## VS Code

### Eenmalige installatie

1. Installeer [Visual Studio Code](https://code.visualstudio.com/)
2. Installeer de extensie **Dev Containers** (`ms-vscode-remote.remote-containers`)

### Gebruik

```bash
git clone https://github.com/cedanl/python-uv-devcontainer
code python-uv-devcontainer
```

VS Code toont een melding rechtsonder: **"Reopen in Container"** — klik daarop.

Lukt dat niet? Druk op `F1` en zoek naar **Dev Containers: Reopen in Container**.

De eerste keer wordt de Docker-image gebouwd; dit duurt enkele minuten. Daarna start de container snel op.

---

## Positron

[Positron](https://positron.posit.co/) is een IDE van Posit met ingebouwde devcontainer-ondersteuning.

```bash
git clone https://github.com/cedanl/python-uv-devcontainer
```

Open de map in Positron. Positron detecteert automatisch de `.devcontainer/devcontainer.json` en vraagt of je de map in een container wilt heropenen. Klik **"Reopen in Container"**.

---

## DevPod

[DevPod](https://devpod.sh/) laat je devcontainers lokaal of in de cloud draaien, los van een specifieke IDE.

### Eenmalige installatie

Download DevPod via [devpod.sh](https://devpod.sh/) en stel een **provider** in. Kies **Docker** voor lokaal gebruik.

### Gebruik via de UI

1. Open DevPod en klik op **"Create Workspace"**
2. Voer de repository-URL in: `https://github.com/cedanl/python-uv-devcontainer`
3. Kies je IDE (VS Code, browser, etc.)
4. Klik **"Create Workspace"**

### Gebruik via de CLI

```bash
devpod up github.com/cedanl/python-uv-devcontainer
```

---

## Devcontainer CLI

De officiële `@devcontainers/cli` bouwt en beheert containers direct vanuit de terminal, zonder IDE.

### Eenmalige installatie

```bash
npm install -g @devcontainers/cli
```

### Gebruik

```bash
git clone https://github.com/cedanl/python-uv-devcontainer
cd python-uv-devcontainer

# Bouw en start de container
devcontainer up --workspace-folder .

# Open een shell in de container
devcontainer exec --workspace-folder . bash
```

---

## Wat zit er in de container?

Na het opstarten zijn de volgende tools beschikbaar:

| Tool | Beschrijving |
|------|-------------|
| `python` | Python 3.12 |
| `uv` | Snelle Python package manager |
| `claude` | Claude Code CLI (AI-assistent in de terminal) |
| `gh` | GitHub CLI |
| CEDA org-skills | Automatisch geladen vanuit `cedanl/.github` via `npx skills` |

Na het inloggen met `gh auth login` kun je ook `gh dash` gebruiken voor een GitHub-dashboard in de terminal.

---

## Problemen oplossen

| Probleem | Oplossing |
|----------|-----------|
| "Cannot connect to Docker daemon" | Zorg dat Docker Desktop of Docker Engine draait |
| Container bouwt niet | Controleer je internetverbinding; images worden bij de eerste build gedownload |
| `claude` niet gevonden | Herstart de terminal in de container (`exec bash`) |
| Skills niet geladen | Voer `npx skills add cedanl/.github --skill '*' -a claude-code -y --copy -g` handmatig uit |
