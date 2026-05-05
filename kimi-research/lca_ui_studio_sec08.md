## 8. Glossario dei Pattern UI

Questo glossario raccoglie i pattern UI/UX identificati nel report e li rende riutilizzabili per il lettore che dialoga con un team di sviluppo. Ogni pattern include una definizione compatta, il tool che lo implementa meglio, e una valutazione di applicabilità al dominio LCA. I pattern sono organizzati per categoria funzionale; la Tabella 8.1 offre una vista master riassuntiva.

---

### 8.1 Pattern di Interazione

#### 8.1.1 Command Palette (Tavolozza dei Comandi)

Interfaccia modale attivata da shortcut (⌘K) che permette di eseguire qualsiasi azione digitandone il nome. Mostra comandi contestuali, shortcut associati e suggerimenti basati sulla frequenza d'uso. Raycast implementa la variante più sofisticata, con estensioni come first-class citizens e alias personalizzabili [^667^][^668^]; Linear la usa come entry point universale [^653^]. *Applicabilità LCA: alta* — rende accessibili in <3 secondo azioni che nei tool tradizionali richiedono 5-10 click attraverso menu annidati (creazione processo, collegamento flussi, cambio metodo di impatto, switch vista). Superhuman dimostra che la palette funge da *training wheels*: l'utente la usa per scoprire shortcut, poi migra ai comandi diretti [^296^].

#### 8.1.2 Ghost Text (Testo Fantasma)

Suggerimento testuale in colore attenuato inline rispetto al contenuto che l'utente sta digitando. Accettabile con Tab, ignorabile continuando a scrivere. Generato da LLM con contesto del documento aperto. Cursor estende il pattern con predizione del prossimo edit oltre al semplice completamento [^714^][^652^]. *Applicabilità LCA: alta* — auto-completamento dei dati di inventario: flussi di massa, unità di misura, fattori di emissione. Quando l'utente digita "Electricity, at grid" il ghost text suggerisce "kWh" e il valore di emissione associato dal database ecoinvent.

#### 8.1.3 Agent Mode (Modalità Agente)

Pattern di interazione in cui un agente AI opera autonomamente seguendo un piano visibile ed editabile: Plan (task list in markdown) → Execute (esecuzione automatica) → Review (approvazione umana). L'utente può intervenire a ogni step [^714^][^646^]. *Applicabilità LCA: alta* — l'Agent LCA pianifica uno studio completo: definizione unità funzionale, creazione processi da database, collegamento flussi, calcolo impatto, report. La fase Plan visibile mitiga il rischio di hallucination del 37–40% documentato su dati ambientali [^669^].

#### 8.1.4 Block-Based Editing (Editing a Blocchi)

Paradigma in cui ogni elemento di contenuto è un blocco indipendente con tipo proprio (paragrafo, tabella, grafico, blocco AI). I blocchi si trascinano, nidificano e convertono da un tipo all'altro. Notion utilizza blocchi come unità base con "AI Block" aggiornabile dal modello [^720^]. *Applicabilità LCA: media* — il report LCA diventa insieme di blocchi sincronizzati con il modello: testo metodologico, tabella inventario, grafico contributo, Sankey interattivo. Utile per la fase di Interpretazione ISO 14040/44.

#### 8.1.5 Progressive Disclosure (Rivelazione Progressiva)

Tecnica che presenta solo le funzionalità necessarie al livello di competenza dell'utente, rivelando complessità aggiuntiva su richiesta. Wizard semplificato → form avanzato → interfaccia esperta. ChatGPT e Canva Magic Studio implementano varianti raffinate [^669^][^670^]. *Applicabilità LCA: altissima* — Layer 1 wizard (~1 ora per primo modello vs ~8 ore di SimaPro) [^Chatty2021^], Layer 2 form per modifica parametri, Layer 3 node-graph per modellazione avanzata. Il 90% delle fonti cita learning curve come problema #1 nei software LCA.

#### 8.1.6 Keyboard-First, Mouse-Optional

