# Blueprint spec-driven con agenti — manuale d'uso

Pacchetto di configurazione agnostico (nessun linguaggio, framework o architettura prefissati) per avviare un nuovo progetto con un flusso **spec-driven**: roadmap → intervista → piano approvato → task paralleli → sviluppo TDD → verifica del revisore → revisione tua → chiusura, con documentazione che si accumula.

Una volta installato nel progetto, questo file diventa `docs/MANUALE-WORKFLOW.md`.

## 1. Il flusso in breve

```
 /setup-progetto  (una volta)
        │   intervista → docs generali + README + ROADMAP
        ▼
 /roadmap                                ← popoli e ordini il backlog di change (quando vuoi)
        ▼
 /intervista-piano [R-NNN]               ← scegli una voce (o descrivi un obiettivo), rispondi alle domande
        │   piano in chat → tu approvi o correggi
        │   OK → docs/changes/<change>/ + ADR + milestone + task + roadmap "in-corso"
        ▼
 /esegui-change <slug> [--parallel N]
        │   ┌──────────── per ogni task pronto (fino a N in parallelo) ─────────────┐
        │   │ sviluppatore (worktree) → Verify → revisore ─ approvato ─► merge nel   │
        │   │                                         branch della change →          │
        │   │                                         "Change Review"                │
        │   └───────── modifiche richieste: torna allo sviluppatore ─────────────────┘
        ▼   quando TUTTI i task sono fusi
 AVVISO + PR change → main (se possibile)   ← TUA revisione della change
        │   modifiche? → task correttivi → di nuovo /esegui-change
        │   approvata  → /chiudi-change
        ▼
 /chiudi-change <slug>
            curatore-docs: la change confluisce in SPECS / ARCHITECTURE / CHANGELOG / ROADMAP / README
            task → Done · merge in main (tuo, o assistito)
```

**Due livelli di verifica.** Il revisore (agente) verifica ogni *task*: se approva, il task entra subito nel branch della change. Tu verifichi la *change* intera, una volta sola, quando tutti i task sono fusi. Solo dopo il tuo sì i task diventano `Done`.

I file generali sono il contesto di ogni change successiva: ogni change li legge, e solo la chiusura li aggiorna.

## 2. Contenuto del pacchetto

```
CLAUDE.md                          principi e regole trasversali (snello, caricato a ogni sessione)
README.md                          questo manuale
.claude/
├── workflow.yml                   parametri: parallelismo, modelli, git, test, chiusura, limiti dei documenti
├── skills/
│   ├── setup-progetto/            primo avvio: strumenti + intervista + file generali + README + ROADMAP
│   ├── roadmap/                   backlog delle change: aggiungi, brainstorm, priorità, pronta, scarta
│   ├── intervista-piano/          intervista, piano, approvazione, creazione di change/ADR/task
│   ├── esegui-change/             orchestrazione parallela, revisione, merge nel branch della change, avviso/PR
│   ├── sviluppo-tdd/              procedura del ruolo sviluppatore (RED e2e → RED unit → GREEN → REFACTOR)
│   ├── verifica-task/             procedura del ruolo revisore
│   └── chiudi-change/             congruenza, sintesi documentale, Done, merge finale
└── agents/
    ├── sviluppatore.md            scrive codice e test nel worktree del task
    ├── revisore.md                verifica in sola lettura
    └── curatore-docs.md           scrive solo in docs/ e README.md alla chiusura
docs/_templates/                   modelli: README, SPECS, ARCHITECTURE, CHANGELOG, ROADMAP, change, plan,
                                   changelog-change, adr, task
scripts/
├── installa-blueprint.sh / .bat   copia il blueprint in un progetto senza sovrascrivere nulla
└── setup.sh / .bat                git + Backlog.md (installazione, init, stati della board) + cartelle
```

## 3. Prerequisiti

