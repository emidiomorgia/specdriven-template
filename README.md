# specdriven-template

> Un blueprint per applicare in qualsiasi progetto una pipeline di **Spec Driven Development** guidata da agenti [Claude Code](https://claude.com/claude-code).

![Licenza: MIT](https://img.shields.io/badge/licenza-MIT-green.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skill%20%26%20agenti-8A2BE2)
![Spec driven](https://img.shields.io/badge/workflow-spec--driven-blue)
![Piattaforme](https://img.shields.io/badge/piattaforme-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey)

## Indice

- [Cos'è](#cosè)
- [Perché](#perché)
- [Come funziona](#come-funziona)
- [Cosa viene installato](#cosa-viene-installato)
- [Comandi](#comandi)
- [Ruoli](#ruoli)
- [Prerequisiti](#prerequisiti)
- [Installazione rapida](#installazione-rapida)
- [Configurazione](#configurazione)
- [Stati della board](#stati-della-board)
- [Documentazione generata](#documentazione-generata)
- [Struttura del repository](#struttura-del-repository)
- [Stato del progetto e limiti noti](#stato-del-progetto-e-limiti-noti)
- [Contribuire](#contribuire)
- [Licenza](#licenza)

## Cos'è

`specdriven-template` è un pacchetto di configurazione **agnostico** (nessun linguaggio, framework o architettura prefissati) che trasforma un progetto vuoto, o già avviato, in un ambiente di lavoro spec-driven.

Uno script di setup copia nella cartella di destinazione il framework contenuto in [`src/`](src/): istruzioni di progetto (`CLAUDE.md`), **skill** e **agenti** di Claude Code, parametri del flusso, modelli di documentazione e script di installazione. Da quel momento il lavoro procede per **change**: un obiettivo che passa da intervista, piano approvato, task paralleli, sviluppo TDD, verifica indipendente, tua revisione e chiusura, con una documentazione che si accumula a ogni ciclo.

## Perché

- **Le specifiche vengono prima del codice.** Nessun file viene scritto e nessun task creato finché non approvi esplicitamente il piano.
- **Il piano nasce da un'intervista.** Domande a round, con una risposta consigliata, e segnalazione dei conflitti con specifiche, architettura e ADR esistenti. La decisione resta tua.
- **TDD sempre, a due livelli.** RED e2e → RED unit → GREEN → REFACTOR, con un commit per fase.
- **Doppia verifica.** Un agente revisore, diverso da chi ha scritto il codice, controlla ogni task. Tu controlli la change intera, una volta sola.
- **Parallelismo controllato.** Più sviluppatori lavorano insieme, ciascuno in un worktree git isolato e con un perimetro di file dichiarato.
- **Documentazione viva.** `SPECS`, `ARCHITECTURE`, `CHANGELOG`, `ROADMAP` e `README` del progetto di destinazione si aggiornano da soli ai punti di svolta del ciclo.

## Come funziona

```
 /setup-progetto  (una volta)
        │   intervista → docs generali + README + ROADMAP
        ▼
 /roadmap                                ← popoli e ordini il backlog di change
        ▼
 /intervista-piano [R-NNN]               ← scegli una voce (o descrivi un obiettivo)
        │   piano in chat → tu approvi o correggi
        │   OK → docs/changes/<change>/ + ADR + milestone + task
        ▼
 /esegui-change <slug> [--parallel N]
        │   per ogni task pronto (fino a N in parallelo):
        │   sviluppatore (worktree) → Verify → revisore ─ approvato ─► merge nel branch della change
        │                                      └─ modifiche richieste: torna allo sviluppatore
        ▼   quando TUTTI i task sono fusi
 AVVISO + PR change → main (se possibile)   ← TUA revisione della change
        │   modifiche? → task correttivi → di nuovo /esegui-change
        │   approvata  → /chiudi-change
        ▼
 /chiudi-change <slug>
            la change confluisce in SPECS / ARCHITECTURE / CHANGELOG / ROADMAP / README
            task → Done · merge in main
```

**Due livelli di verifica.** Il revisore verifica ogni *task*: se approva, il task entra subito nel branch della change. Tu verifichi la *change* intera quando tutti i task sono fusi. Solo dopo il tuo sì i task diventano `Done`.

## Cosa viene installato

L'installatore copia nel progetto di destinazione, senza mai sovrascrivere file esistenti:

```
CLAUDE.md                          principi e regole trasversali (caricato a ogni sessione)
.claude/
├── workflow.yml                   parametri: parallelismo, modelli, git, test, chiusura
├── skills/
│   ├── setup-progetto/            primo avvio: strumenti + intervista + file generali
│   ├── roadmap/                   backlog delle change
│   ├── intervista-piano/          intervista, piano, approvazione, creazione di change/ADR/task
│   ├── esegui-change/             orchestrazione parallela, revisione, merge, avviso/PR
│   ├── sviluppo-tdd/              procedura del ruolo sviluppatore
│   ├── verifica-task/             procedura del ruolo revisore
│   └── chiudi-change/             congruenza, sintesi documentale, Done, merge finale
└── agents/
    ├── sviluppatore.md            scrive codice e test nel worktree del task
    ├── revisore.md                verifica in sola lettura
    └── curatore-docs.md           scrive solo in docs/ e README.md alla chiusura
docs/
├── _templates/                    modelli di tutti i documenti
└── MANUALE-WORKFLOW.md            il manuale completo (copia di src/README.md)
scripts/
└── setup.sh / setup.bat           git + Backlog.md + cartelle del flusso
```

## Comandi

| Comando | Quando | Chi lavora |
|---|---|---|
| `/setup-progetto` | Una sola volta, all'inizio | Sessione principale |
| `/roadmap [aggiungi \| brainstorm \| priorità \| …]` | Per popolare e ordinare il backlog di change | Sessione principale |
| `/intervista-piano [R-NNN]` | Per ogni nuova change | Sessione principale |
| `/esegui-change <slug> [--parallel N]` | Dopo l'approvazione del piano; si rilancia dopo una revisione con modifiche | Orchestratore + agenti `sviluppatore` e `revisore` |
| `/chiudi-change <slug>` | Dopo la tua revisione, con tutti i task in `Change Review` | Orchestratore + agente `curatore-docs` |

Le skill `sviluppo-tdd` e `verifica-task` sono le procedure dei ruoli sviluppatore e revisore: non si invocano a mano, salvo per lavorare a un task senza orchestratore.

## Ruoli

| Ruolo | Dove lavora | Può scrivere | Modello di default |
|---|---|---|---|
| Orchestratore (sessione principale) | repository principale, branch della change | `backlog/`, `docs/`, `README.md`, git | quello della sessione |
| `sviluppatore` | worktree del proprio task | solo codice e test, nel perimetro | sonnet |
| `revisore` | worktree del task, sola lettura | niente | opus |
| `curatore-docs` | repository principale | solo `docs/` e `README.md` | sonnet |
| **Tu** | PR o branch della change | tutto | — |

Il revisore è volutamente il modello più capace: è il controllo di qualità e non ha visto come il codice è stato scritto.

## Prerequisiti

| Strumento | Perché | Note |
|---|---|---|
| [Claude Code](https://claude.com/claude-code) | esegue skill e agenti | |
| git ≥ 2.5 | branch e worktree per il parallelismo | il repository può essere solo locale |
| Node.js + npm | installa Backlog.md | solo per l'installazione |
| [Backlog.md](https://github.com/MrLesk/Backlog.md) (`backlog`) | board dei task e dell'avanzamento | `npm install -g backlog.md` |
| GitHub CLI (`gh`) + remote | PR della change verso `main` | facoltativi: senza, la revisione parte da un avviso |
| Strumenti del tuo stack | build ed esecuzione dei test | definiti nell'intervista di setup |

Gli script esistono in due versioni equivalenti: `.sh` (Linux, macOS, Git Bash, WSL) e `.bat` (Windows, cmd o PowerShell).

## Installazione rapida

Scarica o clona questo repository **fuori** dal progetto di destinazione. L'installatore va lanciato dalla cartella `src/` del blueprint, gli script di setup dalla **radice del progetto**.

**Linux / macOS / Git Bash / WSL**

```bash
# 1. dal blueprint: copia i file nel progetto (senza sovrascrivere nulla)
src/scripts/installa-blueprint.sh /percorso/nuovo-progetto

# 2. nel nuovo progetto: git + Backlog.md + cartelle
cd /percorso/nuovo-progetto
scripts/setup.sh "nome-progetto" --installa-backlog   # senza il flag se backlog è già installato

# 3. apri Claude Code nella cartella ed esegui
/setup-progetto
```

**Windows (cmd o PowerShell)**

```bat
:: 1. dal blueprint
src\scripts\installa-blueprint.bat C:\percorso\nuovo-progetto

:: 2. nel nuovo progetto
cd /d C:\percorso\nuovo-progetto
scripts\setup.bat "nome-progetto" --installa-backlog

:: 3. apri Claude Code nella cartella ed esegui /setup-progetto
```

Note:

- Se `CLAUDE.md` esiste già nel progetto, l'installatore scrive `CLAUDE.blueprint.md` da unire a mano.
- Durante `backlog init`, se chiede di creare file di istruzioni per agenti, rispondi **no**: sono già forniti dal blueprint.
- Dopo `npm install -g`, il terminale può non vedere subito `backlog`: riaprilo e rilancia lo script.

`/setup-progetto` verifica gli strumenti, ti intervista (visione, funzionale, tecnico, test, flusso) proponendo sempre un default, e genera `SPECS`, `ARCHITECTURE`, `CHANGELOG`, le ADR iniziali, il `README.md` del progetto e una `ROADMAP` con le prime voci. Quello che non sai resta `da definire`: non viene inventato.

## Configurazione

I parametri stanno in `.claude/workflow.yml` e si possono modificare in qualsiasi momento. Gli argomenti passati a una skill hanno la precedenza sul file (es. `/esegui-change mia-change --parallel 3`).

| Parametro | Default | Effetto |
|---|---|---|
| `parallelismo.max_task_paralleli` | 2 | sviluppatori contemporanei (1 = sequenziale) |
| `parallelismo.max_review_parallele` | 2 | revisori contemporanei |
| `modelli.*` | sonnet / opus / sonnet | modello per ruolo |
| `esecuzione.su_fallimento` | `ferma` | `ferma` interrompe e riporta; `continua` prosegue sui task indipendenti |
| `esecuzione.max_cicli_review` | 2 | rimandi indietro prima di passare a te |
| `esecuzione.test_dopo_merge` | `true` | suite completa dopo ogni merge di task |
| `git.pr_change` | `auto` | apre la PR change → main (serve `gh` + remote); `nessuna` solo avviso |
| `git.merge_finale` | `manuale` | `manuale` il merge in main lo fai tu; `assistito` lo esegue l'orchestratore dopo il tuo OK |
| `chiusura.pulizia_backlog` | `nessuna` | `cleanup` esegue `backlog cleanup` |
| `documentazione.max_righe_*` | 60 / 40 | limiti di lunghezza di `change.md` e ADR |

Parti da 2–3 task in parallelo: ogni agente consuma token per conto suo.

## Stati della board

Il setup configura in `backlog/config.yml` questi stati:

| Stato | Significato |
|---|---|
| `To Do` | non iniziato |
| `In Progress` | in sviluppo (o rimandato indietro) |
| `Verify` | implementato, in attesa del revisore (agente) |
| `Change Review` | approvato dal revisore e già fuso nel branch della change; in attesa della tua revisione |
| `Done` | change approvata da te e chiusa |

## Documentazione generata

| File (nel progetto di destinazione) | Contenuto | Aggiornamento |
|---|---|---|
| `README.md` | sintesi viva: stato, avanzamento, sottoprogetti, avvio rapido | blocchi gestiti, ai punti di svolta |
| `docs/SPECS.md` | cosa fa il sistema oggi | riscrittura per sezione, in chiusura |
| `docs/ARCHITECTURE.md` | com'è fatto, convenzioni, strategia di test | riscrittura per sezione, in chiusura |
| `docs/CHANGELOG.md` | una voce per change | in chiusura |
| `docs/ROADMAP.md` | backlog delle change (`R-001`, …) | `/roadmap` e il ciclo |
| `docs/changes/AAAAMMGG-slug/` | `change.md`, `plan.md`, `changelog.md` | all'approvazione del piano |
| `docs/adr/ADR-NNNN-*.md` | una decisione per file | all'approvazione del piano |

Un fatto vive in un solo posto; la storia sta nelle change e nelle ADR, i file generali descrivono solo lo stato attuale.

## Struttura del repository

```
.
├── README.md        questo file
├── LICENSE          MIT
└── src/             il blueprint che viene installato
    ├── README.md    manuale d'uso completo (diventa docs/MANUALE-WORKFLOW.md)
    ├── CLAUDE.md
    ├── .claude/     workflow.yml, skills, agents
    ├── docs/_templates/
    └── scripts/     installa-blueprint e setup (.sh / .bat)
```

Per il dettaglio di ogni fase (parallelismo, Git e PR, aggiornamento da versioni precedenti, problemi frequenti) leggi il manuale: [`src/README.md`](src/README.md).

## Stato del progetto e limiti noti

Il blueprint è stato scritto senza poterlo eseguire contro ogni installazione. Al primo utilizzo verifica in particolare:

- i flag della CLI `backlog` (assegnazione milestone, dipendenze, `--plain`) e che lo stato `Change Review` compaia nella board;
- che gli agenti `sviluppatore` lavorino correttamente nel worktree con percorsi assoluti nel tuo ambiente;
- che `esegui-change` lanci davvero più agenti nello stesso messaggio;
- il merge automatico nel branch della change e la PR finale con il tuo remote;
- gli script `.bat`: provali prima su una cartella vuota.

Skill, agenti e modelli sono semplici file di testo, pensati per essere adattati.

## Contribuire

I contributi sono benvenuti.

1. Apri una issue per segnalare un problema o proporre una modifica.
2. Crea un branch dal `main` e prepara una pull request con una descrizione chiara.
3. Se modifichi una skill, un agente o un modello, tieni coerenti `src/README.md` e `src/CLAUDE.md`.
4. Gli script `.sh` e `.bat` devono restare equivalenti; nei `.bat` i testi sono senza accenti per evitare problemi di codepage.
5. Documentazione, skill e commit sono in italiano.

## Licenza

Distribuito con licenza [MIT](LICENSE) © 2026 Emidio Morgia.