Principio in cui ogni azione è eseguibile da tastiera con shortcut mnemonici; il mouse è opzionale. Linear implementa j/k navigazione, / filtro, e edit, con mappatura mnemonica [^653^][^711^]. *Applicabilità LCA: alta* — naviga processi (j/k), command palette (⌘K), calcolo impatto (⌘Enter), switch vista (1-5). L'analista esperto modella 50+ processi per sessione; il risparmio si moltiplica su centinaia di operazioni.

#### 8.1.7 Optimistic UI Updates (Aggiornamenti Ottimistici)

L'interfaccia si aggiorna istantaneamente dopo un'azione utente, prima della conferma del server. Se l'operazione fallisce, rollback trasparente con notifica. Linear combina il pattern con local-first: la modifica è immediata perché scrive sul database locale [^711^][^721^]. *Applicabilità LCA: alta* — modifica flusso di massa → subito visibile nel grafo e negli impatti. Durante la sensitivity analysis, l'aggiornamento ottimistico rende il workflow interattivo.

---

### 8.2 Pattern di Visualizzazione

#### 8.2.1 Node-Graph Canvas (Tela a Grafo di Nodi)

Area di lavoro bidimensionale infinita dove gli elementi sono nodi connessi da archi direzionali. Supporta pan, zoom, selezione multipla e manipolazione diretta. Nodi con porte tipizzate per input/output. React Flow, KNIME e Blender ne sono esempi maturi [^544^][^478^][^572^]. *Applicabilità LCA: altissima* — il modello LCA è intrinsecamente un grafo diretto: nodi = processi, archi = flussi materia/energia. KNIME dimostra che il paradigma gestisce workflow scientifici complessi con typed ports [^562^][^564^].

#### 8.2.2 Data Lineage (Lineage dei Dati)

Visualizzazione interattiva delle dipendenze upstream/downstream tra elementi di dati. Risponde alla domanda "da dove viene questo dato?" navigando ricorsivamente attraverso le dipendenze. Aggiornata automaticamente al cambio del modello. Dagster implementa lineage a livello di colonna [^491^][^576^]. *Applicabilità LCA: altissima* — traccia un elementary flow (es. CO₂) attraverso tutta la supply chain fino al processo origine. Nessun tool LCA attuale offre questa capacità, nonostante ISO 14040/44 ne richieda la tracciabilità [^1039^].

#### 8.2.3 Semantic Zooming (Zoom Semantico)

Tecnica in cui il livello di dettaglio cambia con il fattore di zoom: a zoom out si aggregano dati (fasi di vita), a zoom medio si vedono processi, a zoom in i singoli flussi. yFiles implementa Level-of-Detail rendering per grafi di grandi dimensioni [^489^]. *Applicabilità LCA: alta* — permette di navigare modelli con 500+ processi senza perdita di contesto: fasi a vista d'insieme, processi a livello intermedio, flussi nel dettaglio.

#### 8.2.4 Mini-Map (Mappa di Navigazione)

Miniatura dell'intero grafo con rettangolo colorato che indica la viewport attuale; click per navigazione istantanea. Houdini offre il modello ottimale: bottom-left, interattiva, con apparenza condizionata al superamento della viewport [^594^][^554^]. *Applicabilità LCA: alta* — modelli industriali (automobile) hanno 500+ processi. La mini-map permette di saltare a qualsiasi area in <1s, con indicatori colore per fase di vita.

#### 8.2.5 Force-Directed Layout (Layout a Forza)

Algoritmo che simula forze fisiche: attrazione lungo gli archi, repulsione tra nodi. D3.js, Cytoscape.js e Sigma.js offrono implementazioni ottimizzate [^572^][^578^]. *Applicabilità LCA: media* — utile per esplorazione visiva di grafi LCA; meno adatto della variante DAG layout (Sugiyama) che rispetta la direzionalità dei flussi. Ideale come modalità esplorativa alternativa al layout gerarchico.

#### 8.2.6 Multiple Views (Viste Multiple)

Visualizzazione dello stesso dataset attraverso prospettive sincronizzate: tabella, grafo, treemap, timeline, Kanban, mappa. Il cambio è istantaneo, senza ricaricamento. Notion offre 7+ view types [^658^][^666^]. *Applicabilità LCA: altissima* — il 52% degli utenti LCA usa Excel per visualizzazione perché i software LCA non offrono viste alternative [^EarthShift^]. Viste necessarie: Table, Graph, Sankey, Treemap, Timeline, Kanban, Map.

