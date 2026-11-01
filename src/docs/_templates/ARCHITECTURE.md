---
tipo: architettura-corrente
aggiornato: AAAA-MM-GG
---

# Architettura corrente

> Come è fatto il sistema **oggi** (as-is). Si riscrive per sezione, non si accoda. Le motivazioni delle scelte sono nelle ADR.

## Panoramica e confini

<!-- Stile architetturale, componenti principali, confini e responsabilità. Poche righe o un breve elenco.
Elenco, stato e comandi dei sottoprogetti: tabella "Sottoprogetti" del README.md (fonte unica; qui solo i confini e le dipendenze tra essi). -->

## Stack e ambiente

<!-- Linguaggio, runtime, framework, persistenza, integrazioni. Come si avvia il progetto in locale. -->

## Decisioni (ADR)

| ADR | Titolo | Stato |
|---|---|---|

## Convenzioni di codice

<!-- Naming, organizzazione dei moduli, documentazione dei simboli pubblici nel formato idiomatico del linguaggio, gestione errori. -->

## Strategia di test

### Principi

- Sviluppo in **TDD**, per ogni task: RED e2e → RED unit → GREEN → REFACTOR.
- Nessun codice di produzione prima di aver visto fallire il test corrispondente, per il motivo atteso.
- Un test non si modifica per farlo passare, salvo che sia sbagliato (e lo si segnala).
- La change non è chiusa se i test non sono tutti eseguiti e verdi.

### Livelli

- **e2e**: verificano un caso d'uso completo attraverso l'interfaccia reale del sistema, con le dipendenze esterne reali o effimere. Organizzati per risorsa/area e poi per caso d'uso.
- **unit**: verificano classi/funzioni pubbliche in isolamento, con dipendenze sostituite. Un file di test per unità, struttura speculare ai sorgenti.

### Layout e naming

- Cartella e2e: `<da definire>`
- Cartella unit: `<da definire>`
- Nome dei test: `metodoSottoTest_condizione_risultatoAtteso` (adattare alla convenzione del linguaggio)

### Comandi

| Scopo | Comando |
|---|---|
| Tutti i test | `<da definire>` |
| Solo unit | `<da definire>` |
| Solo e2e | `<da definire>` |

### Dipendenze nei test

<!-- Come si ottengono database, broker, servizi esterni nei test (es. ambienti effimeri), e cosa si sostituisce con doppi. -->

## Branching e PR

<!-- Branch principale, convenzione dei branch. I valori operativi sono in `.claude/workflow.yml`.
Flusso previsto: ogni task su un branch `task/<id>-<slug>` in un worktree; dopo l'approvazione del revisore si fonde nel branch `change/<slug>`; a task tutti fusi la change viene riesaminata dall'utente (PR change → principale, se c'è un remote) e infine portata nel branch principale. -->
