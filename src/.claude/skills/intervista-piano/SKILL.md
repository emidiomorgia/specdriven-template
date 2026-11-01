---
name: intervista-piano
description: Avvia una nuova change, da una voce di roadmap (R-NNN) o da un obiettivo libero. Intervista l'utente, produce un piano con scomposizione in task indipendenti, lo sottopone ad approvazione e, solo dopo l'OK, crea documentazione della change, ADR, milestone e task in Backlog.md e aggiorna roadmap e README. Usare per ogni funzionalità o modifica non banale.
---

# Intervista e piano

Si esegue nella sessione principale. Non delegare a un subagent: serve il dialogo con l'utente. Parametri della documentazione in `.claude/workflow.yml`.

## 1. Contesto (sola lettura)

Leggere `docs/SPECS.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, le ultime voci di `docs/CHANGELOG.md` e le ADR pertinenti all'area toccata. Se serve il dettaglio storico di una decisione, leggere la cartella della change o l'ADR collegata. Prima del piano (dopo l'intervista) leggere anche il **codice esistente** delle aree che la change tocca, per sapere quali file, classi e metodi esistono davvero e quali vanno aggiunti o modificati. **Non scrivere nulla.**

## 2. Obiettivo

- **Con argomento `R-NNN`**: partire dalla voce di `docs/ROADMAP.md` (obiettivo, priorità, dipendenze, dettagli). Se la voce è `idea`, dirlo e chiedere se approfondirla ora; se ha dipendenze non ancora chiuse, segnalarlo e far decidere all'utente.
- **Senza argomento**: se l'utente non ha già descritto cosa vuole ottenere, chiederlo in una frase. Se l'obiettivo coincide con una voce della roadmap, usare quella; se non c'è, la voce verrà creata al punto 6.
- Se la roadmap ha una voce `in-corso` o `in-revisione`, segnalarlo: di norma si tiene **una change alla volta**.

## 3. Intervista

Round di **massimo 4 domande**, chiuse quando possibile, con l'opzione consigliata indicata per prima. Coprire, nell'ordine utile:

- comportamento atteso, dal punto di vista di chi usa il sistema;
- casi limite ed errori;
- cosa è fuori scope;
- impatto su capacità esistenti e conflitti con `SPECS.md`, `ARCHITECTURE.md` o ADR: se ci sono, **segnalarli esplicitamente e far decidere all'utente**;
- dati, integrazioni, vincoli non funzionali;
- scenari e2e di accettazione.

Fermarsi quando si può scrivere un piano senza ipotesi aperte (di norma 2–3 round). Ciò che resta incerto va nei "rischi e punti aperti", non si indovina.

## 4. Piano (solo in chat)

Presentare, in forma compatta:

1. **Obiettivo** e **comportamento atteso**.
2. **Fuori scope**.
3. **Decisioni architetturali** (ADR candidate: titolo e decisione in una riga).
4. **Task**, in tabella: numero, titolo, dipende da, perimetro (aree/moduli toccati), scenari e2e principali.
5. **Modifiche previste**, task per task (vedi sotto): il dettaglio che l'utente approva o corregge.
6. **Parallelismo**: quali task possono andare insieme e quali no, con il motivo.
7. **Rischi e punti aperti**.

### Modifiche previste (obbligatorie per l'approvazione)

Per **ogni task**, elencare **tutti** i file che si prevede di creare o modificare, uno per riga, nel formato:

```
TASK n — <titolo>
| File | Esito | Classi / funzioni e metodi | Cosa fa |
| <percorso> | nuovo / modificato | `Classe` · `metodo(firma sintetica)` | <una riga> |
```

- Includere i **file di test** (e2e e unit) con le classi di test e i **nomi dei test** principali (secondo la convenzione di `ARCHITECTURE.md`), e i file di configurazione, risorse, script o build toccati.
- Per i file **modificati** indicare solo ciò che cambia (metodi aggiunti, modificati, rimossi), non l'intero file; i percorsi e i simboli esistenti vanno verificati nel codice, non ipotizzati.
- Per i file **nuovi** indicare le classi/funzioni pubbliche con firma sintetica (parametri e tipo di ritorno) e il ruolo; i dettagli interni restano all'implementazione.
- Dove il linguaggio o lo stile non ha classi (moduli, funzioni, componenti), usare l'unità equivalente.
- Ciò che non è ancora noto va marcato `da definire` (e finisce nei rischi), non inventato.
- Ogni file elencato deve stare nel **perimetro** del task. L'unione dei perimetri è ciò che serve a verificare l'assenza di sovrapposizioni tra task paralleli.

Regole di scomposizione:

- Ogni task produce un valore **verificabile da solo**, è testabile e2e e corrisponde a una PR.
- Dimensione: completabile da un agente in una sessione, senza dover interpretare altri task.
- **Task paralleli = perimetri disgiunti.** Se due task toccano la stessa area, diventano sequenziali (dipendenza esplicita).
- Le dipendenze si dichiarano solo se reali (un task usa ciò che un altro produce).
- Se serve fondamenta comune (struttura, contratti condivisi), è il primo task, e gli altri dipendono da lui.

## 5. Approvazione

Iterare finché l'utente non dà un **OK esplicito** ("approvato", "procedi"). L'utente può correggere qualsiasi riga delle modifiche previste (spostare un metodo, rinominare una classe, togliere o aggiungere un file): ripresentare solo ciò che è cambiato, ricontrollando perimetri e parallelismo. Fino all'OK nessun file, nessun task, nessun branch.

## 6. Dopo l'OK — nello stesso passaggio

1. **Slug** in kebab-case (max ~5 parole). Cartella `docs/changes/AAAAMMGG-slug/` con data odierna (suffisso `-2`, `-3` se esiste già). Creare da `docs/_templates/`: `change.md` (compilato, stato `in-corso`, con `roadmap:` e `sottoprogetti:`), `plan.md` (il piano approvato, con voce di roadmap, sottoprogetti toccati e le **modifiche previste** per task), `changelog.md` (solo intestazione).
2. **ADR** in `docs/adr/ADR-NNNN-titolo.md`, una per decisione significativa, con NNNN = massimo esistente + 1 (mai riusato). Stato "accettata".
3. **Backlog.md**: `backlog milestone add "<slug>"`; poi un `backlog task create` per ogni task, seguendo `docs/_templates/task.md`: titolo, descrizione (obiettivo, perimetro, dipendenze, test attesi, **modifiche previste** copiate dal piano approvato), `--ac` per ogni criterio, `--dod` per la DoD standard più eventuali specifici, assegnazione al milestone, dipendenze. Annotare in `plan.md` gli ID assegnati.
   - I flag per milestone e dipendenze possono avere nomi diversi a seconda della versione: se un flag non è accettato, consultare `backlog task create --help` e adattarsi. Se le dipendenze non sono esprimibili con un flag, scriverle nella descrizione come `Dipende da: <id>`.
4. **Roadmap e README**:
   - in `docs/ROADMAP.md`, nel blocco `roadmap`: la voce della change passa a `in-corso`, "Avanzamento" `0/N` (N = numero di task), "Change / PR" con il link a `docs/changes/<…>/`. Se la change non aveva una voce, crearla con il prossimo ID `R-NNN` (mai riusato), già `in-corso`; scrivere l'ID in `change.md` e `plan.md`;
   - se la change ha fatto emergere altre idee, proporle all'utente come voci `idea` (non aggiungerle senza OK);
   - in `README.md`, blocco `stato`: aggiornare "Change in corso", "Aggiornato" e la riga della tabella di avanzamento. Se la tabella dei sottoprogetti ha righe da creare o cambiare di stato (es. un sottoprogetto che da `da avviare` passa a `in sviluppo`), aggiornarle.
5. **Git**: creare il branch `change/<slug>` dal branch principale e fare un commit dei documenti, dei task creati, della roadmap e del README (messaggio diretto in italiano). Se non c'è un repository, segnalarlo. **Non toccare** `SPECS.md`, `ARCHITECTURE.md`, `CHANGELOG.md`: li aggiorna `chiudi-change`.
6. **Riepilogo** all'utente: percorso della change, elenco task con ID e dipendenze, e il prossimo passo: `/esegui-change <slug> [--parallel N]`. Ricordare il flusso di verifica: ogni task è verificato dal revisore e fuso nel branch della change; a task tutti fusi sarà avvisato per la **sua** revisione della change.

## Criteri di scrittura

`change.md` entro il limite di righe di `workflow.yml`; comportamento descritto in termini osservabili, non implementativi; niente elenchi di file nel `change.md` (le modifiche previste stanno in `plan.md`); niente ripetizioni tra `change.md` e `plan.md` (la prima dice *cosa*, la seconda *come e in che ordine*).