#### 8.2.7 Color-Coded Wires (Connessioni Colorate)

Codifica colore degli archi in base al tipo di dato. Ogni tipo ha colore distintivo; connessioni incompatibili generano warning visivi (arco tratteggiato). LabVIEW (arancione=floating point, blu=intero, verde=booleano) e Blender (verde=shader, grigio=value) sono i riferimenti [^498^][^544^]. *Applicabilità LCA: alta* — tipi di flusso con palette dedicata: verde=materiale (kg), giallo=energia (kWh), blu=acqua (m³), grigio=servizio, rosso=emissione (kg CO₂eq). Type checking visivo che previene errori di modellazione.

#### 8.2.8 Traffic Light State (Semaforo di Stato)

Codifica a tre colori sul nodo: rosso = non configurato/in errore, giallo = pronto, verde = eseguito/con successo. Visibile direttamente sul grafo senza apertura di panel. KNIME e n8n lo implementano per stati di esecuzione [^564^][^562^]. *Applicabilità LCA: alta* — per modelli con 100+ processi, identifica a colpo d'occhio quali processi hanno dati mancanti, quali sono pronti e quali hanno calcolato.

---

### 8.3 Pattern di Navigazione e Grafo

#### 8.3.1 Drag-link → Search (Trascina-Link → Cerca)

L'utente trascina un arco da una porta verso lo spazio vuoto; al rilascio appare un menu di ricerca filtrato per tipo compatibile. Selezionando un risultato, il nodo viene creato e auto-connesso. Blender ne ha l'implementazione di riferimento [^544^][^545^]. *Applicabilità LCA: alta* — trascina flusso "acciaio (kg)" → ricerca mostra solo processi compatibili ("assemblaggio", "trattamento termico"). Riduce il tempo di collegamento da 30-60s a <5s.

#### 8.3.2 Dive-in Breadcrumb (Breadcrumb di Navigazione Gerarchica)

Gadget che mostra il percorso gerarchico nel grafo (es. ProductSystem > Manufacturing > Assembly). Click su qualsiasi componente per saltare a quel livello. Shortcut Tab per entrare/uscire da gruppi. Houdini (`/obj/geo1/box1`) e TouchDesigner sono i riferimenti [^547^][^554^][^519^]. *Applicabilità LCA: alta* — i product system sono gerarchici: Product System → Life Cycle Stage → Process Group → Process. Fornisce orientamento costante con 10+ livelli di annidamento.

#### 8.3.3 Node Groups / Subgraphs (Gruppi di Nodi)

Raggruppamento di nodi in unità contenitore con interfaccia Input/Output esposta. Riutilizzabile in punti diversi del modello; modifiche propagate a tutte le istanze. Editing interno via Tab. Blender (`Ctrl+G`), Substance (Graph Instances), LabVIEW (SubVIs) e KNIME (Metanodes) [^591^][^138^][^486^][^564^]. *Applicabilità LCA: altissima* — "Steel Production" come gruppo di 12 processi elementari riutilizzabile in 15 punti. KNIME dimostra che i metanodi corrispondono ai "System Process" LCA [^564^].

#### 8.3.4 Named Reroute Nodes (Nodi Rerouting Nominati)

Nodi "tunnel" che collegano aree distanti del grafo senza arco fisico visibile. Nodo "Declaration" per il punto di origine; nodi "Usage" multipli per i ricevitori. Nomi descrittivi e colori identificano il flusso. Unreal Blueprints (`DblClick` su wire) [^117^]. *Applicabilità LCA: media-alta* — flussi ubiqui (elettricità, acqua, trasporto) connettono decine di processi. I Named Reroutes eliminano lo "spaghetti wiring" mantenendo tracciabilità.

#### 8.3.5 Quickmarks (Segnalibri Veloci)

Segnalibri numerici (1-5) che memorizzano posizione e zoom level del canvas. `Ctrl+1..5` per impostare, `1..5` per richiamare. Backtick per toggle tra due view. Houdini [^594^][^604^]. *Applicabilità LCA: media* — in modelli con 200+ processi, l'analista salta frequentemente tra aree (upstream, processo centrale, downstream). Quickmarks riducono la navigazione a <1s.

