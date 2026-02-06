# Python devcontainer met uv

Deze repository biedt een minimale development container voor Python-projecten met [uv](https://github.com/astral-sh/uv) als package manager.

## Gebruik

1. Clone deze repo naar GitHub (bijv. als template voor je organisatie).
2. Open de map in VS Code.
3. Kies: `Reopen in Container` (Dev Containers / Codespaces).
4. Dependencies worden automatisch geïnstalleerd via `uv sync`.
5. Run de app:

   ```bash
   uv run python -m src.main

## Vereisten

- Docker moet geïnstalleerd en actief zijn op je machine (of je gebruikt GitHub Codespaces met container support).
- Een editor die met devcontainers overweg kan, zoals VS Code + de Dev Containers-extensie of GitHub Codespaces.

**Zonder Docker (of een equivalente container runtime) kan deze setup niet werken**, omdat de volledige ontwikkelomgeving in de container draait.
