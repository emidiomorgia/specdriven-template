---
name: esegui-change
description: Orchestra l'esecuzione dei task di una change approvata. Lancia in parallelo gli agenti sviluppatore (nel limite configurato), fa verificare ogni task dal revisore, fonde i task approvati nel branch della change, e a task tutti fusi avvisa l'utente (con PR se possibile) per la sua revisione della change. Se l'utente chiede modifiche, crea task correttivi e riparte. Argomenti - slug della change, opzionalmente --parallel N e --review N.
---

# Esegui change

La sessione principale fa da **orchestratore**. Non scrive codice: seleziona i task, lancia gli agenti, aggiorna Backlog.md, gestisce git e avvisa l'utente. Argomenti: `<slug> [--parallel N] [--review N]`.

La verifica è a **due livelli**:

1. **Per task** — la fa il `revisore` (agente). Se approva, il task è **fuso subito** nel branch della change e passa a `Change Review`.
2. **Per change** — la fa l'utente, quando tutti i task sono fusi. Questa skill lo avvisa (con PR se possibile) e si ferma. La chiusura è di `chiudi-change`.

## 0. Preparazione

1. Leggere `.claude/workflow.yml`. Gli argomenti hanno la precedenza sul file. Parametri chiave: `max_task_paralleli`, `max_review_parallele`, `modelli`, `su_fallimento`, `max_cicli_review`, `test_dopo_merge`, sezione `git`.
2. Verificare: la cartella `docs/changes/*-<slug>/` esiste; `git status` pulito; si è sul branch `change/<slug>` (altrimenti passarci); il comando di test in `docs/ARCHITECTURE.md` esiste.
3. Verificare che `backlog/config.yml` contenga lo stato `Change Review` (elenco: `To Do`, `In Progress`, `Verify`, `Change Review`, `Done`). Se manca, aggiungerlo al campo `statuses` e dirlo all'utente: i progetti nati prima di questa regola non lo hanno.
4. Fotografare lo stato: elenco task del milestone e stati (`backlog task list --plain`; se il flag non esiste, vedere `--help`). Creare con TaskCreate una voce di avanzamento per task.
5. Se la change era già stata portata in revisione e l'utente rilancia la skill dopo aver chiesto modifiche, vedere la sezione 7.

## 1. Quali task sono pronti

Un task è **pronto** se: stato `To Do`; tutte le sue dipendenze sono in `Change Review` o `Done` (cioè **già fuse** nel branch della change); il suo perimetro non si sovrappone a quello di un task in corso (`In Progress` o `Verify`).

Il numero di sviluppatori attivi non supera mai `max_task_paralleli`: il parametro è un tetto, non un obiettivo. I revisori hanno un tetto proprio (`max_review_parallele`).

## 2. Avvio di un task

Per ogni task pronto, finché ci sono slot liberi:

1. `backlog task edit <id> -s "In Progress"`.
2. Creare il worktree dal branch della change (che contiene già i task fusi):
   `git worktree add <cartella_worktree>/<id> -b task/<id>-<slug-breve> change/<slug>`
3. Lanciare l'agente `sviluppatore` con il tool Agent, **in background**, con il parametro `model` preso da `modelli.sviluppatore`. Per avviare più task in parallelo, inviare tutte le chiamate Agent nello stesso messaggio. Il prompt contiene, completi: ID, titolo, descrizione, AC, DoD, perimetro, slug della change, **percorso assoluto del worktree**, branch, e il rimando a `docs/changes/*-<slug>/change.md` e `plan.md` (con le modifiche previste del task).
4. Lo sviluppatore lavora solo nel proprio worktree e non scrive in `backlog/` né in `docs/`.

## 3. Quando uno sviluppatore termina

Alla notifica di completamento, leggere il report.

- **BLOCCATO** o fallito: applicare `su_fallimento`. Con `ferma`, non avviare altri task, lasciare finire quelli in corso e riportare all'utente. Con `continua`, segnare il task e proseguire con i task indipendenti da esso.
- **COMPLETATO**: nel checkout principale aggiornare Backlog.md con la CLI:
  - `backlog task edit <id> --append-notes "[SVILUPPATORE] <note del report>"`
  - `backlog task edit <id> --final-summary "<riga di changelog>"`
  - `--check-ac <n>` e `--check-dod <n>` per ciò che il report dimostra
  - `backlog task edit <id> -s Verify`
  Poi, se c'è uno slot di revisione libero, lanciare l'agente `revisore` (in background, `modelli.revisore`) passando ID, AC, DoD, perimetro, worktree, branch e branch di base.

## 4. Quando un revisore termina