| Strumento | Perché | Note |
|---|---|---|
| Claude Code | esegue skill e agenti | |
| git (≥ 2.5) | branch e **worktree** per il parallelismo | il repo può essere solo locale |
| Node.js + npm | installa Backlog.md | solo per l'installazione |
| Backlog.md (`backlog`) | board dei task e dell'avanzamento | `npm install -g backlog.md` |
| GitHub CLI (`gh`) + remote | PR della change verso main | facoltativi: senza, la revisione parte da un avviso |
| Strumenti del tuo stack | build ed esecuzione dei test | definiti nell'intervista di setup |

Gli script esistono in due versioni equivalenti: `.sh` (Linux, macOS, Git Bash, WSL) e `.bat` (Windows, cmd o PowerShell). Il `.bat` usa `robocopy` e PowerShell, presenti in Windows. Nei file `.bat` i testi sono volutamente senza accenti per evitare problemi di codepage.

## 4. Installazione in un nuovo progetto

Lo zip contiene una cartella `blueprint-sdd/`: scompattala **fuori** dal progetto e punta l'installatore alla cartella del progetto. Gli script di setup vanno lanciati dalla **radice del progetto**.

**Linux / macOS / Git Bash / WSL**

```bash
# 1. dalla cartella del blueprint
blueprint-sdd/scripts/installa-blueprint.sh /percorso/nuovo-progetto

# 2. nel nuovo progetto
cd /percorso/nuovo-progetto
scripts/setup.sh "nome-progetto" --installa-backlog   # senza il flag se backlog è già installato

# 3. apri Claude Code nella cartella ed esegui
/setup-progetto
```

**Windows (cmd o PowerShell)**

```bat
:: 1. dalla cartella del blueprint
blueprint-sdd\scripts\installa-blueprint.bat C:\percorso\nuovo-progetto

:: 2. nel nuovo progetto
cd /d C:\percorso\nuovo-progetto
scripts\setup.bat "nome-progetto" --installa-backlog

:: 3. apri Claude Code nella cartella ed esegui /setup-progetto
```

Dopo `npm install -g`, il terminale può non vedere subito `backlog`: lo script lo segnala, basta riaprire il terminale e rilanciarlo. Durante `backlog init`, se chiede di creare file di istruzioni per agenti, rispondi **no**: sono già forniti dal blueprint.

L'installatore non sovrascrive mai: se `CLAUDE.md` esiste già, scrive `CLAUDE.blueprint.md` da unire a mano. In alternativa puoi copiare a mano `CLAUDE.md`, `.claude/`, `docs/_templates/` e `scripts/`.

## 5. Primo avvio: `/setup-progetto`

Verifica gli strumenti, poi ti intervista a round (visione, funzionale, tecnico con sottoprogetti, test, flusso) proponendo sempre un default. Quello che non sai o non vuoi decidere ora resta `da definire`, non viene inventato. Prima di scrivere ti mostra una sintesi e chiede un'unica conferma. Genera:

- `docs/SPECS.md`, `docs/ARCHITECTURE.md` (con la strategia di test completa: comandi, layout, naming), `docs/CHANGELOG.md`;
- le ADR iniziali (stack, strategia di test, scelte portanti);
- `README.md` nella radice: stato del progetto, tabella dei **sottoprogetti**, avvio rapido, test, struttura;
- `docs/ROADMAP.md` con 2–5 voci (`R-001`, …), la prima di fondamenta (scheletro eseguibile con test e2e funzionante);
- la sezione "Contesto" di `CLAUDE.md` e i parametri scelti in `workflow.yml`.

Poi ti chiede quale voce avviare e passa a `/intervista-piano`.

## 6. Roadmap e README

### 6.1 `docs/ROADMAP.md` — il backlog delle change

Una tabella di voci con ID stabile (`R-001`…), obiettivo in una riga, priorità, dimensione, dipendenze, **stato**, **avanzamento** (task fusi / totali) e link alla change o alla PR. **L'ordine delle righe è la priorità.**

| Stato | Chi lo imposta |
|---|---|
| `idea`, `pronta`, `scartata` | tu, con `/roadmap` |
| `in-corso` | `/intervista-piano`, all'approvazione del piano |
| `in-revisione` | `/esegui-change`, quando tutti i task sono fusi |
| `chiusa` | `/chiudi-change` (la riga passa in "Chiuse") |