#### 8.3.6 Auto-Layout DAG (Layout Automatico per Grafi Diretti)

Algoritmo di Sugiyama che organizza nodi in livelli direzionali: sorgenti in alto, destinazioni in basso, minimizzazione incroci. Eseguito on-demand senza sovrascrivere posizioni manuali. Dagre ed ELK sono i riferimenti [^572^][^578^]. *Applicabilità LCA: media* — i flussi LCA sono direzionali (cradle-to-grave); il layout a livelli è semanticamente appropriato. Complementare al layout manuale.

#### 8.3.7 Frame Nodes (Nodi Cornice)

Cornice non distruttiva che raggruppa visivamente nodi correlati. Label e colore configurabili, ridimensionabile. I nodi dentro si muovono insieme ma la semantica non cambia. Blender (`F` shortcut) e Houdini (Network Boxes) [^596^][^598^]. *Applicabilità LCA: alta* — le 4 fasi del ciclo di vita si mappano su frame colorati: Raw Material (blu), Manufacturing (arancione), Use Phase (verde), End of Life (grigio).

#### 8.3.8 Dirty Flags (Indicatori di Modifica)

Marcatori visivi (archi rossi) che indicano quali nodi necessitano ricalcolo dopo una modifica. Propagazione automatica downstream. Houdini marca catene dirty e evidenzia path di ricalcolo [^568^]. *Applicabilità LCA: alta* — i calcoli LCA (Monte Carlo con 10.000+ iterazioni) sono lenti. Dirty flags indicano esattamente quali processi richiedono ricalcolo, evitando ricalcoli inutili.

---

### 8.4 Pattern di Collaborazione

#### 8.4.1 Multiplayer Real-Time (Collaborazione in Tempo Reale)

Sistema che permette a più utenti di editare simultaneamente con visibilità istantanea delle modifiche. Sincronizzazione via WebSocket con risoluzione conflitti (OT o CRDT). Figma gestisce 2.2 miliardi cambiamenti/giorno con property-level last-writer-wins [^656^][^990^]. *Applicabilità LCA: media-alta* — LCA è collaborativa per natura (processo + analista + reviewer + verificatore). Nessun tool LCA supporta multiplayer editing [^Insight7^].

#### 8.4.2 Branch/Merge (Ramificazione e Fusione)

Ogni linea di sviluppo è un branch indipendente che può essere fuso nel ramo principale. Permette esperimenti paralleli senza rischio per il modello principale. Git, GitHub e Onshape (Git-like per CAD) [^522^][^1017^][^459^]. *Applicabilità LCA: altissima* — ogni scenario LCA (what-if, sensitivity) è un branch: `main`, `branch/scenario-recycling`, `branch/alternative-supplier`. Onshape dimostra che il modello Git funziona per dati non-code [^467^].

#### 8.4.3 Visual Diff (Differenza Visiva)

Visualizzazione side-by-side tra versioni: nodi aggiunti (verde), rimossi (rosso), modificati (arancione). Diff quantitativi con before/after/delta%. GitHub, Onshape e openLCA CS [^1015^][^523^]. *Applicabilità LCA: alta* — confronto sistematico tra scenari con evidenza dei processi che cambiano maggiormente. Per verifica EPD, mostra esattamente cosa è cambiato.

#### 8.4.4 Presence Indicators (Indicatori di Presenza)

Sistema visivo di chi sta lavorando sul documento: avatar stack nell'header, cursori colorati nel canvas, selezione evidenziata, stato attivo/idle. Figma coalesce dati effimeri a ~30 FPS senza salvarli [^656^][^1036^]. *Applicabilità LCA: media* — review collaborativa: il reviewer vede dove sta lavorando l'analista. "Follow presenter" per walkthrough del modello.

#### 8.4.5 Threaded Comments (Commenti in Thread)

Annotazione ancorata a elementi del grafo (nodi/archi) con conversazioni in thread, @mentions e stati (aperto/risolto). Figma e Notion [^1066^][^998^][^1054^]. *Applicabilità LCA: altissima* — "Questo fattore di emissione è datato 2019", "Assunzione: trasporto su strada, confermare?". Gli stati aperto/risolto integrano il workflow di critical review ISO 14044 [^1033^].

