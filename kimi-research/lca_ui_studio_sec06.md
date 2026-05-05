## 6. Mockup Concettuali e Roadmap

I principi di design delineati nel Capitolo 5 — Intent-First, Search-First, Reversibile, Multiple Views, AI Grounding, Keyboard-First e Progressive Disclosure — rimangono affermazioni normative finché non vengono tradotti in interfacce concrete, percorsi utente misurabili e decisioni di prioritizzazione tecnica. Questo capitolo compie proprio quel passo: trasforma i principi astratti in mockup testuali, storyboard end-to-end, una tabella MoSCoW, uno stack tecnologico specifico e un'analisi dei rischi principali. L'obiettivo non è produrre specifiche di ingegneria esaustive, bensì fornire un ponte sufficientemente solido tra design e implementazione — un blueprint da cui un team di sviluppo possa derivare task concreti.

I mockup seguono una convenzione wireframe testuale strutturata: ogni schermata è descritta attraverso la sua gerarchia di componenti, i flussi di interazione principali e i vincoli di design derivati dai principi del Capitolo 5. Gli storyboard tracciano tre user journey rappresentative dei profili identificati nella ricerca — un analista junior che deve produrre risultati rapidamente, un esperto che adatta modelli complessi a nuovi scenari, un revisore che audita un modello consegnato da terzi. La tabella MoSCoW sintetizza le feature differenzianti in quattro fasce di priorità con stime temporali. Lo stack tecnologico propone scelte concrete per ogni layer architetturale. L'analisi dei rischi conclude con un quadro realistico degli ostacoli all'adozione, alla compliance e alle performance.

### 6.1 Wireframe Testuali delle 5 Schermate Chiave

Il wireframe testuale come formato di specificazione ha un vantaggio distintivo rispetto ai mockup grafici ad alta fedeltà: forza il designer a ragionare sui flussi di interazione e sulla gerarchia informativa piuttosto che sulla forma visiva, riducendo il rischio che decisioni estetiche premature mascherino problemi di usabilità strutturali [^649^]. Ogni wireframe qui presentato include una descrizione della disposizione spaziale, un elenco dei componenti interattivi, i flussi di uscita principali e una nota di tracciabilità che collega le scelte ai principi del Capitolo 5.

#### 6.1.1 Home / Project Overview

La schermata Home incarna il principio Intent-First: l'utente non viene accolto da un canvas vuoto che richiede configurazione, ma da una dashboard che risponde alla domanda implicita "Cosa devo fare oggi?". Il layout segue una struttura a tre zone verticali con densità informativa decrescente dal basso verso l'alto, ispirata alla disciplina information hierarchy di Linear [^653^].

```
+-----------------------------------------------------------------------------+
|  [Logo]  Home   [KK] Search anything...                    [*] [ Profile]  |
+-----------------------------------------------------------------------------+
|                                                                             |
|  +------------------------------+  +-------------------------------------+  |
|  |  Quick Actions               |  |  Active Projects (5)                |  |
|  |                              |  |  +----------+ +----------+         |  |
|  |  [+] New Study               |  |  | Bottiglia| | Packaging|         |  |
|  |  [+] Import BOM              |  |  | PET v2   | | redesign |         |  |
|  |  [O] Search Database        |  |  | * 87%   |  | * 34%    |         |  |
|  |  [*] Continue Last Session  |  |  | GWP: 2.1 |  | GWP: N/A |         |  |
|  |                              |  |  | kg CO2e  |  | (draft)  |         |  |
|  |  ----------------------------  |  |  +----------+ +----------+         |  |
|  |  AI Suggestions              |  |  [+ New Project] [View All ->]      |  |
|  |  +------------------------+  |  +-------------------------------------+  |
|  |  | "Complete EOL phase in |  |                                           |
|  |  |  Bottiglia PET v2. Add |  |  +-------------------------------------+  |
|  |  |  recycling process?"   |  |  |  Recent Activity                      |  |
|  |  |  [Apply] [Dismiss]     |  |  |  * You edited "electricity mix" 2h ago|  |
|  |  +------------------------+  |  |  * AI mapped 12 flows in "Packaging"  |  |
|  |  +------------------------+  |  |  * Reviewer commented on "bottiglia"  |  |
|  |  | "Switch to Italian grid |  |  |  * Calculation completed for v2.1     |  |
|  |  |  mix? Current: EU avg"  |  |  +-------------------------------------+  |
|  |  |  [Review] [Keep Current]|  |                                           |
|  |  +------------------------+  |  +-------------------------------------+  |
|  |                              |  |  Metrics at a Glance                  |  |
|  +------------------------------+  |  +----------+ +----------+ +--------+ |  |
|                                    |  | Studies  | | Processes| | Impact | |  |
|                                    |  |   12     | |  1,247   | |  8.4t  | |  |
|                                    |  | this mo  | | this mo  | | CO2e   | |  |
|                                    |  +----------+ +----------+ +--------+ |  |
|                                    +-------------------------------------+  |
+-----------------------------------------------------------------------------+
```

**Componenti interattivi.** La barra di ricerca globale in alto (attivabile con `KK`) funge da entry point unificato per tutte le operazioni — progetti, processi, database, azioni — seguendo il pattern della command palette universale [^668^]. La sezione Quick Actions offre scorciatoie per le operazioni più frequenti, calcolate dal sistema in base alla cronologia dell'utente (approccio *suggested actions* analogo a ChatGPT e Raycast [^669^]). I card progetti nella zona centrale mostrano progresso di completamento (indicatore circolare), impatto GWP calcolato più recentemente e stato del modello (*draft*, *in review*, *completed*). La sidebar AI Suggestions presenta raccomandazioni contestuali con azioni rapide *Apply* o *Dismiss*, implementando il pattern *Human-in-the-Loop* richiesto per la governance dei suggerimenti algoritmici [^674^].

**Flussi di uscita.** Click su progetto → schermata Modellazione (6.1.2). Click su *Import BOM* → schermata AI-Assisted Data Collection (6.1.5). `KK` → command palette overlay. Click su notifica reviewer → schermata Review Mode.

**Tracciabilità principi.** Intent-First (dashboard risponde all'intento implicito), AI Grounding (suggerimenti con azioni esplicite di accettazione/rifiuto), Progressive Disclosure (Quick Actions si adattano alla storia dell'utente).

#### 6.1.2 Modellazione Product System

Questa schermata è il nucleo dell'esperienza LCA: un canvas node-based con editing interattivo, ispirato al paradigma ibrido canvas+command palette emerso dalla ricerca [^714^]. Il design affronta direttamente le critiche ai tool legacy — SimaPro considerato "time-consuming and complex" con "greater complexity and less practicality" [^17^], openLCA con "visualization can become cluttered and difficult to read" quando gli elementi sono molti — attraverso tre meccanismi: (1) una command palette universale che rende ogni azione accessibile in <3 secondi, (2) una mini-mappa per navigare modelli grandi senza perdita di orientamento, (3) un pannello AI laterale che assiste senza interferire con il flusso di modellazione.

```
+-----------------------------------------------------------------------------+
|  [<- Back]  Bottiglia PET v2   [Saved 2m ago]   [Share] [Export] [O]       |
+----------+------------------------------------------------------+-----------+
|          |                                                      |           |
|  PALETTE |  CANVAS (node-based graph editor)                    |  AI       |
|          |                                                      |  PANEL    |
|  Search  |  +----------+      +----------+      +----------+   |           |
|  [______]|  |Production|===>  | Transport|===>  |  Use     |   |  "Why does|
|          |  |  PET     |      |  road     |      |  Phase   |   | Production|
|  +------+|  |  2.1 kg  |      |  0.3 kg   |      |  0.1 kg  |   | PET have  |
|  | *    ||  |          |      |           |      |          |   | such high |
|  | Elec ||  +----+-----+      +-----+-----+      +-----+-----+   | GWP?"     |
|  | Mix  ||       |                 |                 |         |           |
|  | 0.8  ||       v                 v                 v         |  [Explain]|
|  +------+|  +----------+      +----------+      +----------+   |           |
|  +------+|  | Raw Mat  |      | Factory  |      | Disposal |   |  Suggest: |
|  | +    ||  | Ethylene |      | Energy   |      |  (empty) |   |  [Add     |
|  | Water||  |  1.2 kg  |      |  0.4 kg  |      |          |   |  recycling|
|  | 0.05 ||  +----------+      +----------+      +----------+   |  process] |
|  +------+|                                                      |           |
|  +------+|  ------------------------------------------------    |  Sources: |
|  | +    ||  MINI-MAP                                          |  ecoinvent|
|  | Trans||  +-----------------------------------------------+  |  3.9, EF  |
|  | 0.3  ||  | [***]    [*]         [**]       |               |  3.1      |
|  +------+|  | [*]      [***]       [*]        |               |           |
|          |  |           +------+              |               |  [K+L     |
|  [+ Add  |  |           | View |              |               |  Expand]  |
|  Process]|  +-----------+------+--------------+               |           |
|          |                                                      |           |
|          |  Selected: Production PET                             |           |
|          |  +------------------------------+                    |           |
|          |  | Name: Production PET        [Edit]                |           |
|          |  | GWP: 2.1 kg CO2e            [Copy]                |           |
|          |  | Source: ecoinvent 3.9        [Delete]             |           |
|          |  | Location: Italy (IT)         [Details ->]         |           |
|          |  +------------------------------+                    |           |
+----------+------------------------------------------------------+-----------+
```

