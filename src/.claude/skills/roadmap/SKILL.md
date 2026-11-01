---
name: roadmap
description: Gestisce in modo interattivo il backlog delle change in docs/ROADMAP.md - mostra la roadmap, aggiunge voci con una breve intervista, propone idee (brainstorm), riordina le priorità, porta una voce da idea a pronta, scarta voci. Usare prima di avviare una change per popolare e ordinare il backlog da cui attingere.
---

# Roadmap

Si esegue nella sessione principale: richiede dialogo con l'utente. Gestisce `docs/ROADMAP.md`, il backlog delle change. **Non avvia change**: per quello c'è `intervista-piano`. Formato e significato degli stati sono nel modello `docs/_templates/ROADMAP.md`.

Argomenti (tutti facoltativi): `aggiungi [idea]`, `brainstorm`, `priorità`, `pronta R-NNN`, `scarta R-NNN`, `dettaglio R-NNN`. Senza argomenti: mostrare la roadmap e chiedere cosa fare.

## 0. Lettura

Leggere `docs/ROADMAP.md`, e per il contesto `docs/SPECS.md` (fuori scope, capacità), `docs/ARCHITECTURE.md` e le ultime voci di `docs/CHANGELOG.md`. Se `docs/ROADMAP.md` non esiste, crearlo dal modello `docs/_templates/ROADMAP.md`.

## 1. Senza argomenti: stato e scelta

Mostrare in chat la tabella "Backlog" in forma compatta (ID, change, stato, priorità, avanzamento) e indicare:

- la change in corso, se c'è;
- la **prossima voce `pronta`** in ordine di priorità;
- le voci `idea` ancora da approfondire.

Poi proporre cosa fare, come elenco breve: avviare la prossima (`/intervista-piano R-NNN`), aggiungere voci, fare brainstorm, riordinare.

## 2. `aggiungi`

Breve intervista, **massimo 3 domande per round**, con una risposta consigliata:

1. Obiettivo in una riga e perché serve ora.
2. Priorità (alta, media, bassa) e dimensione stimata (S, M, L). Se è L, proporre di spezzarla in più voci.
3. Dipendenze: da quali voci o capacità dipende.

Registrare la voce con ID `R-NNN` = massimo esistente + 1, mai riusato (anche per voci scartate o chiuse). Stato `pronta` se l'obiettivo è chiaro e verificabile, altrimenti `idea`. Colonna "Change" con il nome breve in kebab-case. Dettagli in "Dettagli" solo se servono (motivazione, vincoli, domande aperte).

## 3. `brainstorm`

Proporre **al massimo 5** voci candidate, ricavandole solo da fonti reali: le voci "Fuori scope" e "Rischi" delle change chiuse, le "Conseguenze" delle ADR, i punti aperti, ciò che l'utente ha detto in questa conversazione. Per ciascuna: obiettivo in una riga e da quale fonte nasce. Non inventare funzionalità. L'utente sceglie quali tenere; per quelle tenute fare il giro di `aggiungi` solo per ciò che manca.

## 4. `priorità`

Mostrare le voci non chiuse in ordine attuale e chiedere il nuovo ordine (anche a parole: «metti R-004 prima di R-002»). Riordinare le righe: **l'ordine delle righe è la priorità**. Aggiornare di conseguenza la colonna "Prio" se l'utente lo chiede. Controllare che nessuna voce preceda una voce da cui dipende; se succede, segnalarlo e proporre la correzione.

## 5. `pronta`, `scarta`, `dettaglio`

- `pronta R-NNN`: verificare che l'obiettivo sia una riga chiara e verificabile; se no, completarlo con una domanda. Poi stato `pronta`.
- `scarta R-NNN`: stato `scartata`, con il motivo in una riga in "Dettagli". Non cancellare la riga.
- `dettaglio R-NNN`: mostrare o completare la sezione "Dettagli" della voce, breve.

## 6. Scrittura

Prima di scrivere, riassumere in chat le modifiche (righe aggiunte, cambiate, spostate) e chiedere **un'unica conferma**. Dopo l'OK:

- modificare **solo** il testo dentro i marcatori `<!-- roadmap:inizio -->` / `<!-- roadmap:fine -->` e la sezione "Dettagli"; non toccare altro;
- aggiornare il blocco `stato` di `README.md` (riga "Prossima in roadmap") se la prossima voce `pronta` è cambiata;
- committare con un messaggio diretto in italiano (es. `Roadmap: aggiunte R-004 e R-005`), se il repository è git.

## Regole

- Gli stati `in-corso`, `in-revisione`, `chiusa` e la colonna "Avanzamento" li aggiornano `intervista-piano`, `esegui-change` e `chiudi-change`: qui non si impostano a mano, salvo correzione richiesta dall'utente.
- Una voce `pronta` ha un obiettivo verificabile in una riga; altrimenti è `idea`.
- Non inventare priorità, dimensioni o dipendenze: se l'utente non lo sa, scrivere `da definire`.
- Una voce non si cancella mai: si scarta o si chiude.
