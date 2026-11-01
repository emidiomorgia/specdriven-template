---
name: setup-progetto
description: Primo avvio di un nuovo progetto. Verifica gli strumenti, configura Backlog.md, intervista l'utente per generare i file generali di documentazione (SPECS, ARCHITECTURE, CHANGELOG, ADR iniziali, ROADMAP) e avvia la prima change. Da eseguire una sola volta, all'inizio del progetto.
---

# Setup progetto

Si esegue nella sessione principale: richiede dialogo con l'utente. Obiettivo: partire da un progetto vuoto e arrivare a (1) file generali di contesto compilati, (2) strumenti pronti, (3) prima change avviata.

## 0. Precondizioni

- Se `docs/SPECS.md` o `docs/ARCHITECTURE.md` esistono già con contenuto reale: fermarsi e chiedere se rifare il setup. Non sovrascrivere mai senza conferma esplicita.
- Verificare con Bash `git rev-parse --is-inside-work-tree`, `command -v backlog`, `command -v gh`, `command -v node`. Riportare in una riga cosa manca. Non installare nulla senza consenso.
- Se `backlog/config.yml` non esiste: proporre lo script di setup adatto al sistema (`scripts/setup.sh "<nome>" [--installa-backlog]` su Linux/macOS/Git Bash/WSL, `scripts\setup.bat "<nome>" [--installa-backlog]` su Windows) ed eseguirlo dopo il consenso. Lo script porta gli stati della board a `To Do → In Progress → Verify → Change Review → Done` (`Verify` = verifica del revisore; `Change Review` = revisione umana della change). Se il comando `backlog init` pone domande interattive, guidare l'utente (rispondere NO alla creazione di file di istruzioni per agenti).
- Se `docs/_templates/` manca, fermarsi: il blueprint non è installato correttamente.

## 1. Intervista

Fare domande a round, **massimo 4 per round**, proponendo un default per ciascuna (l'utente può rispondere "default"). Non inventare: ciò che l'utente non sa o non vuole decidere ora si registra come `da definire`.

**Round A — Visione**: nome del progetto; scopo in una frase; chi sono utenti e attori; quale problema risolve; come si riconosce il successo.

**Round B — Funzionale**: capacità principali (elenco ad alto livello); cosa è esplicitamente fuori scope; vincoli (prestazioni, sicurezza, normativi, di dominio); termini di dominio da definire in glossario.

**Round C — Tecnico**: linguaggio, runtime e framework; tipo di applicazione; persistenza e integrazioni esterne; stile architetturale e confini tra componenti; convenzioni di codice (naming, organizzazione, formato idiomatico della documentazione dei simboli pubblici); come si avvia il progetto in locale; strumento di build. **Sottoprogetti**: se il repository contiene più parti (monorepo), per ciascuna nome, cartella, tecnologia, ruolo e come si avvia e si testa; se è un solo progetto, una riga sola.

**Round D — Test** (il TDD è già deciso; qui si definiscono i dettagli): comando per eseguire tutti i test, solo unit, solo e2e; cartelle dei due livelli (e2e organizzati per risorsa e poi per caso d'uso; unit speculari ai sorgenti); convenzione di naming dei test (default: `metodoSottoTest_condizione_risultatoAtteso`, adattata al linguaggio); come si ottengono le dipendenze esterne nei test (ambienti effimeri o doppi); eventuali soglie di copertura.

**Round E — Flusso**: parallelismo desiderato (default 2); modelli per ruolo (default in `.claude/workflow.yml`); esiste un remote git e `gh` è disponibile (da cui dipende `git.pr_change`: con una PR la tua revisione della change avviene su GitHub; senza, ti arriva un avviso con i comandi git per riguardare le differenze); chi esegue il merge finale in main (`git.merge_finale`: `manuale` = tu, `assistito` = l'orchestratore dopo il tuo OK). La verifica per task è sempre del revisore, e quella della change è sempre tua: non sono opzioni.

## 2. Sintesi e conferma

Riassumere in chat, in forma compatta, ciò che si scriverà in ciascun file e le ADR iniziali (tipicamente: stack e linguaggio; strategia di test; eventuali scelte architetturali portanti). Chiedere un'unica conferma: "Scrivo i file?". Iterare se l'utente corregge.

## 3. Generazione dei file

Partire dai modelli in `docs/_templates/`. Non scrivere nulla di non emerso dall'intervista.

1. `docs/SPECS.md` — panoramica, attori, capacità note (solo se già definite; per un progetto vuoto le capacità sono quelle che verranno costruite: lasciare la sezione con un rimando a `ROADMAP.md`), fuori scope, glossario.
2. `docs/ARCHITECTURE.md` — panoramica e confini, stack e ambiente, tabella ADR, convenzioni, **Strategia di test completa** (principi TDD invariati; livelli, layout, naming, comandi, dipendenze dall'intervista), branching e PR.
3. `docs/adr/ADR-0001-….md` e successive — una per decisione portante, brevi (limite in `workflow.yml`). Stato "accettata", change "setup".
4. `docs/CHANGELOG.md` — prima voce: setup iniziale, con rimando alle ADR.
5. `docs/ROADMAP.md` — dal modello, con le voci candidate (vedi punto 4).
6. `README.md` nella radice — dal modello `docs/_templates/README.md`: nome e descrizione, blocco `stato` (nessuna change in corso, prossima in roadmap = R-001), tabella **Sottoprogetti** compilata dall'intervista (stato iniziale `da avviare`), avvio rapido e test (da Round C e D, senza inventare), struttura del repository, link alla documentazione. Se un `README.md` esiste già, non sovrascriverlo: mostrare cosa verrebbe aggiunto e inserire i soli blocchi gestiti dopo l'OK.
7. `CLAUDE.md` — compilare solo la sezione "Contesto del progetto" (nome, scopo, stato: inizializzato). Non alterare il resto.
8. `.claude/workflow.yml` — aggiornare solo i valori che l'utente ha cambiato.

Rispettare i criteri di scrittura: dettagliato e preciso ma poco prolisso; frasi brevi; tabelle e elenchi per ciò che è enumerabile; nessun contenuto duplicato tra i file.

## 4. Roadmap e prima change

Proporre 2–5 change candidate in ordine, ciascuna con nome breve, obiettivo in una riga, priorità, dimensione e dipendenze. La prima deve essere di fondamenta: uno scheletro eseguibile minimo, con ambiente di test funzionante e almeno un test e2e che passa. Le candidate vengono solo da ciò che l'utente ha detto (capacità, sottoprogetti da avviare): non inventare funzionalità.

Scrivere le voci in `docs/ROADMAP.md` dopo l'OK dell'utente: ID `R-001`, `R-002`, … in ordine di priorità; `R-001` `pronta`, le altre `pronta` se l'obiettivo è chiaro, altrimenti `idea`. Dire all'utente che da qui in poi il backlog si completa e si riordina con `/roadmap`.

Chiedere quale voce avviare e procedere invocando la skill `intervista-piano` con `R-NNN` (di norma `R-001`).

## 5. Chiusura

Se il git è inizializzato, proporre un commit dei file generati con messaggio diretto in italiano (es. "Setup iniziale: contesto, ADR e roadmap"). Non fare il commit senza consenso.
