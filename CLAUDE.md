# Claude Code — projectinstructies

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
Gebruik standaard `--sandbox workspace-write --full-auto` voor taken met bestandswijzigingen.
