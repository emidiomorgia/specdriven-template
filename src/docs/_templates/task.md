# Modello di task (Backlog.md)

Come popolare un task creato da `/intervista-piano`. I campi vanno nei flag della CLI `backlog`.

## Titolo

Imperativo, breve, orientato al risultato verificabile.

## Descrizione (`-d`)

```
Obiettivo: <cosa deve fare il sistema al termine del task>
Change: <slug>
Perimetro: <aree/moduli/file toccabili; l'agente non esce da qui>
Dipende da: <id task, oppure nessuno>
Test attesi:
- e2e: <scenari>
- unit: <unità e comportamenti principali>
Modifiche previste (dal piano approvato):
- <file> (nuovo|modificato): <classi/funzioni e metodi>
```

Le modifiche previste sono la guida dello sviluppatore: se servono file o simboli diversi, lo dichiara come scostamento.

## Criteri di accettazione (`--ac`, uno per flag)

Comportamenti osservabili e verificabili, uno per riga. Ogni AC deve essere coperto da almeno un test.

## Definition of Done (`--dod`, uno per flag)

Standard, sempre presenti:

1. Test e2e del task scritti prima del codice, visti fallire e ora verdi.
2. Test unit delle unità pubbliche coinvolte scritti prima del codice, visti fallire e ora verdi.
3. Refactor eseguito e intera suite verde.
4. Ogni simbolo pubblico di produzione è documentato nel formato idiomatico del linguaggio.
5. Nessuna modifica fuori dal perimetro.

Specifici del task: aggiungerne solo se servono.