Si usa con `/roadmap`: senza argomenti mostra lo stato e la prossima voce pronta; `aggiungi` fa una breve intervista (obiettivo, priorità e dimensione, dipendenze); `brainstorm` propone al massimo 5 voci ricavate solo da fonti reali (fuori scope, rischi, conseguenze delle ADR); `priorità` riordina; `pronta` e `scarta` cambiano stato. Prima di scrivere ti riassume le modifiche e chiede un'unica conferma. Poi si parte con `/intervista-piano R-NNN`.

### 6.2 `README.md` — la sintesi viva del progetto

Il README di tipo GitHub, sempre aggiornato, con:

- **Stato del progetto** (blocco gestito): change in corso, ultima chiusa, prossima in roadmap e una **tabella di avanzamento rispetto al piano** (ID, change, stato, task fusi/totali, PR);
- **Sottoprogetti** (blocco gestito): per ciascuno percorso, tecnologia, stato (`da avviare`, `scheletro`, `in sviluppo`, `stabile`), come si avvia e si testa, ultima change che l'ha toccato;
- avvio rapido, test, struttura del repository, indice della documentazione.

Le parti dentro i marcatori `<!-- … -->` le aggiorna il flusso; **il testo fuori è tuo** e non viene riscritto. Quando si aggiorna: all'approvazione del piano, quando i task sono tutti fusi, alla chiusura. Lo stato dei singoli task, minuto per minuto, resta nella board di Backlog.md.

## 7. Una change, passo per passo

### 7.1 `/intervista-piano [R-NNN]`

Parti da una voce di roadmap o descrivi un obiettivo. Il sistema legge il contesto, ti intervista (round da massimo 4 domande, con risposta consigliata) e segnala qualsiasi conflitto con specifiche, architettura o ADR esistenti: la decisione resta tua. Poi presenta il piano in chat: obiettivo, comportamento atteso, fuori scope, ADR candidate, **tabella dei task** (dipendenze, perimetro, scenari e2e), **modifiche previste**, parallelismo, rischi. Le modifiche previste elencano, per ogni task, tutti i file nuovi o modificati (test compresi) con le classi/funzioni e i metodi che si intende realizzare: puoi correggerle riga per riga prima dell'OK. Diventano una guida per lo sviluppatore e un riferimento per il revisore, che verifica gli scostamenti.

Puoi correggerlo quante volte vuoi. **Finché non dai un OK esplicito non viene scritto nulla.** Dopo l'OK, nello stesso passaggio:

- `docs/changes/AAAAMMGG-slug/` con `change.md`, `plan.md`, `changelog.md`;
- le ADR in `docs/adr/`;
- il milestone e i task in Backlog.md (con AC, DoD, perimetro, dipendenze);
- la voce di roadmap `in-corso` (creata se non esisteva) e il README aggiornato;
- il branch `change/<slug>`.

### 7.2 `/esegui-change <slug> [--parallel N]`

La sessione principale diventa orchestratore e ripete questo ciclo:

1. sceglie i task **pronti** (To Do, dipendenze già fuse, perimetro libero), fino al tetto di parallelismo;
2. per ognuno crea un **worktree** e lancia un agente `sviluppatore` in background;
3. quando uno termina, aggiorna Backlog.md (note, final-summary, AC/DoD) e porta il task in **Verify**;
4. lancia il `revisore` (contesto separato, sola lettura);
5. **Approvato** → l'orchestratore fonde subito il task nel branch della change, esegue la suite completa (`test_dopo_merge`), porta il task in **Change Review** e rimuove worktree e branch del task. **Modifiche richieste** → torna allo sviluppatore, fino a `max_cicli_review`, poi passa a te;
6. riempie gli slot liberi e ti mostra una riga di stato dopo ogni evento.

