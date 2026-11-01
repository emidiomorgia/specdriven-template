# <Nome progetto>

<!-- Una o due righe: cos'è e a cosa serve. -->

> Le parti tra i marcatori `<!-- … -->` sono mantenute dal flusso di lavoro (piano approvato, task in revisione, change chiusa). Il resto è modificabile a mano.

## Stato del progetto

<!-- stato:inizio -->
- **Aggiornato**: AAAA-MM-GG
- **Change in corso**: nessuna
- **Ultima change chiusa**: nessuna
- **Prossima in roadmap**: —

| ID | Change | Stato | Task | PR |
|---|---|---|---|---|
<!-- stato:fine -->

Dettaglio e idee future in [docs/ROADMAP.md](docs/ROADMAP.md). Avanzamento dei singoli task nella board di Backlog.md (`backlog board`).

## Sottoprogetti

<!-- sottoprogetti:inizio -->
| Sottoprogetto | Percorso | Tecnologia | Stato | Avvio e test | Ultima change |
|---|---|---|---|---|---|
<!-- sottoprogetti:fine -->

Stato: `da avviare` · `scheletro` · `in sviluppo` · `stabile`.

## Avvio rapido

### Prerequisiti

<!-- Strumenti e versioni necessari. -->

### Avvio

<!-- Comandi per avviare il progetto in locale. -->

### Test

<!-- Comandi per eseguire tutti i test, solo unit, solo e2e (vedi docs/ARCHITECTURE.md, "Strategia di test"). -->

## Struttura del repository

<!-- Albero essenziale: una riga per cartella di primo livello. -->

## Documentazione

| Documento | Contenuto |
|---|---|
| [docs/SPECS.md](docs/SPECS.md) | cosa fa il sistema oggi |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | com'è fatto, convenzioni, strategia di test |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | cronologia delle change |
| [docs/ROADMAP.md](docs/ROADMAP.md) | backlog delle change |
| [docs/adr/](docs/adr/) | decisioni architetturali |
| [docs/changes/](docs/changes/) | documentazione di ogni change |
| [docs/MANUALE-WORKFLOW.md](docs/MANUALE-WORKFLOW.md) | manuale del flusso di lavoro |

## Flusso di lavoro

Sviluppo spec-driven con agenti e TDD: `/roadmap` → `/intervista-piano` → `/esegui-change` → tua revisione → `/chiudi-change`. Dettagli nel [manuale](docs/MANUALE-WORKFLOW.md).
