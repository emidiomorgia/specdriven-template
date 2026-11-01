---
change: <slug>
data_approvazione: AAAA-MM-GG
stato: in-corso        # in-corso | chiusa
milestone: <id milestone Backlog.md>
roadmap: R-NNN         # voce di docs/ROADMAP.md da cui nasce la change
sottoprogetti: []      # es. [backend, frontend]: righe da aggiornare nel README
adr: []                # es. [ADR-0003]
---

# <Titolo della change>

> Delta di specifica introdotto da questa change, non l'intera specifica. Massimo ~60 righe.

## Obiettivo

<!-- Cosa si vuole ottenere e perché, in 2-4 righe. -->

## Comportamento atteso

<!-- Cosa cambia per chi usa il sistema, in termini osservabili. Un elenco breve; sezioni per capacità se più di una. -->

## Fuori scope

<!-- Cosa questa change NON fa. -->

## Criteri di accettazione della change

<!-- Scenari verificabili a livello di change (corrispondono agli e2e principali). -->

## Impatto sui documenti generali

- `SPECS.md`: <sezioni da aggiornare alla chiusura>
- `ARCHITECTURE.md`: <sezioni da aggiornare alla chiusura>
- `README.md`: <sottoprogetti il cui stato, comandi o tecnologia cambiano; altrimenti "nessuno">

## Rischi e punti aperti

<!-- Solo ciò che è davvero incerto. -->