#### 8.4.6 Audit Trail (Traccia di Audit)

Registro immutabile di ogni modifica: chi, quando, quale elemento, valori pre/post. Snapshot ricostruibili; firma crittografica per verificabilità. Git commit history e LCA Collaboration Server [^522^][^1039^]. *Applicabilità LCA: altissima* — requisito normativo ISO 14040/44. Ogni modifica a processo, cambio database, aggiunta flow deve essere tracciata [^1043^].

#### 8.4.7 Review Workflow (Flusso di Revisione)

Workflow con stati: DRAFT → UNDER_REVIEW → REVISION_REQUESTED → APPROVED → PUBLISHED. Transizioni condizionate a checklist e ruoli separati. GitHub PR e openLCA CS [^1015^][^523^]. *Applicabilità LCA: alta* — per EPD e asserzioni comparative, ISO 14044 richiede critical review da terza parte indipendente [^1033^].

---

### 8.5 Pattern AI-Native

#### 8.5.1 RAG — Retrieval-Augmented Generation

Architettura che combina LLM con retrieval su knowledge base esterna. Per ogni query, il sistema recupera documenti rilevanti e li inietta nel contesto del prompt. Cursor usa @codebase per grounding [^714^]. *Applicabilità LCA: altissima* — l'AI usa @database per groundare risposte in dati verificati (ecoinvent, EF). Il rischio di hallucination è 37-40% senza grounding [^669^].

#### 8.5.2 GraphRAG

Variante di RAG in cui la knowledge base è un grafo strutturato. Il retrieval naviga le relazioni del grafo per trovare entità e connessioni rilevanti. Paper Tu et al. 2024: Hit@10 >88% per LCA data [^Tu2024^]. *Applicabilità LCA: altissima* — un modello LCA è un grafo. Permette query come "Trova processi che usano energia elettrica con GWP > 10 kg CO₂eq". Precision su Amazon EF: 86.9% [^Zhao2025^].

#### 8.5.3 Context Awareness (Consapevolezza di Contesto)

L'AI conosce il progetto aperto: processi, flussi, database usati, metodi di impatto. Ogni suggerimento si riferisce al modello attivo. Cursor indicizza l'intero codebase con chunking semantico [^714^]. *Applicabilità LCA: alta* — l'AI risponde a "Perché questo processo contribuisce tanto al GWP?" con riferimenti specifici ai dati del modello, non genericamente.

#### 8.5.4 Streaming UI (Interfaccia in Streaming)

Risultati che arrivano progressivamente (token per token, chunk per chunk) anziché tutti insieme. Include placeholder e indicatori di progresso. Metriche: TTFT <2s, TPS per fluidità [^648^][^701^]. *Applicabilità LCA: alta* — calcolo impatto in streaming (risultati parziali per categoria), grafo che si costruisce pezzo per pezzo. Riduce percezione di lentezza su calcoli lunghi (Monte Carlo).

#### 8.5.5 Side-by-Side AI Workspace (Spazio di Lavoro AI Affiancato)

Pannello AI collocato lateralmente all'area di lavoro principale per conversazione contestuale e editing coordinato. Cursor usa quattro colonne: navigazione, editor, content, AI Chat Panel (⌘L) [^664^]. *Applicabilità LCA: alta* — l'analista consulta l'AI nel pannello laterale mentre modella: "Aggiungi fase end-of-life" → l'AI propone → l'utente applica con un click. Pattern assistive design [^674^][^314^].

#### 8.5.6 Plan Mode (Modalità Pianificazione)

L'agente AI produce prima un piano dettagliato ed editabile; l'utente approva prima dell'esecuzione. Ogni task è modificabile, rimovibile o confermabile. Cursor Agent Mode [^714^]. *Applicabilità LCA: altissima* — critico per trust. L'AI mostra: "1. Creo processo 'Produzione PET' 2. Aggiungo input da Ecoinvent v3.9 3. Calcolo ReCiPe 2016". L'utente reviewa prima dell'esecuzione.

---

### 8.6 Tabella Riassuntiva Master

