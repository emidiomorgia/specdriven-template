---
name: verifica-task
description: Procedura di verifica indipendente di un task completato - AC e DoD, rispetto del TDD, test, perimetro, coerenza con piano, specifiche e ADR. Usata dall'agente revisore; produce un esito APPROVATO o MODIFICHE RICHIESTE.
---

# Verifica di un task

Chi verifica **non ha scritto il codice** e lavora in sola lettura: non modifica file, non fa commit. Può eseguire comandi di test e di lettura git. Ogni giudizio ha un'evidenza (file, test, comando, commit).

Questa è la verifica **del singolo task**. Se l'esito è APPROVATO, l'orchestratore fonde subito il task nel branch della change: la revisione della change nel suo insieme la fa poi l'utente. Perciò giudicare il task per ciò che promette (AC, DoD, perimetro), senza rimandare indietro per questioni che riguardano altri task o scelte di insieme: quelle vanno segnalate come suggerimenti, per la revisione della change.

## 1. Raccolta

Leggere il task (descrizione, AC, DoD, perimetro), `docs/changes/*-<slug>/change.md` e `plan.md`, le sezioni di `docs/ARCHITECTURE.md` su convenzioni e test, `docs/SPECS.md` per le parti toccate, le ADR citate. Poi il lavoro: `git log <base>..<branch>` e `git diff <base>...<branch>`.

## 2. Controlli

1. **AC**: per ogni criterio, quale test lo copre e se il comportamento è davvero quello descritto. Un AC senza test, o con un test che non lo verifica, è un rilievo.
2. **TDD rispettato**: nella cronologia i commit di test (`test(e2e)`, `test(unit)`) precedono il codice di produzione (`feat`/`fix`); i due livelli di test esistono; i test non sono stati indeboliti per passare (controllare le modifiche ai test dopo il primo commit di produzione).
3. **Esecuzione**: eseguire la suite completa con i comandi di `ARCHITECTURE.md`. Riportare esito e conteggi. Una suite rossa o non eseguibile è un rilievo bloccante.
4. **DoD**: ogni voce soddisfatta; simboli pubblici documentati nel formato del linguaggio.
5. **Perimetro**: `git diff --name-only` contenuto nel perimetro. Confrontare file e simboli con le "modifiche previste" del task (in `plan.md` e nella descrizione): le differenze sono ammesse se dichiarate e coerenti con gli AC; scostamenti non dichiarati sono un rilievo.
6. **Coerenza**: il comportamento rispetta `change.md` e `plan.md`; nessun conflitto con `SPECS.md`, `ARCHITECTURE.md` o ADR; nessuna decisione architetturale nuova non registrata.
7. **Qualità**: leggibilità, duplicazioni evidenti, gestione errori, assenza di codice morto o di debug. Solo rilievi concreti, non gusti.

## 3. Esito

Classificare i rilievi: **bloccante** (impedisce l'approvazione) o **suggerimento** (non blocca). Un solo bloccante basta per MODIFICHE RICHIESTE. Non rimandare indietro per suggerimenti.

Formato di risposta, breve:

```
ESITO: APPROVATO | MODIFICHE RICHIESTE
Test: <comando eseguito> → <esito, conteggio unit/e2e>
AC: <n>/<n> coperti
TDD: <rispettato | rilievo>
Perimetro: <ok | rilievo>
Bloccanti:
- <rilievo + evidenza + cosa cambiare>
Suggerimenti:
- <rilievo>
```

Se non ci sono bloccanti, la sezione "Bloccanti" riporta "nessuno".