- **MODIFICHE RICHIESTE**: `--append-notes "[REVISORE] <richieste>"`, stato `In Progress`, e rilancio dello `sviluppatore` sullo stesso worktree con le richieste. Contare i cicli: superato `max_cicli_review`, fermarsi e consegnare il task all'utente con il quadro della situazione.
- **APPROVATO**: eseguire nell'ordine questi passi, **senza attendere l'utente**.
  1. `backlog task edit <id> --append-notes "[REVISORE] approvato: <sintesi>"`.
  2. Committare le modifiche a `backlog/` nel checkout principale (messaggio diretto in italiano, es. `Backlog: TASK-<id> approvato dal revisore`), così il merge parte da un albero pulito.
  3. **Merge nel branch della change**, dal checkout principale (sul branch `change/<slug>`):
     `git merge --no-ff task/<id>-<slug-breve> -m "Merge TASK-<id>: <titolo>"`.
     I merge si fanno **uno alla volta**: se due revisori terminano insieme, serializzarli.
     - **Conflitto**: `git merge --abort`. Il task resta in `Verify` con la nota `[ORCHESTRATORE] conflitto di merge con <file>`. Fermarsi su questo task e riportarlo all'utente; i task indipendenti possono proseguire se `su_fallimento` è `continua`.
  4. Se `test_dopo_merge` è `true`: eseguire la **suite completa** (unit ed e2e) sul branch della change. Se è rossa, annullare il merge con `git revert -m 1 --no-edit HEAD` (operazione non distruttiva), tornare a `In Progress` con la nota `[ORCHESTRATORE] suite rossa dopo il merge: <test falliti>` e rilanciare lo `sviluppatore` perché risolva l'integrazione. Conta come ciclo di review.
  5. `backlog task edit <id> -s "Change Review"`. Da qui il task è fuso nel branch della change.
  6. Pulizia: `git worktree remove <worktree>` e `git branch -d task/<id>-<slug-breve>`.
  7. Committare le modifiche a `backlog/`.

Un task in `Change Review` **non è Done**: lo diventa solo in `chiudi-change`, dopo l'approvazione dell'utente.

## 5. Ciclo

Dopo ogni evento (task terminato, revisione conclusa), riempire gli slot liberi tornando al punto 1. Dopo ogni evento mostrare all'utente una riga di stato (task per stato) e aggiornare le voci di avanzamento. Su richiesta, mostrare la board (`backlog board`).

## 6. Tutti i task fusi: revisione dell'utente

Quando **tutti** i task del milestone sono in `Change Review` (nessuno in `To Do`, `In Progress` o `Verify`):

1. **Verifica d'insieme**: suite completa (unit ed e2e) sul branch della change; deve essere verde. Se è rossa, trattarlo come un guasto: riportarlo all'utente con i test falliti e non proseguire.
2. **Roadmap e README**: nella riga della change in `docs/ROADMAP.md` mettere stato `in-revisione` e avanzamento `N/N`; aggiornare lo stesso dato nel blocco di stato di `README.md` (formato nei modelli di `docs/_templates/`). Committare.
3. **PR o avviso**, secondo `git.pr_change`:
   - `auto`, con `gh` disponibile e un remote configurato: `git push -u origin change/<slug>` e `gh pr create --base <branch principale> --head change/<slug>`. Branch principale: quello indicato in `docs/ARCHITECTURE.md` (sezione "Branching e PR"), altrimenti `main`. Titolo = titolo della change. Descrizione, breve: obiettivo, elenco task (ID e titolo), ADR prodotte, esito dei test, rimando a `docs/changes/<…>/`. Annotare il link della PR nella riga della roadmap.
   - `auto` ma senza `gh` o senza remote, oppure `nessuna`: nessuna PR. L'utente riguarda la change in locale con `git diff <principale>...change/<slug>` o `git log`.
4. **Avvisare l'utente** con un messaggio chiaro in chat; se è disponibile uno strumento di notifica, usarlo anche. Il messaggio contiene: la change è pronta per la tua revisione; link alla PR oppure i comandi git per vedere le differenze; elenco dei task fusi; cosa fare dopo:
   - **approvi** → `/chiudi-change <slug>`;
   - **chiedi modifiche** → descrivile in chat (sezione 7) oppure commenta la PR e dimmelo.
5. **Fermarsi.** Non chiudere, non fare merge in `main`, non segnare nulla `Done`.

## 7. Dopo la revisione dell'utente: modifiche richieste

Se l'utente chiede modifiche (in chat o riassumendo i commenti della PR):

1. Tradurle in uno o più **task correttivi**, nel milestone della change, con `backlog task create`: titolo che inizia con `Fix revisione:`, descrizione con l'esito atteso, perimetro, AC verificabili, DoD standard. Chiedere conferma all'utente solo se la richiesta è ambigua.
2. Stato iniziale `To Do`. I task già fusi restano `Change Review`.
3. Aggiornare la roadmap (stato `in-corso`, avanzamento ricalcolato) e il README, committare.
4. Riprendere dal punto 1: il ciclo è identico (sviluppatore → revisore → merge nel branch della change). Se esiste una PR, i nuovi commit la aggiornano da soli (`git push`).
5. A task correttivi fusi, tornare al punto 6.

Se la modifica è minima e l'utente preferisce farla da sé sul branch della change, lasciarlo fare: poi basta `/chiudi-change`.

## 8. Fine

Questa skill termina sempre al punto 6 (in attesa dell'utente) oppure con task bloccati/in attesa dell'utente. Riportare in poche righe: task fusi, task rimasti e perché, PR aperta (se c'è).

## Regole

- Solo l'orchestratore usa la CLI `backlog` e scrive in `docs/`, in `README.md` e nei file di `backlog/`. Gli agenti non lo fanno: così i worktree paralleli non entrano in conflitto.
- Non avviare un task il cui perimetro tocca file di un altro task in corso.
- Non fondere mai un task non approvato dal revisore, e non segnare mai `Done` un task: è compito di `chiudi-change` dopo l'approvazione dell'utente.
- Un solo agente per task alla volta; il revisore non è mai lo stesso contesto dello sviluppatore.
- Nessuna operazione distruttiva su git (`reset --hard`, `push --force`, `branch -D`): per annullare un merge usare `revert`.
- I commit di backlog si fanno sul branch della change, nel checkout principale, ai punti di svolta (task in Verify, task approvato, task correttivi creati), non a ogni comando.