La Tabella 8.1 elenca i 42 pattern del glossario con definizione one-line, tool di origine, applicabilità LCA e priorità implementativa. Il lettore — metodologo LCA in dialogo con il team di sviluppo — può usarla come checklist per la progettazione funzionale.

**Tabella 8.1 — Glossario master dei pattern UI per software LCA**

| # | Pattern | Definizione | Tool Origine | App. LCA | Priorità |
|---|---------|-------------|-------------|----------|----------|
| 1 | Command Palette | Interfaccia modale ⌘K per eseguire qualsiasi azione digitandone il nome | Raycast, Linear, Superhuman [^667^][^653^] | Alta | Critica |
| 2 | Ghost Text | Suggerimento inline sfumato generato da LLM, accettabile con Tab | Cursor, GitHub Copilot [^714^] | Alta | Critica |
| 3 | Agent Mode | Piano visibile editabile → esecuzione autonoma → review umana | Cursor Composer, Replit [^714^][^646^] | Alta | Critica |
| 4 | Block-Based Editing | Contenuto come blocchi indipendenti trascinabili e convertibili | Notion, Coda [^720^] | Media | Media |
| 5 | Progressive Disclosure | Complessità rivelata gradualmente: wizard → form → espert | ChatGPT, Canva [^669^][^670^] | Altissima | Critica |
| 6 | Keyboard-First | Ogni azione eseguibile da tastiera; mouse opzionale | Linear, Superhuman [^653^][^711^] | Alta | Alta |
| 7 | Optimistic UI Updates | UI aggiornata istantaneamente, rollback se il server fallisce | Linear, Figma [^711^][^721^] | Alta | Alta |
| 8 | Node-Graph Canvas | Area di lavoro 2D con nodi connessi da archi direzionali | KNIME, React Flow [^544^][^572^] | Altissima | Critica |
| 9 | Data Lineage | Visualizzazione dipendenze upstream/downstream tra dati | Dagster, Dataiku [^491^][^576^] | Altissima | Alta |
| 10 | Semantic Zooming | Livello di dettaglio che cambia con il fattore di zoom | yFiles, Gephi [^489^] | Alta | Media |
| 11 | Mini-Map | Miniatura del grafo con indicatore viewport per navigazione rapida | Houdini, openLCA 2 [^594^][^164^] | Alta | Alta |
| 12 | Force-Directed Layout | Posizionamento automatico simulando attrazione/repulsione fisica | D3.js, Cytoscape.js [^572^][^578^] | Media | Bassa |
| 13 | Multiple Views | Stesso dataset visto come tabella, grafo, treemap, timeline, Kanban | Notion, Airtable [^658^][^666^] | Altissima | Critica |
| 14 | Color-Coded Wires | Archi colorati per tipo di dato; warning su connessioni invalide | LabVIEW, Blender [^498^][^544^] | Alta | Alta |
| 15 | Traffic Light State | Semaforo rosso/giallo/verde per stato di ogni nodo | KNIME, n8n [^564^] | Alta | Alta |
| 16 | Drag-link → Search | Trascina arco verso spazio vuoto → ricerca filtrata → auto-connect | Blender [^544^][^545^] | Alta | Alta |
| 17 | Dive-in Breadcrumb | Percorso gerarchico cliccabile per navigare livelli del grafo | Houdini, TouchDesigner [^547^][^519^] | Alta | Alta |
| 18 | Node Groups / Subgraphs | Raggruppamento nodi con interfaccia I/O, riutilizzabile | Blender, KNIME [^591^][^564^] | Altissima | Alta |
| 19 | Named Reroute Nodes | Nodi tunnel per collegare aree distanti senza arco visibile | Unreal Blueprints [^117^] | Media-Alta | Media |
| 20 | Quickmarks | Segnalibri numerici per saltare istantaneamente tra aree del canvas | Houdini [^594^] | Media | Bassa |
| 21 | Auto-Layout DAG | Algoritmo Sugiyama per livelli direzionali con minimizzazione incroci | Dagre, ELK [^572^][^578^] | Media | Media |
| 22 | Frame Nodes | Cornice non distruttiva per raggruppare visivamente nodi correlati | Blender, Houdini [^596^][^598^] | Alta | Alta |
| 23 | Dirty Flags | Marcatori visivi di nodi che necessitano ricalcolo post-modifica | Houdini [^568^] | Alta | Media |
| 24 | Multiplayer Real-Time | Editing simultaneo multi-utente con sincronizzazione istantanea | Figma, Google Docs [^656^][^990^] | Media-Alta | Media |
| 25 | Branch/Merge | Linee di sviluppo indipendenti fusi selettivamente nel ramo principale | Git, Onshape [^522^][^1017^] | Altissima | Alta |
| 26 | Visual Diff | Confronto side-by-side: aggiunti (verde), rimossi (rosso), modificati (arancione) | GitHub, Onshape [^1015^] | Alta | Alta |
| 27 | Presence Indicators | Avatar, cursori colorati e selezione evidenziata per utenti attivi | Figma [^656^][^1036^] | Media | Media |
| 28 | Threaded Comments | Annotazioni ancorate a nodi/archi con thread, @mentions e stati | Figma, Notion [^1066^][^998^] | Altissima | Alta |
| 29 | Audit Trail | Registro immutabile di ogni modifica con autore, timestamp e valori pre/post | Git, openLCA CS [^522^][^1039^] | Altissima | Critica |
| 30 | Review Workflow | Stati espliciti: DRAFT → UNDER_REVIEW → APPROVED → PUBLISHED | GitHub PR, openLCA CS [^1015^][^523^] | Alta | Alta |
| 31 | RAG | LLM combinato con retrieval su knowledge base esterna verificata | Cursor, Perplexity [^714^] | Altissima | Critica |
| 32 | GraphRAG | RAG su grafo strutturato; retrieval naviga relazioni del grafo | Neo4j, MS Research [^Tu2024^] | Altissima | Alta |
| 33 | Context Awareness | AI che conosce il modello aperto: processi, flussi, database, metodi | Cursor (@codebase) [^714^] | Alta | Alta |
| 34 | Streaming UI | Risultati che arrivano progressivamente con placeholder e indicatori | ChatGPT, Cursor [^648^][^701^] | Alta | Media |
| 35 | Side-by-Side AI Workspace | Pannello AI affiancato al canvas per conversazione e editing coordinato | Cursor (⌘L) [^664^] | Alta | Alta |
| 36 | Plan Mode | Piano dettagliato ed editabile approvato dall'utente prima dell'esecuzione | Cursor Agent [^714^] | Altissima | Alta |
| 37 | Typed Ports | Porte di input/output con tipo di dato; connessioni solo tra tipi compatibili | KNIME, ComfyUI [^562^][^557^] | Alta | Alta |
| 38 | Inline Editing | Modifica dei parametri direttamente sul nodo senza aprire dialoghi | ComfyUI, Substance [^561^][^491^] | Alta | Media |
| 39 | Skeleton Screens | Placeholder che matchano il layout esatto durante caricamento | Linear [^711^] | Alta | Bassa |
| 40 | @mentions e Notifications | Notifiche a utenti specifici con @nome su commenti e annotazioni | Notion, Figma [^998^] | Media | Media |
| 41 | Workspace Protection | Modelli certificati modificabili solo via branch e merge approvato | Onshape [^457^] | Alta | Media |
| 42 | Alignment Tools | Strumenti di allineamento automatico per layout manuale pulito | Unreal (`Shift+W/A/S/D`) [^119^] | Media | Bassa |

La tabella offre 42 pattern distribuiti su 5 categorie funzionali. La distribuzione per priorità implementativa evidenzia un profilo realistico per un team di sviluppo: 7 pattern critici da includere nel MVP (command palette, ghost text, agent mode, progressive disclosure, node-graph, multiple views, audit trail, RAG), 21 pattern ad alta priorità per il rilascio v2, e 14 pattern medi/bassi per iterazioni successive. La colonna "App. LCA" segnala 8 pattern con applicabilità "altissima" — questi sono i non-negoziabili per chi costruisce un software LCA moderno, poiché rispondono direttamente a vincoli normativi (ISO 14040/44), pain point utente documentati (learning curve, tempo di modellazione) o opportunità di differenziazione competitiva (collaborazione, AI grounding).