Quando **tutti** i task sono in `Change Review`, la skill: rilancia la suite sul branch della change, aggiorna roadmap (`in-revisione`) e README, apre la **PR change → main** (con `gh` e un remote; altrimenti nessuna PR) e **ti avvisa** con il link alla PR o con i comandi per riguardare le differenze. Poi si ferma.

### 7.3 La tua revisione della change

Rivedi la change nel suo insieme, dalla PR oppure con `git diff <principale>...change/<slug>`. Due esiti:

- **Approvi** → `/chiudi-change <slug>`.
- **Chiedi modifiche** → le descrivi in chat (o riassumi i commenti della PR). L'orchestratore le trasforma in **task correttivi** (`Fix revisione: …`) nel milestone, e rilanci `/esegui-change <slug>`: stesso ciclo, stesso branch. I task già fusi restano in `Change Review`; la PR si aggiorna da sola.

### 7.4 `/chiudi-change <slug>`

Richiede tutti i task in `Change Review`, la tua conferma e la suite verde. Controlla la congruenza tra `change.md`/`plan.md` e il codice, poi il `curatore-docs` riscrive le sezioni di `SPECS.md` e `ARCHITECTURE.md` toccate, compila il changelog locale, aggiunge la voce a `CHANGELOG.md`, chiude la riga di roadmap e aggiorna il README (stato e sottoprogetti). Poi i task passano a `Done` (task e milestone **restano visibili** nel backlog), si fa il commit e il push dei documenti e la change va in `main`: con `merge_finale: manuale` il merge lo fai tu (dalla PR o in locale), con `assistito` lo esegue l'orchestratore dopo un ultimo tuo OK.

## 8. Ruoli

| Ruolo | Dove lavora | Può scrivere | Modello di default |
|---|---|---|---|
| Orchestratore (sessione principale) | repository principale, branch della change | `backlog/`, `docs/`, `README.md`, git | quello della sessione |
| `sviluppatore` | worktree del proprio task | solo codice e test, nel perimetro | sonnet |
| `revisore` | worktree del task, sola lettura | niente | opus |
| `curatore-docs` | repository principale | solo `docs/` e `README.md` | sonnet |
| **Tu** | PR o branch della change | tutto | — |

I modelli si cambiano in `workflow.yml`. Il revisore è volutamente il più capace: è il controllo di qualità, e non ha visto come il codice è stato scritto.

## 9. Parametri (`.claude/workflow.yml`)

| Parametro | Default | Effetto |
|---|---|---|
| `parallelismo.max_task_paralleli` | 2 | sviluppatori contemporanei (1 = sequenziale). È un tetto |
| `parallelismo.max_review_parallele` | 2 | revisori contemporanei, contati a parte |
| `modelli.*` | sonnet / opus / sonnet | modello per ruolo |
| `esecuzione.su_fallimento` | `ferma` | `ferma` interrompe e riporta; `continua` prosegue sui task indipendenti |
| `esecuzione.max_cicli_review` | 2 | rimandi indietro prima di passare a te |
| `esecuzione.test_dopo_merge` | `true` | suite completa sul branch della change dopo ogni merge di task |
| `git.pr_change` | `auto` | `auto` apre la PR change → main quando i task sono tutti fusi (serve `gh` + remote); `nessuna` solo avviso |
| `git.merge_finale` | `manuale` | `manuale` il merge in main lo fai tu; `assistito` lo esegue l'orchestratore dopo il tuo OK |
| `chiusura.pulizia_backlog` | `nessuna` | `nessuna` lascia task e milestone visibili; `cleanup` esegue `backlog cleanup` |
| `documentazione.max_righe_*` | 60 / 40 | limiti di lunghezza di `change.md` e ADR |

Un argomento sul comando vince sul file: `/esegui-change mia-change --parallel 3`. `workflow.yml` non è un file standard di Claude Code: lo leggono le skill del blueprint.

## 10. Parallelismo: come funziona davvero

Non c'è una "squadra" autonoma: c'è un orchestratore che lancia più agenti, ciascuno con contesto isolato, prompt di ruolo e un **worktree** git proprio, e che raccoglie i loro report. Perché regga:

- **Perimetri disgiunti.** Il piano dichiara per ogni task le aree toccate; due task che si sovrappongono diventano sequenziali. È la causa principale di conflitti: se vedi molte dipendenze "forzate", la scomposizione era troppo larga.
- **Merge uno alla volta.** Dopo l'approvazione del revisore l'orchestratore fonde i task nel branch della change in sequenza, e con `test_dopo_merge` verifica che l'insieme resti verde. Un conflitto o una suite rossa fermano quel task, non gli altri.
- **Un solo scrittore per `backlog/`, `docs/` e `README.md`.** Gli sviluppatori non li toccano: così i worktree paralleli non confliggono.
- **I file generali si aggiornano solo in chiusura**, da un solo agente.
- **Le dipendenze richiedono integrazione.** Un task dipendente parte solo quando quello da cui dipende è già nel branch della change, cioè in `Change Review`.
- **Test paralleli.** Ogni worktree esegue la propria suite: evita porte fisse e risorse condivise nei test (usa ambienti effimeri o porte dinamiche).
- **Costo.** Ogni agente consuma token per conto suo: parti da 2–3 in parallelo e osserva.

## 11. Backlog.md

**Nessuna modifica al sorgente di Backlog.md**: serve un solo cambio di configurazione, fatto da `scripts/setup.sh` / `setup.bat`. In `backlog/config.yml`:

```yaml
statuses: ["To Do", "In Progress", "Verify", "Change Review", "Done"]
```

| Stato | Significato |
|---|---|
| `To Do` | non iniziato |
| `In Progress` | lo sta sviluppando uno sviluppatore (o è stato rimandato indietro) |
| `Verify` | implementato, in attesa del **revisore** (agente) |
| `Change Review` | approvato dal revisore **e già fuso nel branch della change**; in attesa della **tua** revisione della change |
| `Done` | change approvata da te e chiusa |

Non c'è un comando per cambiare l'elenco degli stati: si modifica il file (lo fa lo script; `esegui-change` lo aggiunge da sé se manca).

Uso previsto: **milestone = change**; task con descrizione (obiettivo, perimetro, dipendenze, test attesi), AC e DoD; note con prefisso (`[SVILUPPATORE]`, `[REVISORE]`, `[ORCHESTRATORE]`) che formano un thread leggibile; `final-summary` = riga di changelog del task. A fine change task e milestone **restano visibili** (task in `Done`).

Comandi usati dalle skill:

| Scopo | Comando |
|---|---|
| Milestone | `backlog milestone add "<slug>"` |
| Creare task | `backlog task create "<titolo>" -d "<desc>" --ac "<…>" --dod "<…>"` |
| Stato | `backlog task edit <id> -s "In Progress"` / `Verify` / `"Change Review"` / `Done` |
| Note e riepilogo | `--append-notes "<…>"` · `--final-summary "<…>"` |
| Spuntare | `--check-ac <n>` · `--check-dod <n>` |
| Vedere | `backlog task list --plain` · `backlog board` · `backlog browser` |
| Vedere i milestone | `backlog milestone list --plain` (`--show-completed` per i completati) |
| Pulizia opzionale | `backlog cleanup` (sposta i task Done fuori dalla board; non usare `task archive`, pensato per task annullati) |

I flag per **assegnare il milestone**, per le **dipendenze** e l'opzione `--plain` dipendono dalla versione installata: verificali una volta con `backlog task create --help` e `backlog task list --help`. Le skill si adattano (se un flag manca, le dipendenze finiscono nella descrizione come `Dipende da: <id>`). Regola: mai modificare a mano `backlog/tasks/*.md`.

Backlog.md ha una sezione documenti propria (`backlog doc`), ma non può puntare a `docs/`: la documentazione del progetto resta in `docs/` e nel README, non nella board.

## 12. Documentazione