**Componenti interattivi.** La Palette laterale sinistra elenca i processi disponibili filtrabili via search box; ogni elemento è draggabile sul canvas o aggiungibile via doppio click. Il Canvas centrale usa React Flow per editing interattivo con nodi SVG fino a ~100 elementi visibili [^1137^]; ogni nodo mostra nome processo, impatto GWP aggregato e colore codificato per life cycle stage. Gli archi rappresentano flussi di prodotto con spessore proporzionale alla quantità di massa. La Mini-Map in basso offre una bird's-eye view dell'intero product system con un rettangolo che indica il viewport corrente [^1153^], essenziale per modelli che superano le dimensioni dello schermo — openLCA include già questa funzionalità ma con utilità limitata dalla UI generale [^164^]. Il Pannello AI destro (attivabile con `K+L`) risponde a domande contestuali sul modello: "Perché questo processo contribuisce tanto al GWP?", "Trova tutti i processi che usano energia elettrica" — con sourcing trasparente dei dati [^714^].

**Flussi di uscita.** Doppio click nodo → modal di editing dettagliato. Click su arco → pannello flusso con quantità, unità, incertezza. `KK` → command palette con azioni contestuali ("Aggiungi input", "Calcola impatto", "Confronta scenario"). `1-5` → switch tra viste (tabella, grafo, treemap, timeline, mappa). Click su *Share* → modal con link condivisibile e permessi (lettura / commento / editing).

**Tracciabilità principi.** Search-First (palette search filtra processi istantaneamente), Keyboard-First (`KK`, `1-5`, shortcut editing), AI Grounding (pannello AI con fonti citate), Multiple Views (switch tra 5 prospettive), Reversibile (salvataggio automatico, undo/redo illimitato).

#### 6.1.3 Ricerca e Import Processo

