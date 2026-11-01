---
name: sviluppo-tdd
description: Procedura di sviluppo di un singolo task in TDD, con test e2e e unit - RED e2e, RED unit, GREEN, REFACTOR. Usata dall'agente sviluppatore; usabile anche a mano per lavorare a un task senza orchestratore.
---

# Sviluppo TDD di un task

Si lavora **solo nel worktree indicato** e **solo nel perimetro** del task. Convenzioni, layout e comandi dei test sono in `docs/ARCHITECTURE.md` (sezioni "Convenzioni di codice" e "Strategia di test"): sono la fonte di verità e hanno la precedenza su qualsiasi abitudine.

## 0. Preparazione

1. Leggere il task (descrizione, AC, DoD, perimetro), `docs/changes/*-<slug>/change.md` e `plan.md`, e le sezioni citate di `ARCHITECTURE.md`.
2. Eseguire la suite esistente e verificare che sia **verde**. Se è rossa prima di iniziare, fermarsi e riportare (esito BLOCCATO): non è colpa di questo task.
3. Elencare mentalmente gli scenari da coprire derivandoli dagli AC: ogni AC deve finire in almeno un test.

## 1. RED — e2e

Scrivere i test e2e del task, per caso d'uso, nel layout previsto, con il nome nel formato definito in `ARCHITECTURE.md`. Eseguirli e verificare che **falliscano per il motivo atteso** (comportamento mancante), non per errori di compilazione o di setup. Se la compilazione impedisce l'esecuzione, creare solo gli stub minimi (firme vuote) perché il test giri e fallisca per asserzione.

Commit: `test(e2e): <cosa verifica>`.

## 2. RED — unit

Scrivere i test unit delle unità pubbliche coinvolte, un file di test per unità, nel layout previsto, con dipendenze sostituite. Eseguirli e verificare che falliscano per il motivo atteso.

Commit: `test(unit): <cosa verifica>`.

## 3. GREEN

Scrivere il **codice minimo** che fa passare i test. Eseguire unit ed e2e: devono passare tutti.

Commit: `feat: <cosa>` (o `fix:` se corregge un comportamento esistente).

## 4. REFACTOR

Migliorare codice e test senza cambiare il comportamento, rieseguendo i test dopo ogni passo: devono restare verdi. Verificare che ogni simbolo pubblico di produzione sia documentato nel formato idiomatico del linguaggio (scopo e, dove significativo, parametri, ritorno, errori), e che le classi di test abbiano una breve descrizione.

Commit: `refactor: <cosa>`. Se non c'è nulla da rifattorizzare, dirlo nel report senza commit vuoto.

## 5. Chiusura del task

1. Eseguire **l'intera suite** (unit ed e2e): tutto verde.
2. Controllare gli AC e la DoD uno per uno, con l'evidenza (quale test li copre).
3. Verificare `git diff --name-only <branch-base>`: nessun file fuori dal perimetro, e confrontarlo con le "modifiche previste" del task (file e simboli): ogni differenza va dichiarata come scostamento. Se un file esterno era davvero necessario, dichiararlo come scostamento nel report, non nasconderlo.
4. Produrre il report nel formato dell'agente `sviluppatore`.

## Regole

- **Non scrivere codice di produzione prima di aver visto fallire il test corrispondente.**
- Se un test non fallisce al RED, o è sbagliato o il comportamento esiste già: indagare prima di procedere.
- Non modificare un test per farlo passare, salvo che il test sia sbagliato; in tal caso segnalarlo nel report.
- Commit separati per fase: servono al revisore per verificare che il RED preceda il GREEN.
- Se il task è ambiguo, contraddittorio o richiede decisioni architetturali non previste dal piano: fermarsi e riportare BLOCCATO con la domanda precisa, senza improvvisare.
- Nessuna scrittura in `backlog/` o `docs/`.