| File | Contenuto | Come si aggiorna |
|---|---|---|
| `README.md` | sintesi viva: stato, avanzamento, sottoprogetti, avvio rapido | blocchi gestiti: piano approvato, task fusi, chiusura |
| `docs/SPECS.md` | cosa fa il sistema oggi | riscrittura per sezione, in chiusura |
| `docs/ARCHITECTURE.md` | com'è fatto oggi, convenzioni, strategia di test | riscrittura per sezione, in chiusura |
| `docs/CHANGELOG.md` | una voce per change | in testa, in chiusura |
| `docs/ROADMAP.md` | backlog delle change | `/roadmap` e i punti di svolta del ciclo |
| `docs/changes/<change>/` | `change.md` (delta), `plan.md` (piano approvato), `changelog.md` (una riga per task) | creata all'approvazione del piano, chiusa a fine change |
| `docs/adr/ADR-NNNN-*.md` | una decisione per file, numerazione mai riusata | creata all'approvazione del piano |

Criteri di scrittura: dettagliata e precisa ma poco prolissa; limiti di righe in `workflow.yml`; un fatto vive in un solo posto (le tabelle di sintesi del README derivano da roadmap e sottoprogetti); niente elenchi di file toccati; storia nelle change e nelle ADR, non nei file generali.

## 13. TDD

Per ogni task, nell'ordine e senza saltare passi:

1. **RED e2e** — test del caso d'uso, visti fallire per il motivo atteso.
2. **RED unit** — test delle unità pubbliche, visti fallire.
3. **GREEN** — codice minimo; suite verde.
4. **REFACTOR** — migliorie a comportamento invariato, suite sempre verde; simboli pubblici documentati.

Un commit per fase: il revisore li usa per verificare che i test precedano il codice. Un test non si modifica per farlo passare. Layout, naming e comandi concreti sono in `docs/ARCHITECTURE.md`, decisi in `/setup-progetto`.

## 14. Git e PR

- `change/<slug>` dal branch principale; `task/<id>-<slug>` dal branch della change (un worktree per task, in `cartella_worktree`). **Il branch è per task, non per skill o ruolo.**
- Dopo l'approvazione del revisore il task viene **fuso nel branch della change** (merge locale `--no-ff`, senza PR per task) e il suo worktree e branch vengono rimossi.
- A task tutti fusi: PR **change → main** (se `pr_change: auto`, con `gh` e un remote), su cui fai la tua revisione. Senza PR ricevi un avviso con i comandi git per riguardare le differenze.
- Il merge in `main` è tuo (`manuale`) oppure dell'orchestratore dopo il tuo OK (`assistito`).
- L'orchestratore non fa operazioni distruttive: un merge che rompe i test si annulla con `git revert`, mai con `reset --hard`.
- Chi lavora dove:

| Ruolo | Branch / worktree | Accesso |
|---|---|---|
| `sviluppatore` (uno per task) | `task/<id>-<slug>`, worktree dedicato | scrive codice e test |
| `revisore` | lo stesso `task/<id>-<slug>` del task che verifica | sola lettura |
| `curatore-docs` | `change/<slug>` (checkout principale) | scrive solo `docs/` e `README.md` |
| Orchestratore | `change/<slug>` (checkout principale) | `backlog/`, `docs/`, `README.md`, git |

- Consiglio: tieni **una change alla volta**. Più change in parallelo moltiplicano i conflitti sui file generali e sul contesto.

## 15. Aggiornare un progetto già avviato con una versione precedente del blueprint

L'installatore non sovrascrive: l'aggiornamento è una copia mirata. Dal nuovo blueprint copia nel progetto, sostituendoli:

- `.claude/skills/esegui-change/SKILL.md`, `chiudi-change/SKILL.md`, `intervista-piano/SKILL.md`, `setup-progetto/SKILL.md`, `verifica-task/SKILL.md`;
- `.claude/skills/roadmap/` (nuova cartella);
- `.claude/agents/curatore-docs.md`;
- `docs/_templates/` (tutti i modelli, tra cui il nuovo `README.md`);
- `docs/MANUALE-WORKFLOW.md` (da questo file);
- `scripts/setup.sh` e `scripts/setup.bat`.