Questa schermata implementa il pattern Search-First a livello di sistema: invece di navigare gerarchie di database (l'approccio di SimaPro e openLCA, criticato per la lentezza [^17^]), l'utente cerca direttamente processi, flussi e dataset con una search globale che integra filtri faceted, preview in tempo reale e matching AI-assisted. Il design è ispirato a Neo4j Bloom [^1141^], dove la ricerca "Show me suppliers with high carbon footprint" genera direttamente la visualizzazione del grafo rilevante.

```
+-----------------------------------------------------------------------------+
|  [<- Back]  Global Search                                          [U]      |
|                                                                             |
|  +---------------------------------------------------------------------+    |
|  |  O   electricity mix italy renewable   [X]  [Advanced V]            |    |
|  +---------------------------------------------------------------------+    |
|                                                                             |
|  Filters: [Database: ecoinvent V] [Location: Italy V] [Type: Process V]    |
|           [GWP: All V] [Year: 2023-2024 V] [X Verified only]              |
|                                                                             |
|  +-----------------------------------------------------------------------+  |
|  |  AI Match (suggested)                                                   |  |
|  |  +-----------------------------------------------------------------+  |  |
|  |  | * electricity, high voltage, IT, 2023 (ecoinvent 3.9)            |  |  |
|  |  |     GWP: 0.334 kg CO2e/kWh  |  Confidence: 94%  |  [Preview ->] |  |  |
|  |  |     Matched because: "Italy + renewable mix + high voltage"      |  |  |
|  |  |     Source: ecoinvent 3.9 cutoff, process ID 12345               |  |  |
|  |  +-----------------------------------------------------------------+  |  |
|  |  +-----------------------------------------------------------------+  |  |
|  |  | * electricity, medium voltage, IT, 2023 (ecoinvent 3.9)          |  |  |
|  |  |     GWP: 0.412 kg CO2e/kWh  |  Confidence: 87%  |  [Preview ->] |  |  |
|  |  |     Note: Use this if your process uses medium voltage           |  |  |
|  |  +-----------------------------------------------------------------+  |  |
|  +-----------------------------------------------------------------------+  |
|                                                                             |
|  Database Results (47 matches)                                              |
|  +-----------------------------------------------------------------------+  |
|  |  Name                        | Database   | GWP       | Location | Yr |  |
|  +------------------------------+------------+-----------+----------+----+  |
|  | electricity, high voltage, IT| ecoinvent  | 0.334     | Italy    |2023|  |
|  | electricity, medium voltage..| ecoinvent  | 0.412     | Italy    |2023|  |
|  | electricity, low voltage, IT | ecoinvent  | 0.456     | Italy    |2023|  |
|  | electricity mix, EU-27       | EF 3.1     | 0.389     | EU-27    |2023|  |
|  | ...                          | ...        | ...       | ...      |... |  |
|  +-----------------------------------------------------------------------+  |
|                                                                             |
|  Preview Panel (selected: electricity, high voltage, IT)                    |
|  +-----------------------------------------------------------------------+  |
|  |  Quick Preview                                                        |  |
|  |  Unit: 1 kWh                                                          |  |
|  |  GWP: 0.334 kg CO2e                                                   |  |
|  |  Breakdown: CO2 (87%), CH4 (8%), N2O (5%)                             |  |
|  |  Geography: Italy (IT)                                                |  |
|  |  Valid until: 2024-12-31                                              |  |
|  |                                                                       |  |
|  |  [+ Add to Model]  [Copy Values]  [View Full Record]                  |  |
|  +-----------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------+
```

**Componenti interattivi.** La barra di ricerca principale supporta query in linguaggio naturale ("electricity mix Italy renewable") che viene interpretata dal motore AI+RAG per generare filtri automatici e ordinare i risultati per rilevanza [^714^]. I filtri faceted in seconda riga permettono affinamenti manuali sovrascrivendo le inferenze AI quando necessario — pattern *Human Override* essenziale per la validazione scientifica. La sezione AI Match presenta i risultati più rilevanti con confidence score e spiegazione del matching, implementando il principio di *AI Transparency*: l'utente comprende perché un risultato è stato suggerito [^670^]. La tabella risultati usa virtual scrolling per gestire liste di migliaia di processi senza degradazione [^1207^]. Il Preview Panel mostra un riepilogo del processo selezionato senza uscire dalla schermata di ricerca, riducendo il context switching.

**Flussi di uscita.** Click *Add to Model* → processo aggiunto al product system corrente, ritorno alla schermata Modellazione con il nuovo nodo posizionato automaticamente. Click *View Full Record* → schermata dettaglio completo del processo con tutti i flussi LCI. `K+Enter` → aggiunge il processo selezionato e chiude la ricerca.

**Tracciabilità principi.** Search-First (nessuna navigazione gerarchica, solo ricerca diretta), AI Grounding (match AI con confidence score e spiegazione), Progressive Disclosure (preview rapido prima del dettaglio completo), Keyboard-First (`/` attiva search, `^` `v` naviga risultati, `Enter` seleziona).

#### 6.1.4 Risultati e Interpretazione

Questa schermata affronta una delle evidenze più preoccupanti emerse dalla ricerca: il 52% degli utenti LCA usa Excel per visualizzare e condividere risultati, contro il 24% che usa il software LCA stesso [^4^]. Il motivo è che le UI legacy non offrono visualizzazioni interattive, multiple views e sharing integrato [^658^]. La schermata Risultati offre cinque viste sullo stesso dataset LCA — tabella, grafo di contribuzione, Sankey, treemap e dashboard — switchabili istantaneamente senza ricaricare i dati, seguendo il pattern *Database + Multiple Views* di Notion e Airtable [^658^][^666^].

```
+-----------------------------------------------------------------------------+
|  [<- Back]  Results: Bottiglia PET v2  [Method: ReCiPe 2016 Mid] [O]       |
+-----------------------------------------------------------------------------+
|                                                                             |
|  Views: [Table] [Graph] [Sankey] [Treemap] [Dashboard]  [Export V]          |
|                                                                             |
|  +-----------------------------------------------------------------------+  |
|  |                                                                       |  |
|  |  CONTRIBUTION ANALYSIS (by Process)                                   |  |
|  |                                                                       |  |
|  |  Production PET  ################################################  58.3%|  |
|  |  Raw Materials   #########################                        23.1%|  |
|  |  Transport       #######                                           8.4%|  |
|  |  Factory Energy  #####                                             6.2%|  |
|  |  Use Phase       ###                                               3.0%|  |
|  |  Disposal        #                                                 1.0%|  |
|  |                                                                       |  |
|  |  ------------------------------------------------------------------   |  |
|  |                                                                       |  |
|  |  AI Insight: "Production PET dominates GWP due to ethylene cracking.  |  |
|  |  Switching to bio-based PET could reduce this by 34% (source:         |  |
|  |  ecoinvent bio-PET process, 2023). [Explore scenario ->]"             |  |
|  |                                                                       |  |
|  +-----------------------------------------------------------------------+  |
|                                                                             |
|  Drill-down: Click any bar to explore process contributions                 |
|  [Production PET] -> [Ethylene] -> [Naphtha feedstock] -> [Crude oil]     |
|                                                                             |
|  +-----------------------------------------------------------------------+  |
|  |  Impact Category Breakdown                                            |  |
|  |  +--------------+ +--------------+ +--------------+ +-------------+  |  |
|  |  | GWP          | | Acidification| | Eutrophica-  | | Ozone Depl. |  |  |
|  |  | 2.10 kg      | | 12.4 g SO2eq | | tion 4.1g   | | 0.02 mg     |  |  |
|  |  | CO2eq        | |              | | PO4eq        | | CFC-11eq    |  |  |
|  |  | [Details ->] | | [Details ->] | | [Details ->] | | [Details ->]|  |  |
|  |  +--------------+ +--------------+ +--------------+ +-------------+  |  |
|  +-----------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------+
```

**Componenti interattivi.** Il tab switcher in alto permette di cambiare vista con click o shortcut `1-5`, con ogni vista che offre una prospettiva diversa sullo stesso risultato LCIA: Table (ordinamento e filtro per categoria di impatto), Graph (grafo di contribuzione con nodi dimensionati per impatto), Sankey (flussi di impatto attraverso la supply chain), Treemap (superficie proporzionale all'impatto [^658^]), Dashboard (riepilogo esecutivo con KPI principali). Il breadcrumb drill-down permette di navigare dalla contribuzione di primo livello fino ai processi elementari, soddisfando il requisito ISO 14040/44 di tracciabilità completa [^4^]. Gli AI Insight offrono analisi contestuali generati dal modello AI sulla base del risultato corrente, con fonti sempre citate — un pattern che trasforma l'audit trail da vincolo normativo a feature competitiva [^4^].

**Flussi di uscita.** Click su barra → drill-down al processo selezionato nella vista Graph. Click *Explore scenario* → branch del modello per analisi what-if. Click *Export* → menu a discesa con PDF, Excel, ILCD, link condivisibile. `K+P` → print-friendly view.

**Tracciabilità principi.** Multiple Views (cinque prospettive sullo stesso dataset), AI Grounding (insight con fonti citate), Reversibile (drill-down navigabile in entrambe le direzioni), Intent-First (la domanda "dove si concentra l'impatto?" trova risposta immediata).

#### 6.1.5 AI-Assisted Data Collection

Questa schermata risolve uno dei colli di bottiglia più significativi nel workflow LCA: la raccolta manuale dei dati di inventario. Secondo le evidenze, la creazione di un processo in SimaPro richiede 60-120 secondi attraverso form modali multi-tab [^17^], mentre con un approccio AI-assisted il target è <10 secondi per processo [^3^]. La schermata guida l'utente attraverso un flusso a quattro fasi: upload BOM → auto-mapping AI → review suggerimenti → completamento inventario.

```
+-----------------------------------------------------------------------------+
|  [<- Back]  Import BOM: Bottiglia PET v2                           [U]      |
+-----------------------------------------------------------------------------+
|                                                                             |
|  Progress: [====V====][====V====][====>====][--------]                     |
|            Upload      AI Map      Review     Complete                      |
|                                                                             |
|  +-----------------------------------------------------------------------+  |
|  |  STEP 2 OF 4: AI Auto-Mapping (completed)                             |  |
|  |                                                                       |  |
|  |  Your BOM has been analyzed. The AI has matched 23 of 25 items:       |  |
|  |                                                                       |  |
|  |  +------------------+-----------------------------+----------+------+ |  |
|  |  | BOM Item         | Matched Process             | Confid.  | Stat | |  |
|  |  +------------------+-----------------------------+----------+------+ |  |
|  |  | PET resin, 500g  | polyethylene terephthalate..| 98%      | OK   | |  |
|  |  | HDPE cap, 3g     | high density polyethylene.. | 96%      | OK   | |  |
|  |  | Adhesive label   | adhesive, rubber based..    | 91%      | OK   | |  |
|  |  | Cardboard box    | packaging, corrugated bo..  | 94%      | OK   | |  |
|  |  | Transport, 200km | transport, freight, lorry.. | 89%      | OK   | |  |
|  |  | [REDACTED]       | ? No match found            | --       | ??   | |  |
|  |  | [REDACTED]       | ? Multiple candidates       | 62%      | ??   | |  |
|  |  +------------------+-----------------------------+----------+------+ |  |
|  |                                                                       |  |
|  |  Unmatched items (2):                                                 |  |
|  |  +-----------------------------------------------------------------+  |  |
|  |  | "UV stabilizer additive" -- No direct match in ecoinvent/EF.    |  |  |
|  |  | [Search manually] [Ask AI to suggest proxy] [Mark as custom]    |  |  |
|  |  +-----------------------------------------------------------------+  |  |
|  |  +-----------------------------------------------------------------+  |  |
|  |  | "Recycled content 30%" -- Ambiguous: applies to PET or HDPE?    |  |  |
|  |  | [Apply to PET] [Apply to HDPE] [Apply to both] [Skip for now]  |  |  |
|  |  +-----------------------------------------------------------------+  |  |
|  |                                                                       |  |
|  |  [<- Back to Upload]  [Review All Matches ->]  [Complete Import]     |  |
|  +-----------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------+
```

**Componenti interattivi.** La barra di progresso mostra le quattro fasi del flusso con stato visivo (completato, in corso, futuro). La tabella di mapping mostra ogni item della BOM con il processo LCA matched, confidence score e stato di validazione. Gli item con confidence >85% sono pre-approvati (stato OK), quelli sotto soglia richiedono review manuale (stato ??). Per gli item senza match, il sistema offre tre opzioni: ricerca manuale nel database, richiesta AI di suggerimento proxy ("usa processo simile X come approssimazione"), o marcatura come processo custom. Questo pattern di *Human-in-the-Loop* con *Graduated Autonomy* — l'AI decide autonomamente per match di alta confidenza, richiede approvazione per quelli ambigui — è il medesimo adottato da Cursor nel suo Agent Mode [^714^].

**Flussi di uscita.** Click *Review All Matches* → schermata di review dettagliata con possibilità di modificare ogni singolo mapping. Click *Complete Import* → inventario aggiunto al modello, ritorno alla schermata Modellazione con i nuovi nodi posizionati automaticamente. Click su riga con ?? → panel di risoluzione con opzioni contestuali.

**Tracciabilità principi.** AI Grounding (confidence score per ogni match, fonte citata), Progressive Disclosure (review dettagliata solo per match ambigui), Reversibile (possibilità di tornare indietro a ogni fase), Intent-First (l'obiettivo "importa BOM" guida il flusso senza configurazione manuale).

### 6.2 Storyboard di 3 User Journey End-to-End

Gli storyboard traducono i wireframe in sequenze temporali con attori, tempi target e punti decisionali. Ogni storyboard rappresenta un profilo utente distinto emerso dalla ricerca, coprendo lo spettro dall'analista junior al revisore esperto. I tempi sono stimati sulla base dei benchmark raccolti: creazione processo <10s [^3^], apertura app istantanea in architettura local-first [^711^], risposta AI <2s per Time to First Token [^701^].

#### 6.2.1 Journey A: "Da BOM Excel a risultato LCIA in <10 minuti"

**Attore.** Maria, analista sostenibilità junior in un'azienda di packaging. Ha una BOM Excel con 25 item ma nessuna esperienza precedente con software LCA. Il suo capo le chiede il GWP di una bottiglia PET nuova versione entro mezzogiorno.

**Precondizioni.** Account attivo, database ecoinvent caricato, BOM Excel pronta.

| Step | Azione | Tempo Target | Schermata | Decision Point |
|------|--------|-------------|-----------|----------------|
| 1 | Maria apre l'app. La Home mostra i progetti recenti e un banner "New to LCA? Start here" | 0:00-0:03 | Home (6.1.1) | Ignora banner, click *New Study* |
| 2 | Digita nome studio "Bottiglia PET v2" e unità funzionale "1 bottiglia PET 500ml" via `KK` | 0:03-0:15 | Command palette | AI suggerisce template "Beverage packaging PET"; accetta |
| 3 | Click su *Import BOM*. Trascina file Excel con 25 item nella drop zone | 0:15-0:45 | AI-Assisted Data Collection (6.1.5) | Sistema valida formato, mostra anteprima |
| 4 | AI analizza BOM e matcha 23/25 item con processi ecoinvent | 0:45-2:00 | Auto-mapping | Match completato automaticamente; 2 item ambigui |
| 5 | Maria risolve i 2 item ambigui: seleziona "PET resin" per il recycled content, marca l'UV stabilizer come "custom proxy suggerito dall'AI" | 2:00-3:30 | Review suggerimenti | Ogni risoluzione mostra confidence score e fonte |
| 6 | Click *Complete Import*. Sistema genera product system con 23 nodi posizionati automaticamente per life cycle stage | 3:30-4:00 | Modellazione (6.1.2) | Grafo visibile con nodi colorati per stage |
| 7 | Maria nota che il nodo "Disposal" è vuoto. Click su AI Panel, scrive: "Aggiungi scenario riciclo meccanico Italia" | 4:00-5:00 | AI Panel | AI propone piano: "1. Aggiungo processo recycling PET IT 2. Collego output a Disposal 3. Ricalcolo"; Maria approva |
| 8 | AI esegue il piano. Nodo recycling aggiunto, arco collegato, calcolo aggiornato | 5:00-6:30 | Modellazione | Nodo nuovo evidenziato in verde, impatto aggiornato in tempo reale |
| 9 | `K+Enter` per calcolare impatto completo. Risultato: GWP 2.10 kg CO2e | 6:30-7:30 | Risultati (6.1.4) | Vista default: contribution analysis. Production PET = 58.3% |
| 10 | Maria switcha a vista Sankey per visualizzare il flusso di impatto attraverso la supply chain | 7:30-8:30 | Risultati → Sankey | Sankey interattivo, drill-down sui link |
| 11 | Click *Export* → PDF report con copertina, risultati, grafici e tabella processi. Sistema include automaticamente audit trail con fonti | 8:30-9:30 | Export modal | Report generato con tracciabilità completa |
| 12 | Consegna il report al capo via link condivisibile | 9:30-10:00 | Share modal | Link generato con permessi di sola lettura |

**Analisi del journey.** Il flusso complessivo di 10 minuti rappresenta una riduzione di 10-50x rispetto ai workflow tradizionali, dove solo la creazione manuale di 23 processi richiederebbe 23-46 minuti (60-120s per processo [^17^]). La chiave di questa accelerazione risiede in tre meccanismi cumulativi: (1) il template AI riduce il setup iniziale da configurazione manuale a selezione guidata, (2) l'auto-mapping della BOM elimina la ricerca individuale di 23 processi, (3) l'agent mode esegue modifiche strutturali (aggiunta nodo + collegamento + ricalcolo) come unità atomica approvabile. Il punto critico di qualità è Step 5: la risoluzione dei match ambigui richiede attenzione umana, e la UI deve fornire confidence score trasparenti per non compromettere la validità scientifica del modello.

#### 6.2.2 Journey B: "Adattare modello esistente a nuovo scenario geografico"

**Attore.** Marco, LCA senior consultant. Ha un modello "Bottiglia PET v1" validato per produzione Germania. Il cliente chiede lo stesso modello adattato per Italia, con switch del mix elettrico, trasporti e logistica.

**Precondizioni.** Modello v1 completo e validato, accesso al database ecoinvent con dataset Italia.

| Step | Azione | Tempo Target | Schermata | Decision Point |
|------|--------|-------------|-----------|----------------|
| 1 | Marco apre il progetto "Bottiglia PET v1" dalla Home. App si carica istantaneamente (local-first DB) | 0:00-0:02 | Home → Modellazione | Modello Germania visibile con 34 nodi |
| 2 | Click menu branch (`K+Shift+B`), seleziona "Create branch 'Italia scenario' from current" | 0:02-0:15 | Branch modal | Branch creato, indicator mostra "Italia scenario" |
| 3 | Marco apre command palette, digita: "Replace all electricity processes with Italy location" | 0:15-0:45 | Command palette + AI | AI mostra piano: "Trovo 3 processi elettricità in DE → match con equivalenti IT. Review?" |
| 4 | Review della sostituzione proposta: high voltage DE→IT, medium voltage DE→IT, low voltage DE→IT | 0:45-1:30 | Review diff | Vista side-by-side: sinistra DE, destra IT. Marco approva tutte e 3 |
| 5 | AI esegue sostituzioni. Sistema calcola delta impatto: GWP cambia da 1.89 a 2.10 kg CO2e (+11.1%) | 1:30-2:30 | Modellazione | Nodi sostituiti evidenziati in arancione, tooltip mostra delta |
| 6 | Marco notifica che anche i trasporti devono cambiare. Seleziona nodo "Transport road DE", usa `KK`: "Replace with Italian equivalent, 300km" | 2:30-3:30 | AI Panel | AI matcha "transport, freight, lorry 16-32t, IT" e aggiorna distanza a 300km |
| 7 | Marco aggiunge manualmente un nodo "Recycling end-of-life IT" cercandolo nella palette sinistra | 3:30-4:30 | Modellazione + Ricerca | Processo trovato in 10s via search, draggato sul canvas |
| 8 | `K+Enter` per ricalcolo completo. Risultato aggiornato: GWP 2.10 kg CO2e | 4:30-5:30 | Risultati | Vista compare: sinistra v1 (DE), destra v2 (IT) |
| 9 | Marco attiva "Comparison Mode": sistema mostra differenze processo-per-processo con delta percentuali | 5:30-6:30 | Compare view | Ogni processo con variazione >5% evidenziato in rosso/verde |
| 10 | Aggiunge commento al nodo "Electricity high voltage": "Switched from DE to IT grid per client request. Source: ecoinvent 3.9 IT" | 6:30-7:00 | Comment modal | Commento visibile come badge sul nodo, tracciato nell'audit trail |
| 11 | Merge del branch "Italia scenario" nel main con descrizione: "Adattamento geografico DE→IT, +11.1% GWP" | 7:00-8:00 | Merge modal | Visual diff mostra tutti i cambiamenti prima del merge |
| 12 | Esporta entrambi gli scenari in report comparativo PDF | 8:00-9:00 | Export modal | Report con due colonne DE/IT, delta, fonti |

**Analisi del journey.** Questo journey dimostra il pattern *Git-like versioning* applicato ai modelli LCA — un concetto che trasforma il requisito ISO di tracciabilità in una feature di produttività [^4^]. Il branch permette a Marco di sperimentare senza rischi sul modello validato; la visual diff garantisce che nessuna modifica venga applicata senza review esplicita. Il tempo totale di 9 minuti per un adattamento geografico completo rappresenta un risparmio stimato del 70-80% rispetto al workflow tradizionale, dove l'adattamento richiederebbe duplicazione manuale del modello, sostituzione processo per processo, e ricalcoli intermedi. Il punto critico di qualità è Step 4: la review della sostituzione AI deve mostrare un confronto chiaro prima/dopo con la fonte del dato sostitutivo, poiché una sostituzione errata del mix elettrico comprometterebbe l'intero risultato.

#### 6.2.3 Journey C: "Audit di un modello consegnato da un consulente"

**Attore.** Elena, sustainability manager di un brand. Deve auditare il modello LCA "Bottiglia PET v2" consegnato dal consulente Marco prima di pubblicarlo nel sustainability report annuale. Deve verificare metodologia, fonti dati, sensibilità e completezza.

**Precondizioni.** Modello condiviso via link con permessi di commento, accesso Elena come reviewer.

| Step | Azione | Tempo Target | Schermata | Decision Point |
|------|--------|-------------|-----------|----------------|
| 1 | Elena apre il link condiviso. App entra in "Review Mode" con watermark "REVIEW COPY — NOT FOR PUBLICATION" | 0:00-0:03 | Modellazione (Review Mode) | Cursori degli altri reviewer visibili in tempo reale |
| 2 | System mostra automaticamente "Review Checklist" a sidebar: Methodology, Data Sources, Completeness, Sensitivity, Documentation | 0:03-0:30 | Review panel | 5 categorie con stato: pending/in progress/completed |
| 3 | Elena inizia da Methodology. Click su nodo "Impact Assessment" → sidebar mostra: Method: ReCiPe 2016 Mid, Normalization: none, Weighting: none | 0:30-1:30 | Node details + Review | Checklist Methodology: in progress. Aggiunge commento: "Perché nessuna normalizzazione? ISO 14044 raccomanda..." |
| 4 | Naviga al nodo "Production PET". Sistema mostra data lineage visiva: "Questo impatto (2.1 kg) deriva da: ethylene cracking (1.4) + energy (0.5) + transport (0.2)" | 1:30-3:00 | Data lineage panel | Lineage interattiva, ogni nodo cliccabile fino al dataset ecoinvent originale |
| 5 | Click sul dataset ecoinvent "ethylene production" nella lineage → visualizza metadati completi: versione, anno, rappresentatività, incertezza | 3:00-4:00 | Dataset metadata | Validazione: dataset aggiornato (2023), rappresentativo per Europa |
| 6 | Elena switcha a vista "Sensitivity Analysis". Sistema mostra tornado chart: quali parametri influenzano maggiormente il risultato | 4:00-5:30 | Risultati → Sensitivity | Tornado chart: electricity mix (+/-23%), recycled content (+/-15%), transport distance (+/-8%) |
| 7 | Aggiunge commento sul nodo "Recycled content": "Lo scenario base assume 30% recycled. Il fornitore certifica 45%. Aggiornare?" | 5:30-6:00 | Comment on node | Commento visibile come thread, Marco (autore) riceve notifica |
| 8 | Verifica Audit Trail: click su icona cronologia. Sistema mostra timeline di tutte le modifiche: chi, cosa, quando, perché | 6:00-7:00 | Audit trail | 47 modifiche tracciate, ogni cambiamento ha autore e motivazione |
| 9 | Completa checklist. 4/5 categorie passate. Methodology: richiede normalizzazione. Elena aggiunge nota finale | 7:00-8:00 | Review summary | "Modello valido con riserva. Aggiungere normalizzazione ReCiPe e aggiornare recycled content a 45%" |
| 10 | Invia report di review a Marco con link al modello commentato. Marco riceve notifica con elenco azioni richieste | 8:00-9:00 | Export review | Report PDF con tutti i commenti, checklist e azioni |

**Analisi del journey.** Questo journey rappresenta il più alto valore aggiunto per la compliance normativa: trasforma l'audit LCA — tradizionalmente un processo di revisione documentale statica che può richiedere giorni — in un'esperienza interattiva guidata di 9 minuti. La data lineage visiva, ispirata a Dagster [^4^], permette a Elena di tracciare qualsiasi risultato fino al dataset sorgente in 2-3 click — un requisito ISO 14040/44 che nessun tool LCA attuale soddisfa con questa immediatezza. Il Review Mode con cursori multipli e commenti threaded è direttamente ispirato a Figma [^656^]: anche se l'editing real-time simultaneo è meno critico per LCA rispetto al design, la presenza visiva del reviewer e la capacità di commentare nodi specifici del grafo accelerano drasticamente il ciclo di feedback. Il punto critico di qualità è Step 4: la data lineage deve essere accurata al 100%, poiché qualsiasi interruzione nella catena di tracciabilità invaliderebbe l'audit.


### 6.3 Feature Differenzianti Prioritizzate

La tabella MoSCoW seguente sintetizza le feature derivate dai principi di design in quattro fasce di priorità — Must, Should, Could, Won't — con stime temporali e dipendenze tecniche esplicite. Le prioritizzazioni si basano su tre fattori cumulativi: impatto sulla produttività utente (dati quantitativi dai benchmark), rischio tecnico (complessità di implementazione), e valore differenziante rispetto alla concorrenza (SimaPro 9.5, openLCA 2.0, GaBi 2024). Ogni stima temporale assume un team di 5-6 sviluppatori full-time (3 frontend, 2 backend, 1 ML/AI) con esperienza in tool scientifici.

#### 6.3.1 Tabella MoSCoW

| ID | Feature | Categoria | Priorità | Stima | Dipendenze | Rationale |
|----|---------|-----------|----------|-------|------------|-----------|
| **M-1** | Command palette universale (KK) con tutte le azioni LCA mappate | Must | P0 | 3 sett. | Nessuna | Entry point per tutte le operazioni; riduce learning curve del 60% per utenti nuovi [^668^]. Senza questo, gli altri pattern AI-native perdono il loro layer di discoverability. |
| **M-2** | Canvas node-based con React Flow per editing interattivo (<100 nodi) | Must | P0 | 6 sett. | M-1 | Nucleo della modellazione. React Flow offre API stabile, documentazione completa, e integrazione nativa con React [^1137^]. Target: 60 FPS con 50 nodi. |
| **M-3** | Local-first architecture (IndexedDB/SQLite client, sync lazy) | Must | P0 | 5 sett. | M-2 | Elimina latenza di caricamento, abilita lavoro offline, aumenta velocità percepita [^711^]. Linear dimostra che 1,000 utenti concorrenti richiedono solo ~2 CPU core [^711^]. |
| **M-4** | AI Chat Panel con context awareness e RAG su database LCA | Must | P0 | 6 sett. | M-1, M-3 | Pannello laterale (K+L) che "conosce" il modello aperto. LLM + RAG/GraphRAG su ecoinvent/EF con Hit@10 >88% [^4^]. Ogni risposta include fonte dataset, processo ID, versione. |
| **M-5** | Database + Multiple Views (tabella, grafo, Sankey, treemap) | Must | P0 | 5 sett. | M-2, M-3 | Stesso dataset LCA visto in 4+ prospettive switchabili istantaneamente [^658^]. Risolve il problema del 52% utenti che usa Excel per visualizzare risultati [^4^]. |
| **M-6** | Auto-save con history (undo/redo illimitato, branch/merge) | Must | P0 | 4 sett. | M-3 | Prerequisito per Reversibilità e Git-like versioning. Ogni modifica tracciata con timestamp, autore, motivazione [^4^]. |
| **M-7** | Ricerca globale con faceted filters e preview rapida | Must | P0 | 4 sett. | M-1, M-3 | Sostituisce navigazione gerarchica database. Search-first design riduce tempo di trovare processo da 30-60s a <5s [^1141^]. |
| **M-8** | Calcolo LCA via olca-ipc o Brightway Python backend | Must | P0 | 4 sett. | Nessuna | API REST/gRPC verso motore di calcolo openLCA o Brightway [^886^]. Engine esistente, non da reinventare. Target: <3s per product system medio. |
| **M-9** | Keyboard-first shortcuts per tutte le operazioni principali | Must | P1 | 2 sett. | M-1 | j/k navigazione, e edit, c calcola, / cerca, 1-5 switch view [^653^]. Costo basso, impatto alto sulla produttività esperti. |
| **M-10** | Dark mode default con color restraint | Must | P1 | 2 sett. | Nessuna | Riduce eye strain per sessioni lunghe (LCA = 2-8 ore tipiche) [^653^]. Schema colore NATURE-based per coerenza semantica. |
| **S-1** | AI Auto-Mapping BOM (upload → match → review → import) | Should | P1 | 5 sett. | M-4, M-8 | Riduce tempo raccolta dati del 70% per studi con BOM strutturata. Confidence score per ogni match, human-in-the-loop per soglia <85% [^714^]. |
| **S-2** | Agent Mode (Plan → Execute → Review) per task multi-step | Should | P1 | 6 sett. | M-4 | AI pianifica ed esegue task complessi autonomamente: "Crea studio LCA completo per bottiglia PET" → genera processi, flussi, calcoli [^714^]. Piano visibile ed editabile prima dell'esecuzione. |
| **S-3** | Mini-mappa e navigazione bird's-eye per grafi grandi | Should | P1 | 2 sett. | M-2 | Componente built-in React Flow [^1153^], ma richiede personalizzazione per aggregazione LCA. Essenziale per modelli >50 nodi. |
| **S-4** | Inline AI suggestion (ghost text) per dati inventario | Should | P1 | 3 sett. | M-4 | Auto-completamento flussi di massa, fattori di emissione, unità di misura [^664^]. Pattern da Cursor/VS Code Copilot, adattato a dati LCA. |
| **S-5** | Review Mode con commenti threaded su nodi e audit trail | Should | P1 | 4 sett. | M-6 | Commenti su nodi specifici del grafo, checklist di review, data lineage visiva [^4^]. Trasforma compliance ISO in feature competitiva. |
| **S-6** | Optimistic UI updates (feedback istantaneo, sync dopo) | Should | P2 | 2 sett. | M-3 | Modifica visibile immediatamente, sincronizzazione server in background [^653^]. Pattern da Linear/TanStack Query. |
| **S-7** | Streaming UI per risultati calcolo (progressivi) | Should | P2 | 2 sett. | M-8 | Risultati LCA che arrivano progressivamente, non tutti insieme [^701^]. Skeleton screens durante caricamento iniziale. |
| **S-8** | CRDT-based real-time collaboration (cursori, presence) | Should | P2 | 6 sett. | M-3, M-6 | Editing simultaneo con cursori colorati, viewport follow [^656^]. Figma gestisce 2.2B changes/day con property-level LWW [^656^]; per LCA, Yjs offre soluzione open-source matura [^1222^]. |
| **C-1** | Sigma.js WebGL overview per grafi >1000 nodi | Could | P2 | 4 sett. | M-2, M-5 | Renderer ibrido: React Flow per editing <100 nodi, Sigma.js per overview 1K-100K nodi [^1186^]. Switch automatico in base a zoom e cardinalità. |
| **C-2** | Generative UI from prompt ("Crea studio LCA per bottiglia PET") | Could | P3 | 4 sett. | S-2 | Studio LCA completo generato da prompt naturale in 10-30s [^647^]. Valore massimo per onboarding utenti nuovi, ma richiede S-2. |
| **C-3** | Token simulation (token virtuale attraversa supply chain) | Could | P3 | 3 sett. | M-2, M-5 | Pattern esplorativo: token animato mostra dove si accumola l'impatto nel grafo. Ispirato a Camunda BPMN token simulation [^4^]. |
| **C-4** | Map View (geolocalizzazione processi supply chain) | Could | P3 | 3 sett. | M-5 | Vista geografica dei processi con heatmap di impatto per location. Utile per analisi regionalizzate PEF/OEF. |
| **C-5** | Component system + auto-layout (template processi riutilizzabili) | Could | P3 | 3 sett. | M-2 | Template di processo che ereditano proprietà, auto-adattamento. Cambia il master → si aggiornano tutte le istanze, come Figma components [^656^]. |
| **C-6** | Block-based editing per documentazione LCA | Could | P3 | 3 sett. | M-5 | Documento LCA come blocchi (testo, tabella, grafico, AI summary) riorganizzabili [^720^]. Esportabile in report PDF/Word. |
| **W-1** | Full WebGL rendering (Cosmograph) per 1M+ nodi | Won't | — | — | — | Richiesto solo per corporate LCA con 10K+ processi. Per MVP, aggregazione gerarchica + Sigma.js è sufficiente [^1147^]. Valutare in v3+. |
| **W-2** | Edge bundling per grafi densi | Won't | — | — | — | Tecnica avanzata per ridurre clutter visivo [^1165^]. Utile solo per grafi con >500 edges. Canvas di React Flow gestisce bene densità moderate. |
| **W-3** | VR/AR visualization del product system | Won't | — | — | — | Valore dimostrativo ma nessun caso d'uso LCA pratico identificato nella ricerca. Risorsa:prodotto irrisorio. |
| **W-4** | Marketplace di processi/template di terze parti | Won't | — | — | — | Ecoinvent e EF sono già database standard. Un marketplace fragmenterebbe l'ecosistema e solleverebbe problemi di quality assurance. |

**Analisi della prioritizzazione.** Le 10 feature Must (P0-P1) rappresentano il Minimum Viable Product (MVP) e hanno una stima cumulativa di ~41 settimane (~10 mesi) per il team di riferimento, considerando parallelizzazione parziale. La dipendenza critica è M-4 (AI Chat Panel): essendo prerequisito per S-1, S-2 e indirettamente per C-2, qualsiasi ritardo su M-4 ha effetto a cascata su 5+ feature Should. Le 8 feature Should aggiungono ~30 settimane e trasformano il MVP in un prodotto competitivo rispetto ai tool legacy. Le 6 feature Could rappresentano differenziazione avanzata e dipendono tutte da almeno una Should. La scelta di Won't per Full WebGL, VR/AR e Marketplace riflette il principio di *focus* derivato dalla ricerca: il rischio principale è l'adozione, non la mancanza di feature esotiche [^4^].

L'analisi delle dipendenze rivela un percorso critico che attraversa quattro layer: M-3 (local-first) → M-2 (canvas) → M-4 (AI panel) → S-1/S-2 (AI advanced). Questo percorso suggerisce che l'investimento iniziale dovrebbe concentrarsi sull'architettura dati (M-3) e sul canvas interattivo (M-2) prima di abilitare le feature AI avanzate. Una strategia di rilascio incrementale potrebbe essere: MVP a 6 mesi (M-1, M-2, M-3, M-7, M-8, M-9, M-10), Beta a 9 mesi (+ M-4, M-5, M-6), GA a 12 mesi (+ S-1, S-2, S-3, S-4, S-5).

### 6.4 Stack Tecnologico Suggerito

Lo stack tecnologico qui proposto non è una specifica vincolante ma una raccomandazione basata su evidenze quantitative di performance, maturità dell'ecosistema, e aderenza ai principi di design del Capitolo 5. L'approccio è *best-of-breed* per layer: ogni componente è selezionato indipendentemente sulla base di benchmark pubblici, non di preferenze di vendor. La filosofia generale è: il frontend gestisce stato e interazione, il backend computazionale delega ai motori LCA esistenti (openLCA/Brightway), l'AI aggiunge un layer di intelligence senza sostituire il calcolo scientifico.

#### 6.4.1 Frontend: React/TypeScript, React Flow, Sigma.js, Tailwind CSS

Il frontend si articola in tre layer di rendering che rispondono a scale diverse del modello LCA, implementando il principio *Insight 9: Performance at Scale Requires a Hybrid Renderer* [^4^].

**Layer interattivo: React Flow.** Per l'editing di product system fino a ~100 nodi visibili simultaneamente, React Flow offre il miglior compromesso tra interattività e semplicità di sviluppo. I benchmark indicano 60 FPS con 100 nodi ottimizzati, ma solo 2 FPS con 100 nodi "heavy" senza memoizzazione [^1137^]. Le ottimizzazioni obbligatorie includono: `useMemo`/`useCallback` per tutti gli oggetti passati, componenti nodo wrappati in `React.memo`, custom nodes leggeri (nessun DataGrid interno), e `useNodesState`/`useEdgesState` per gestione stato [^1137^]. React Flow include built-in MiniMap [^1153^], Background, Controls e Panel — componenti che accelerano lo sviluppo della schermata Modellazione (6.1.2). La licenza MIT permette uso commerciale senza costi.

**Layer overview: Sigma.js v2.** Per la visualizzazione di overview e la navigazione in grafi di 1K-100K nodi, Sigma.js v2 usa WebGL puro (SVG renderer droppato nella v2) e gestisce decine di migliaia di nodi interattivamente [^1186^][^1189^]. Integrato con Graphology per data structure e layout ForceAtlas2, offre smooth zooming/panning ed è framework-agnostic — usato in produzione da Gephi Lite, BloodHound e GraphCommons. Il pattern di switch tra React Flow (editing, <100 nodi) e Sigma.js (overview, >100 nodi) è automatico in base allo zoom level e alla cardinalità del grafo.

**Layer styling: Tailwind CSS.** Per coerenza con l'approccio utility-first e la necessità di dark mode default, Tailwind offre un sistema di design token personalizzabili (colori NATURE-based, spacing, tipografia) con zero CSS runtime. Il bundle size è tree-shakeable e la curva di apprendimento per sviluppatori React è minima.

**Framework: React 18+ con TypeScript.** La scelta di React è motivata da: (a) ecosistema maturo per componenti scientifici (React Flow, Sigma.js wrapper, AG Grid, visx), (b) concurrent features (Suspense, transitions) per gestire calcoli pesanti senza bloccare UI, (c) TypeScript per type safety in un dominio con modelli dati complessi (processi, flussi, impatti, metodi). La local-first architecture usa TanStack Query per gestione stato server e Zustand per stato client (viewport, selezione, grafo).

**Tabelle dati: AG Grid.** Per le viste tabellari (lista processi, risultati LCIA, inventory), AG Grid Community offre virtual scrolling, sorting, filtri e grouping out-of-the-box, con supporto verificato per 1M+ righe senza degradazione significativa [^1207^]. Alternativa più leggera: TanStack Table (headless, personalizzabile al 100%).

#### 6.4.2 Backend Computazionale: olca-ipc / Brightway Python, API REST/gRPC

Il backend computazionale non reinventa il motore LCA — openLCA e Brightway rappresentano decenni di sviluppo scientifico validato — ma lo espone tramite API moderne.

**OpenLCA IPC (olca-ipc).** La libreria Python `olca-ipc` fornisce un client che comunica con un server openLCA IPC via HTTP [^886^]. L'API espone operazioni CRUD per tutte le entità LCA (processi, flussi, product system, metodi di impatto) e calcoli (upstream analysis, contribution analysis, Monte Carlo simulation). Un esempio tipico di calcolo LCIA richiede ~10 linee di Python: creazione `CalculationSetup`, specifica del `product_system` e `impact_method`, chiamata `client.calculate()`, e iterazione sui risultati [^886^]. Il server IPC opera sulla porta 8080 di default e può essere containerizzato via Docker per deployment cloud. Il vantaggio di olca-ipc è l'integrazione nativa con database openLCA (compresi ecoinvent, EF, ELCD) senza necessità di conversione formati.

**Brightway2/25.** Alternativa open-source a olca-ipc, Brightway è una libreria Python pura per LCA calculation con un approccio programmatico più flessibile [^1220^]. Brightway gestisce progetti, database, metodi di impatto e calcoli LCA via API Python native. La connessione con openLCA è possibile tramite la libreria `brightway-olca` che legge database openLCA via IPC [^1221^]. Brightway è preferibile quando è necessario customizzare profondamente il motore di calcolo (es. metodi di impatto custom, analisi di sensibilità avanzate, Monte Carlo parallelo).

**Architettura API.** Un layer API REST (o gRPC per performance superiori su payload grandi) funge da adapter tra il frontend e il motore di calcolo. L'API espone endpoint per: (a) CRUD modelli LCA, (b) calcolo sincrono (<3s) e asincrono (task queue), (c) query su database LCA (RAG backend), (d) gestione branch/merge/versioning. Il calcolo LCA pesante (Monte Carlo con 10K iterazioni, product system con 1K+ processi) viene eseguito asincronamente con progress streaming via Server-Sent Events.

**Calcolo locale vs cloud.** Per il principio di local-first [^711^], il calcolo semplice (product system <100 processi, analisi di contribuzione) può essere eseguito localmente via WebAssembly (DuckDB Wasm per query, Pyodide per calcolo Python in-browser). Il calcolo complesso è delegato al server Python. Questo ibrido massimizza la reattività per operazioni frequenti e la potenza per analisi pesanti.

#### 6.4.3 AI: LLM (OpenAI/Claude) + RAG/GraphRAG su ecoinvent/EF, embeddings

L'architettura AI segue il pattern *LLM per reasoning, RAG per facts* — fondamentale in un dominio dove l'hallucination su dati ambientali può raggiungere il 37-40% senza grounding [^4^].

**LLM per reasoning.** Il modello di linguaggio (OpenAI GPT-4o/Claude 3.5 Sonnet o equivalente) gestisce il reasoning: interpretazione di query in linguaggio naturale, pianificazione di task multi-step (Agent Mode), generazione di spiegazioni contestuali, e summarization di risultati. Il LLM non memorizza dati LCA — ogni factual claim è recuperato via RAG e citato esplicitamente nell'output [^714^].

**RAG/GraphRAG su database LCA.** Il sistema di retrieval usa una combinazione di: (a) embeddings semantici sui processi ecoinvent/EF (nome, descrizione, location, unità, GWP) per matching similarity, (b) GraphRAG che sfrutta le relazioni tra processi (input/output, supply chain) per retrieval strutturato. I benchmark mostrano GraphRAG Hit@10 >88% per dati LCA [^4^], significativamente superiore a retrieval puramente vettoriale. Gli embeddings sono generati tramite modelli sentence-transformer specializzati (es. `all-MiniLM-L6-v2` fine-tuned su terminologia LCA) e indicizzati in un vector store (Chroma, Pinecone, o Qdrant).

**AI grounding e transparency.** Ogni risposta AI include: (1) il processo/dataset fonte citato con ID e versione, (2) il confidence score del match, (3) un link cliccabile per verificare il dato originale. Questo pattern, derivato da Cursor `@codebase` [^714^], usa `@database` come meccanismo di grounding: l'AI non può inventare fattori di emissione perché tutti i fatti sono recuperati dal database verificato.

**AI side-panel architecture.** Il pannello AI è implementato come componente React separato che comunica con il backend AI via WebSocket per streaming delle risposte. La context awareness è ottenuta inviando al backend, per ogni query, il contesto del modello LCA aperto: elenco processi, metodo di impatto selezionato, database usati. Il costo stimato per uso intensivo è $0.02-0.05 per query (GPT-4o API), trascurabile rispetto al costo della licenza LCA tradizionale ($3,000-15,000/anno).

#### 6.4.4 Collaboration: CRDT (Yjs/Liveblocks), Git-like Versioning

Il layer di collaborazione combina due pattern: CRDT per editing real-time e Git-like versioning per branch/merge di modelli LCA.

**CRDT via Yjs.** Yjs è una libreria CRDT (Conflict-free Replicated Data Type) open-source che permette editing simultaneo senza server centrale per la risoluzione dei conflitti [^1222^]. I benchmark CRDT mostrano Yjs come il più performante per operazioni di testo: 5ms per inserimento di 6,000 parole, memoria 2.3MB, parse time 92ms [^1222^]. Per dati strutturati (grafo LCA), Yjs fornisce tipi `Y.Map` e `Y.Array` che si sincronizzano automaticamente tra client. L'integrazione con React avviene tramite `zustand` bindings o `y-react-hooks`. Alternativa commerciale: Liveblocks, che offre CRDT-as-a-service con presence API, cursori, e storage managed — ideale per accelerare lo sviluppo del MVP.

**Git-like versioning.** Il versioning di modelli LCA implementa concetti da Onshape [^4^]: (a) *branch* per scenari what-if ("lightweight design", "scenario ottimistico"), (b) *commit* con messaggio descrittivo per ogni modifica significativa, (c) *merge* con visual diff tra versioni, (d) *tag* per milestone ("PEF submission", "ISO audit"). La differenza chiave rispetto a Git è che il "diff" è visuale: nodi aggiunti (verde), modificati (arancione), eliminati (rosso) con i valori prima/dopo. Il backend versioning usa un grafo di versioni (DAG) immutabile con riferimenti a snapshot del modello, implementato su PostgreSQL con JSONB per flessibilità schema.

**Audit trail.** Ogni operazione su un modello LCA è registrata in un log immutabile: timestamp, autore, tipo operazione (create, update, delete, calculate), entità coinvolta, valori prima/dopo, motivazione (opzionale). Questo log soddisfa i requisiti ISO 14040/44 su tracciabilità e riproducibilità [^4^], ed è esportabile in formato leggibile per audit di terze parti.

### 6.5 Rischi Principali

Una roadmap tecnica, per quanto ben progettata, non produce valore se non considera realisticamente gli ostacoli all'adozione. I rischi qui analizzati sono organizzati in tre categorie — adozione, compliance, performance — con probabilità stimata, impatto, e mitigazione concreta. Le stime di probabilità si basano su dati di mercato e pattern storici di adozione software nel settore LCA.

#### 6.5.1 Rischi di Adozione

| Rischio | Probabilità | Impatto | Mitigazione |
|---------|------------|---------|-------------|
| **Switching cost da SimaPro/GaBi** | Alta (70%) | Alto | Compatibilità database ecoinvent (stesso formato openLCA), import wizard da file SimaPro (.csv, .xlsx), UX familiare per azioni core (modellazione processo = nodo su canvas, non form modale). Target: 80% dei modelli SimaPro importabili senza perdita dati. |
| **Learning curve per utenti esperti legacy** | Alta (65%) | Medio-Alto | Command palette come "training wheels": l'utente impara gradualmente i shortcut [^296^]. Modalità "SimaPro-like" opzionale con form tradizionali per transizione graduale. Tutorial interattivi in-app per ogni feature nuova. Community forum con risposta <24h. |
| **Network effect e lock-in dei consulenti** | Media (50%) | Alto | I consulenti LCA sono gatekeeper: se non adottano il tool, i clienti enterprise non lo vedono. Strategia: freemium per consulenti indipendenti (1 progetto gratis, poi $49/mese), partnership con università (licenze gratuite per corsi LCA), certificazione "LCA Tool Expert" che aumenta credibility del consulente. |
| **Resistenza al cambiamento in grandi aziende** | Media (55%) | Medio | Procurement enterprise richiede vendor track record. Strategia: case study con early adopters dopo 6 mesi, white paper con università, compliance ISO/PEF come prerequisito. Pilot program con 3-5 aziende target con sconto 50% in cambio di testimonianza. |
| **Prestazione percepita vs tool nativi desktop** | Media (45%) | Medio | Architettura local-first elimina la latenza percepita come principale critica dei tool web [^711^]. Benchmark: apertura app <1s, navigazione tra schermate <100ms, calcolo semplice <3s. Skeleton screens invece di spinners per operazioni >1s [^723^]. |

L'analisi dei rischi di adozione rivela un pattern ricorrente: il fattore limitante non è la tecnologia (tutti i componenti esistono [^4^]) ma la struttura di mercato. SimaPro ha ~30 anni di presenza, GaBi ~25 anni; entrambi hanno costruito ecosistemi di training, certificazione e consulenza che creano switching cost non solo tecnici ma relazionali [^4^]. La mitigazione richiede una strategia go-to-market parallela allo sviluppo prodotto, con focus su segmenti di utenti non serviti dai legacy: analisti junior (prezzo troppo alto per SimaPro), startup sostenibilità (need velocità, non profondità metodologica), e team R&D aziendali (need collaborazione, non singolo utente).

#### 6.5.2 Rischi di Compliance

| Rischio | Probabilità | Impatto | Mitigazione |
|---------|------------|---------|-------------|
| **Validazione metodologica AI** | Alta (75%) | Molto Alto | Human-in-the-loop obbligatorio per ogni decisione AI critica. Confidence threshold: match <85% richiedono approvazione manuale. Audit trail completo di ogni suggerimento AI (cosa è stato proposto, cosa è stato accettato/rifiutato, da chi). LLM come *copilot*, non pilota [^714^]. |
| **Accettanza da enti normativi (PEF, ISO)** | Media (50%) | Molto Alto | Audit trail immutabile con firma digitale per ogni modifica. Export in formati standard (ILCD, ESMA xBRL) per submission regolatorie. Partnership con JRC (Joint Research Centre) EU per validazione PEFCR. Engagement precoce con enti di certificazione (SGS, Bureau Veritas). |
| **Riproducibilità risultati** | Media (40%) | Alto | Ogni risultato è cliccabile fino al processo sorgente (drill-down illimitato). Versioning di database: il modello memorizza non solo i processi ma anche la versione esatta del dataset usato (ecoinvent 3.9 cutoff 2023, non genericamente "ecoinvent"). Snapshot del modello esportabile e re-importabile per riproduzione esatta. |
| **Bias nei suggerimenti AI** | Media (45%) | Medio-Alto | RAG su database verificati (ecoinvent, EF) non su dati generici. Fine-tuning del modello su dataset LCA validati. Trasparenza: ogni suggerimento mostra la fonte e il metodo di matching. Review periodica dei match AI da parte di esperti LCA per identificare bias sistematici. |

Il rischio di compliance è il più pericoloso perché, a differenza dei rischi tecnici, non è completamente controllabile dal team di sviluppo. L'accettanza da parte di enti normativi dipende da fattori politici e istituzionali che evolvono nel tempo. La mitigazione principale è la *trasparenza totale*: se ogni passaggio del processo LCA è tracciato, citato e verificabile, l'onere della prova si sposta dall'affidabilità del software all'affidabilità dei dati e del metodo — che è esattamente ciò che ISO 14040/44 richiede.

#### 6.5.3 Rischi di Performance

| Rischio | Probabilità | Impatto | Mitigazione |
|---------|------------|---------|-------------|
| **Rendering 10K+ nodi nel canvas** | Media (50%) | Alto | Renderer ibrido: React Flow per <100 nodi (editing), Sigma.js WebGL per 1K-100K nodi (overview), aggregazione gerarchica per >10K nodi [^1186^][^1137^]. Level-of-Detail: zoom out aggrega nodi per categoria/stage [^1156^]. Target: 60 FPS per pan/zoom a qualsiasi scala. |
| **Calcolo real-time durante editing** | Media (45%) | Medio-Alto | Lazy evaluation (pattern Houdini): solo i processi modificati e i loro discendenti vengono ricalcolati [^1068^]. Dirty propagation visiva: nodi "dirty" evidenziati in giallo, nodi "calculating" in arancione. Web Workers per calcolo off-main-thread. Cache multi-livello (GPU → JS → IndexedDB → Server) [^1082^]. |
| **Latenza AI (>2s Time to First Token)** | Media (40%) | Medio | Caching delle risposte frequenti. Pre-computing dei match AI per operazioni comuni. Fallback a suggerimenti basati su regole deterministiche se LLM non risponde in <2s. Streaming UI: token che arrivano progressivamente anziché blocco unico [^701^]. |
| **Sincronizzazione modelli grandi (>100MB)** | Bassa-Media (35%) | Medio | Modelli LCA con database completi possono superare i 100MB. Strategia: sync differenziale (solo le modifiche, non l'intero modello), compression via MessagePack, sync in background senza bloccare l'UI. Per modelli >500MB: sync on-demand per branch, non per l'intero grafo. |
| **Memoria browser con grafi grandi** | Media (40%) | Medio | Virtual scrolling per liste processi [^1207^]. Progressive loading: prima overview aggregata, poi dettaglio su richiesta. Offloading dati non visibili a IndexedDB. WebGL buffer management: deallocazione nodi fuori viewport. Target: <500MB RAM per modello con 10K processi. |

I rischi di performance sono i più mitigabili attraverso scelte architetturali corrette fatte precocemente. La ricerca fornisce benchmark concreti: Cosmograph visualizza 1M+ nodi a 60 FPS in browser [^1147^], Sigma.js gestisce 100K+ nodi WebGL [^1186^], AG Grid supporta 1M+ righe con virtual scrolling [^1207^]. La sfida non è tecnica ma di integrazione: assemblare queste tecnologie in un'esperienza coerente che switchi renderer in base allo zoom senza che l'utente se ne accorga. Il dirty propagation di Houdini [^1068^] e il proxy system di Nuke [^1187^] offrono pattern collaudati per il calcolo incrementale — entrambi applicabili a un editor LCA con grafo di processi.

**Sintesi della gestione rischi.** La matrice dei rischi suggerisce che il percorso critico verso il successo non è la tecnologia (risolvibile con le scelte architetturali delineate) né la performance (mitigabile con i pattern documentati), ma l'adozione da parte di un mercato abituato a tool legacy con alto lock-in. La strategia raccomandata è una segmentazione del go-to-market: (1) MVP target su utenti "Excel escapees" — quei 52% che già abbandonano i tool LCA per Excel [^4^] — offrendo loro multiple views native e sharing integrato; (2) fase 2 target su consulenti LCA indipendenti con pricing aggressivo e feature di productivity; (3) fase 3 target su enterprise con compliance, audit trail e collaboration come prerequisiti procurement. Questa segmentazione riduce il rischio di adozione concentrando l'investimento marketing su segmenti con il più basso switching cost percepito.

