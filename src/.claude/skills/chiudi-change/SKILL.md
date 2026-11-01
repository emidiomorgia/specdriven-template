---
name: chiudi-change
description: Chiude una change dopo la revisione manuale dell'utente. Con tutti i task in Change Review, verifica test e congruenza con il piano, fa confluire la documentazione nei file generali (SPECS, ARCHITECTURE, CHANGELOG, README, ROADMAP), porta i task a Done, e porta la change in main (merge dell'utente o assistito). Argomento - slug della change.
---

# Chiudi change

Si esegue **dopo la revisione manuale dell'utente** (da PR o dall'avviso di `esegui-change`). Orchestrata dalla sessione principale; la sintesi documentale è affidata all'agente `curatore-docs`. Argomento: `<slug>`.

## 1. Precondizioni

- Tutti i task del milestone sono in `Change Review`. Se anche uno solo è in `To Do`, `In Progress` o `Verify`, **fermarsi** e dire quale: la change non è pronta. (Task già `Done` di un'esecuzione precedente non sono un problema.)
- Chiedere **una sola conferma**: «Confermi che la tua revisione della change è completata e approvata?». Senza un sì esplicito, fermarsi. Se l'utente ha chiesto modifiche, rimandarlo a `esegui-change` (sezione 7).
- Il branch `change/<slug>` contiene tutti i task fusi; `git status` pulito.
- La suite completa (unit ed e2e) è **verde** sul branch della change: eseguirla con i comandi di `docs/ARCHITECTURE.md`. Se è rossa, la change non si chiude.
- Con `gh` e una PR aperta, controllarne lo stato (`gh pr view --json state,mergedAt`). Se la PR risulta **già fusa**, avvisare l'utente: i documenti vanno committati sul branch principale. Proporre un branch `docs/<slug>` e una PR dedicata (o il commit diretto, se l'utente lo preferisce) e procedere così al punto 5.

## 2. Congruenza

Confrontare `docs/changes/*-<slug>/change.md` e `plan.md` con lo stato reale del codice e con le note dei task. Elencare gli scostamenti. Se ce ne sono: riportarli all'utente e decidere insieme se correggere il codice o aggiornare `change.md`/`plan.md` (nella sezione "Scostamenti"). Non chiudere con scostamenti irrisolti.

## 3. Sintesi documentale

Lanciare l'agente `curatore-docs` (`modelli.curatore_docs`) con: slug, percorso della change, voce di roadmap collegata (`roadmap:` in `change.md`), ADR collegate, sottoprogetti toccati, elenco dei final-summary dei task (`backlog task <id> --plain` per ciascuno). Il curatore:

1. Compila `docs/changes/<…>/changelog.md` con una riga per task.
2. Fonde il delta di `change.md` in `docs/SPECS.md`: **riscrive le sezioni interessate**, non accoda.
3. Aggiorna `docs/ARCHITECTURE.md` (componenti, convenzioni, tabella ADR) coerentemente con le ADR della change.
4. Aggiunge in testa a `docs/CHANGELOG.md` una voce: data, slug con link, sintesi in una riga, ADR collegate.
5. Aggiorna `docs/ROADMAP.md`: la voce passa a `chiusa` e si sposta nella tabella "Chiuse"; segnala le voci rese obsolete o nate durante la change, senza inventarne.
6. Aggiorna `README.md`: blocco di stato (ultima change chiusa, prossima in roadmap, avanzamento) e tabella dei sottoprogetti (stato, ultima change, comandi se cambiati).
7. Imposta `stato: chiusa` in `change.md` e aggiorna la data nei file generali.

Al ritorno, **verificare** il risultato: nessuna sezione duplicata, nessun contenuto della change lasciato fuori, limiti di lunghezza rispettati, marcatori del README e della roadmap intatti. Mostrare all'utente un riepilogo dei file cambiati.

## 4. Task a Done

Per ogni task del milestone in `Change Review`: `backlog task edit <id> -s Done`. Il milestone **non** si archivia.

Poi leggere `chiusura.pulizia_backlog` in `.claude/workflow.yml`:

- `nessuna` (default): non fare altro. I task restano in `Done` e il milestone resta nell'elenco: lo storico rimane consultabile (`backlog board`, `backlog task list -s Done --plain`, `backlog milestone list --plain`). Non usare `backlog task archive`: è pensato per lavori annullati o duplicati e rimuove dipendenze e riferimenti.
- `cleanup`: eseguire `backlog cleanup` per spostare i task Done fuori dalla board. Dopo il cleanup i task non sono più visibili con la CLI; il milestone resta nell'elenco (`--show-completed` se non compare).

## 5. Commit e push dei documenti

Committare documenti, `README.md` e file di `backlog/` modificati sul branch della change (messaggio diretto in italiano, es. `Chiusura change <slug>: documentazione e stato`). Con un remote: `git push`; se esiste una PR, si aggiorna da sola.

## 6. Portare la change in main

Secondo `git.merge_finale`:

- **`manuale`** (default): non fare il merge. Dire all'utente che il branch (o la PR) è pronto e che il merge in `main` lo fa lui. Se vuole, dopo il merge si può eliminare il branch della change.
- **`assistito`**: chiedere un ultimo OK esplicito, poi:
  - con PR: `gh pr merge --merge` (senza `--delete-branch` se l'utente non lo chiede);
  - senza PR: merge locale `--no-ff` di `change/<slug>` nel branch principale.
  Dopo il merge, eseguire la suite sul branch principale e riportare l'esito.

Non fare mai il merge in `main` senza il consenso previsto da questa regola.

## 7. Riepilogo

Dire in due righe: change chiusa, file generali aggiornati, stato del merge. Indicare il prossimo passo: la prossima voce `pronta` di `docs/ROADMAP.md` (`/intervista-piano R-NNN`), oppure `/roadmap` per popolare o riordinare il backlog di change.
