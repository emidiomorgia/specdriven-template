# CLAUDE.md — Flusso spec-driven con agenti

Istruzioni di progetto, caricate a ogni sessione: non vanno ripetute in chat. Il dettaglio dei passi sta nelle skill in `.claude/skills/`; qui restano principi, struttura e regole trasversali.

## Contesto del progetto

<!-- Compilato da /setup-progetto -->
- Nome: _da compilare_
- Scopo: _da compilare_
- Stato: da inizializzare — eseguire `/setup-progetto`

Il contesto funzionale e architetturale vive in `docs/SPECS.md` e `docs/ARCHITECTURE.md`. Leggerli prima di ogni intervista o piano.

## Approccio

Il lavoro procede per **change**: un obiettivo descritto dall'utente che passa per intervista, piano approvato, task, sviluppo TDD, verifica, PR e chiusura.

1. **Una change = un milestone Backlog.md = una cartella `docs/changes/YYYYMMDD-slug/`.**
2. **Il piano nasce da un'intervista e va approvato** dall'utente prima di scrivere qualsiasi file o creare task.
3. **Dal piano nascono task indipendenti**, ciascuno con criteri di accettazione (AC), definition of done (DoD), perimetro di file e dipendenze. I task senza dipendenze aperte e con perimetri disgiunti possono procedere in parallelo.
4. **TDD sempre**, a due livelli (e2e e unit): RED e2e → RED unit → GREEN → REFACTOR.
5. **Verifica a due livelli.** Per **task**: un agente diverso da chi ha scritto il codice (il `revisore`) verifica; se approva, il task viene fuso subito nel branch della change. Per **change**: quando tutti i task sono fusi, l'utente fa la sua revisione (da PR, se possibile, altrimenti da avviso). Solo dopo la sua approvazione la change si chiude.
6. **La documentazione nasce per change** e, alla chiusura, confluisce nei file generali, che sono il contesto delle change successive.
7. **`docs/ROADMAP.md` è il backlog delle change** da cui si attinge; **`README.md`** è la sintesi viva del progetto (stato, avanzamento, sottoprogetti). Entrambi si mantengono durante il normale ciclo, non a mano.

## Struttura

```
CLAUDE.md                        # questo file
README.md                        # sintesi viva: stato, avanzamento, sottoprogetti, avvio rapido
.claude/
├── workflow.yml                 # parametri del flusso (parallelismo, modelli, git, approvazioni)
├── skills/                      # procedure: setup-progetto, roadmap, intervista-piano, esegui-change,
│                                #   sviluppo-tdd, verifica-task, chiudi-change
└── agents/                      # ruoli: sviluppatore, revisore, curatore-docs
backlog/                         # ledger dei task — gestito SOLO dalla CLI `backlog`
                                 #   stati: To Do → In Progress → Verify → Change Review → Done
docs/
├── SPECS.md                     # specifiche correnti (as-is)
├── ARCHITECTURE.md              # architettura, convenzioni e strategia di test correnti (as-is)
├── CHANGELOG.md                 # cronologia sintetica delle change
├── ROADMAP.md                   # backlog delle change: idee, pronte, in corso, chiuse
├── changes/YYYYMMDD-slug/       # change.md, plan.md, changelog.md della singola change
├── adr/ADR-NNNN-titolo.md       # una decisione architetturale per file
└── _templates/                  # modelli dei documenti
```

## Comandi (skill)

| Comando | Quando | Chi lavora |
|---|---|---|
| `/setup-progetto` | Una sola volta, all'inizio | Sessione principale |
| `/roadmap [aggiungi \| brainstorm \| priorità \| …]` | Per popolare e ordinare il backlog di change, quando vuoi | Sessione principale (dialogo con l'utente) |
| `/intervista-piano [R-NNN]` | Per ogni nuova change, da una voce di roadmap o da un obiettivo libero | Sessione principale (dialogo con l'utente) |
| `/esegui-change <slug> [--parallel N]` | Dopo l'approvazione del piano; si rilancia dopo una revisione con modifiche | Sessione principale come orchestratore; agenti `sviluppatore` e `revisore` |
| `/chiudi-change <slug>` | Dopo la **tua** revisione della change, con tutti i task in `Change Review` | Orchestratore; agente `curatore-docs` |

Le skill `sviluppo-tdd` e `verifica-task` sono le procedure dei ruoli `sviluppatore` e `revisore`: non si invocano a mano, salvo per lavorare a un task senza orchestratore.

## Regole generali

- **Lingua**: documentazione, commit e note in italiano; gli identificatori del codice seguono la convenzione del progetto.
- **Niente scritture prima dell'approvazione del piano**: né `docs/changes/`, né ADR, né task, né file generali.
- **Chi scrive dove**: solo la sessione principale scrive in `backlog/` e `docs/`. Gli agenti `sviluppatore` scrivono solo codice e test nel proprio worktree e non toccano mai `backlog/` né `docs/`.
- **Backlog.md solo via CLI**: mai modificare a mano `backlog/tasks/*.md`.
- **Significato degli stati**: `Verify` = implementato, in attesa del revisore (agente). `Change Review` = approvato dal revisore **e già fuso nel branch della change**, in attesa della revisione umana della change. `Done` = change approvata dall'utente e chiusa. Un task passa a `Done` solo in `/chiudi-change`.
- **Roadmap e README**: li aggiorna solo la sessione principale (o il `curatore-docs` in chiusura), ai punti di svolta: piano approvato, tutti i task in `Change Review`, change chiusa. Le parti gestite dal flusso sono dentro i marcatori `<!-- … -->` dei modelli: il testo fuori dai marcatori è tuo e non si tocca.
- **File generali = solo stato attuale**: `SPECS.md` e `ARCHITECTURE.md` si riscrivono per sezione, non si accoda; si aggiornano solo in `/chiudi-change`. La storia sta in `docs/changes/` e `docs/adr/`.
- **Conflitti con il contesto**: se una richiesta contraddice `SPECS.md`, `ARCHITECTURE.md` o un'ADR, segnalarlo e far decidere all'utente; non scegliere da soli.
- **Documenti brevi e precisi**: rispettare i limiti di lunghezza in `.claude/workflow.yml`. Niente elenchi di file toccati (lo dice git), niente ripetizioni tra documenti.
- **Test**: una change non è chiusa se i test unit ed e2e non sono tutti eseguiti e verdi. Comandi e layout dei test sono in `docs/ARCHITECTURE.md`, sezione "Strategia di test".
- **Modifiche banali** (refusi, rinomina, correzione di una riga): lavorare direttamente, senza change né task.
- **Parametri**: i valori in `.claude/workflow.yml` valgono sempre; gli argomenti passati a una skill hanno la precedenza sul file.
- **Change già chiuse**: non modificare i file di una change o di un'ADR chiusa senza richiesta esplicita.