Poi, a mano:

1. In `backlog/config.yml` aggiungi lo stato `Change Review` tra `Verify` e `Done` (altrimenti lo aggiunge `esegui-change` alla prima esecuzione).
2. In `.claude/workflow.yml` (**non sostituirlo**, contiene i tuoi valori):
   - togli `git.integrazione_task`, `git.pr_task_verso`, `git.merge_pr_task`, `approvazioni.verifica_umana_task`, `approvazioni.pr_finale`;
   - aggiungi `esecuzione.test_dopo_merge: true`, `git.pr_change: auto`, `git.merge_finale: manuale`;
   - tieni `branch_change`, `branch_task`, i tetti di parallelismo e i modelli.
3. Nel `CLAUDE.md` del progetto aggiorna le sezioni Approccio, Struttura, Comandi e Regole con quelle del nuovo `CLAUDE.md`, lasciando intatta la sezione "Contesto del progetto".
4. Crea `README.md` dalla radice (modello in `docs/_templates/README.md`) e converti `docs/ROADMAP.md` nel nuovo formato (`/roadmap` può farlo con te). Le change già chiuse si registrano nella tabella "Chiuse".

Le change in corso con il flusso vecchio si possono portare a termine con quello nuovo: i task già `Done` restano tali.

## 16. Problemi frequenti

| Sintomo | Causa probabile | Cosa fare |
|---|---|---|
| Nessun task parte | dipendenze non ancora fuse o perimetri sovrapposti | controlla `plan.md`; un task dipendente parte solo quando il precedente è in `Change Review` |
| Un task resta in `Verify` con nota "conflitto di merge" | il suo codice confligge con task già fusi | risolvi il conflitto (o rimanda il task allo sviluppatore) e rilancia `/esegui-change` |
| Un task torna in `In Progress` con "suite rossa dopo il merge" | l'integrazione con gli altri task rompe i test | è normale: lo sviluppatore risolve l'integrazione; conta come ciclo di review |
| Il flusso si ferma su un task | `su_fallimento: ferma` | leggi il report, correggi, rilancia `/esegui-change` (riparte dai task To Do/In Progress) |
| Il revisore rimanda sempre indietro | AC vaghi o test deboli | rivedi gli AC del task, poi rilancia |
| Non arriva nessuna PR | `pr_change: nessuna`, `gh` assente o niente remote | usa i comandi git dell'avviso; per la PR configura remote e `gh` |
| `/chiudi-change` si rifiuta di partire | ci sono task non in `Change Review` | `backlog board`: porta a termine o correggi i task mancanti |
| La board non mostra `Change Review` | `config.yml` non aggiornato | rilancia `scripts/setup.sh` / `setup.bat` oppure aggiungilo a mano agli stati |
| Test che si disturbano a vicenda | risorse condivise (porte, DB) | ambienti effimeri o porte dinamiche nei test |
| Un flag `backlog` non è riconosciuto | versione diversa | `backlog <comando> --help` e adatta la skill |

## 17. Cose da verificare al primo uso

Il blueprint è stato scritto senza poterlo eseguire contro ogni installazione. Al primo progetto controlla in particolare:

1. i flag di `backlog` elencati al punto 11, e che lo stato `Change Review` compaia nella board;
2. che gli agenti `sviluppatore` riescano a lavorare nel worktree con percorsi assoluti nel tuo ambiente;
3. che `esegui-change` lanci davvero più agenti nello stesso messaggio (lo vedi dalla lista dei task attivi);
4. che il merge automatico nel branch della change e la PR finale si comportino come atteso con il tuo remote;
5. gli script `.bat`: provali su una cartella vuota prima di usarli su un progetto vero;
6. lunghezza e tono dei documenti generati: se non ti convincono, correggi i modelli in `docs/_templates/` e i "criteri di scrittura" nelle skill.

Il flusso è pensato per essere ritoccato: skill, agenti e modelli sono semplici file di testo.
