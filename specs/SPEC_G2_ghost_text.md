# SPEC G2 — Ghost Text inventory

> **Sprint**: V1.5 partial — G2 (~2 settimane)
> **Branch**: `night/G2-ghost-text-inventory`
> **Autore SPEC**: Architect-GUI
> **Data**: 2026-05-05
> **Implementer target**: Claude Code Ubuntu (chat dev separata)
> **Riferimenti**: DESIGN_GUI.md §3 (P5 AI Grounding), §4 (V1.5 partial roadmap), §6 (decisioni cross-sprint). MASTER_PLAN §12 (V1.5 partial). Kimi `lca_ui_studio_sec05.md` Principio 5 (AI Grounding) + Principio 7 (Progressive Disclosure layer 2). `lca_ui_studio_sec06.md` §6.3.1 S-4 (ghost text MoSCoW Should-P1, partial implementation). `lca_ui_studio_sec08.md` Pattern Ghost Text (Cursor/Copilot adapted).

---

## 1. Goal

Aggiungere al frontend V1 un'interazione **ghost text inline** dentro la BomTable del match page (`/projects/:pid/match`): mentre il consulente digita il nome di un flusso/processo nelle celle, sotto il testo compare in grigio chiaro un suggerimento dal database ecoinvent (top match dal ChromaDB matcher index esistente). `Tab` accetta il suggerimento, `Esc` lo dismisses, le frecce `↓`/`↑` ciclano fra i top-K alternativi. La proposta ha sempre confidence score visibile e fonte citata (database + version + ID processo) come da P5 AI Grounding.

Il valore atteso è duplice. Operativamente: ridurre il tempo di compilazione di una BomTable da ~30-60 secondi per riga a ~5-10 secondi per riga nelle celle dove il matcher ha alta confidence (>85%). Strategicamente: introdurre il primo pattern AI-native visibile e percepibile come "magico" dall'utente (non un comando esplicito da imparare), preparando il terreno per V2 Agent Mode senza introdurre rischi di hallucination — il ghost text è retrieval-only su database verificato, niente LLM nel loop.

Lo sprint G2 non riscrive la BomTable. Aggiunge un componente wrapper (`GhostInput` / `GhostTextarea`) che si sostituisce a `<input>`/`<textarea>` in pochi punti chirurgici delle celle "name" / "matched process" della tabella. Aggiunge un endpoint backend `/api/projects/{pid}/suggest` che incapsula lookup ChromaDB. Aggancia il pattern `registerCommand` di G1 per dare comandi rapidi tipo "accept all suggestions ≥95%" da palette.

**Definizione di successo**: un consulente che compila una BomTable di 25 righe (Journey A di Kimi sec06) impiega meno della metà del tempo richiesto pre-G2, mantenendo o aumentando la qualità del match (% righe con confidence ≥85% accettate al primo tentativo). Tutte le proposte AI sono cliccabili fino al record ecoinvent originale (P5 grounding), niente proposta arriva senza confidence score visibile.

---

## 2. Pre-flight

Claude Code esegue questa checklist e blocca se qualcosa non torna.

**Verifica frontend**:
- Conferma che la BomTable esista in `frontend/src/` (probabilmente in `components/bom-table/` o simili). Documenta path esatto e numero righe nel REPORT.
- Conferma struttura BomRow (campi: nome libero descrittivo, matched process id/uuid, quantity Quantity-native, unit). Schema canonico documentato in MASTER_PLAN §3.2 e progettato in M2.x.2.
- Conferma che esiste già un comportamento per "edit cell" (probabilmente `<input>` controlled + onBlur save). Il wrapper Ghost\* deve sostituire chirurgicamente solo il render dell'input, mantenendo la signature del comportamento esistente.
- Conferma che `useCommandRegistry` di G1 è disponibile (deve esserlo: G1 merged main).

**Verifica backend**:
- Conferma esistenza ChromaDB embedding index del matcher M1. Path probabile: `backend/services/matcher/` o simili. Documentato in MASTER_PLAN §3.1 (multilingual-e5-large 1024-dim, 23k processi indicizzati).
- Conferma che esiste già un endpoint matcher esistente (probabilmente `/api/projects/{pid}/match` o `/api/matcher/...`) che leverages quell'index. Se sì, il nuovo endpoint `/api/projects/{pid}/suggest` ne riusa il client/funzioni interne.
- Conferma che il client ChromaDB del matcher può rispondere a query top-K rapide (<200ms p95) — se l'index è stato costruito per batch matching, potrebbe avere overhead sui retrieval singoli; in tal caso pre-load del client + caching warm.

**Verifica test baseline**:
- Vitest baseline post-G1: 12 pass. Annotare nel REPORT.
- Backend pytest baseline post-M3.1.1: **366 default + 4 preflight skip senza `OLCA_IPC_PORT`** = 370 totali. Annotare.
- Bundle baseline post-G1: main 90.84 KB gzip + palette lazy chunk 17.12 KB.
- main HEAD post-merge G1 (commit `6815de6`) atteso allineato con il post-merge backend M3.1.1 (commit `b8d6002`). Verificare che G1 sia stato rebased/merged sopra `b8d6002` prima di iniziare G2 — diversamente il backend del frontend potrebbe non avere le 7 entità nuove M3.1.1 (actors/locations/sources/lcia_method/lcia_categories/nw_sets) che però per G2 non sono critiche (G2 non tocca questi domini).

**Verifica ambiente dev** (da `_CURRENT_STATE_20260505_0100.md`):
- venv Python: `.venv/` alla root del repo (NON in `backend/`). Attivare con `source .venv/bin/activate` prima di pytest.
- Backend dev server: `uvicorn :8000` lanciabile da repo root.
- Frontend dev server: Vite `:5173`.
- olca-ipc 2.6.2 + olca-schema 2.6.2 nel venv. **Non rilevanti per G2** (retrieval-only su ChromaDB) ma utili come check ambiente integro.
- rclone mount Drive su workstation Mirko: `~/drive/Substitute HiQ cortex/`. Per scambio docs / lettura SPEC, NON per upload payload binari (ADR 24 MASTER_PLAN: Drive REST trunca 48 byte EOCD).
- Convenzioni branch (cumulative MASTER_PLAN + STATE): `night/G2-ghost-text-inventory`, atomic same-branch cleanup ≤1h, branch chain max 5, italiano-concreto, idempotency non-negotiable. PR strategy = 1 squash per sprint singolo (ADR 29).
- Verify-merge-before-branch-delete (ADR 34, post-incidente M3.1.1): prima di `git push origin --delete <branch>`, controllare con `git log origin/main..<branch> --oneline` che il branch sia stato assorbito.

**No-go condition**:
- Se ChromaDB matcher index non è raggiungibile via codice backend (es. è un servizio esterno non containerizzato), STOP — escalation a Mirko per discutere alternative (Postgres pg_trgm? Qdrant? Lookup deterministico su nomi ecoinvent?).
- Se la BomTable non ha celle modificabili (è solo display), STOP — il ghost text non ha dove agganciarsi, ridefinire scope con Mirko.
- Se G1 non è effettivamente in main (verifica `git log main --oneline | grep "G1"` o equivalente), STOP — il registry `useCommandRegistry` non esiste e G2 non ha il punto di aggancio per i 3 comandi palette correlati. Aspettare merge G1.

---

## 3. Architettura componenti

### 3.1 Layout cartelle

```
frontend/src/
├── components/
│   └── ghost-text/                       # NUOVO modulo
│       ├── GhostInput.tsx                # wrapper <input> con suggest
│       ├── GhostTextarea.tsx             # wrapper <textarea> (opzionale, stretch)
│       ├── SuggestionOverlay.tsx         # ghost text render + alternatives popup
│       ├── ConfidenceBadge.tsx           # badge "94% ecoinvent 3.9 IT"
│       ├── __tests__/
│       │   ├── GhostInput.test.tsx
│       │   └── useSuggest.test.ts
│       └── index.ts
├── lib/
│   ├── suggest/                          # NUOVO modulo logico
│   │   ├── api.ts                        # fetch wrapper /api/projects/{pid}/suggest
│   │   ├── types.ts                      # SuggestRequest, SuggestResult
│   │   ├── hooks/
│   │   │   ├── useSuggest.ts             # debounced TanStack Query
│   │   │   └── useGhostText.ts           # accept/dismiss/cycle state machine
│   │   └── telemetry.ts                  # opt-in accept/reject log
│   └── commands/
│       └── definitions/
│           └── ghost-text.ts             # NUOVO: comandi palette G2-related
└── components/bom-table/                  # MODIFICA chirurgica
    └── BomRowCell.tsx                    # sostituzione <input> con <GhostInput>
                                          # SOLO nelle celle "name" / "match"
backend/
├── api/
│   └── projects/
│       └── suggest.py                    # NUOVO endpoint
├── services/
│   └── matcher/
│       └── suggest_top_k.py              # NUOVO wrapper su ChromaDB client esistente
└── tests/
    └── test_suggest_endpoint.py          # NUOVO pytest
```

### 3.2 Backend — endpoint `/api/projects/{pid}/suggest`

```python
# backend/api/projects/suggest.py
from fastapi import APIRouter, Query
from pydantic import BaseModel
from typing import Literal

router = APIRouter()

class SuggestResult(BaseModel):
    process_id: str          # ecoinvent UUID
    label: str               # "electricity, medium voltage, IT, 2023"
    db_source: str           # "ecoinvent 3.9"
    location: str | None     # "IT"
    confidence: float        # 0.0..1.0
    rationale: str | None    # opzionale, "matched on: electricity + IT"

class SuggestResponse(BaseModel):
    query: str
    context: str             # "bom.name" | "bom.match" | "process.input" | ...
    results: list[SuggestResult]
    cache_hit: bool          # diagnostic

@router.get("/api/projects/{pid}/suggest", response_model=SuggestResponse)
def suggest(
    pid: str,
    q: str = Query(..., min_length=2, max_length=200),
    context: Literal["bom.name", "bom.match", "process.input", "process.output"] = "bom.name",
    top_k: int = Query(5, ge=1, le=10),
    location_hint: str | None = None,  # opzionale, es. "IT" se progetto è italiano
):
    """
    Top-K suggest dal ChromaDB matcher index.
    Retrieval-only, no LLM. <200ms p95 atteso.
    """
    # implementation: leverage ChromaDB client del matcher M1
    # filter by context-appropriate flow types (bom.name → all flows;
    # process.input → input flow types; process.output → output flow types)
    ...
```

**Note implementative backend**:
- L'endpoint deve riusare il client ChromaDB già istanziato per il matcher M1, non aprirne uno nuovo a ogni request (overhead init). Verificare pattern singleton/lifespan FastAPI già in uso.
- `confidence` viene direttamente dal cosine similarity ChromaDB normalizzato in [0,1]. Threshold convenzionali: ≥0.85 alta, 0.65-0.85 media, <0.65 bassa.
- `rationale` è opzionale e best-effort: se il matcher M1 ha già una funzione di explain (es. token overlap), riusarla. Altrimenti omettere — non bloccante.
- Il `pid` permette filtering futuro project-scoped (es. "preferisci processi della stessa location del progetto"), non implementato in G2 ma signature pronta.
- Cache: TanStack Query lato frontend cacha per 60s; backend può aggiungere LRU in-memory (max 1k entries) per query identiche frequenti. Non obbligatorio in G2.

### 3.3 Frontend — `useSuggest` hook

```typescript
// lib/suggest/hooks/useSuggest.ts
import { useQuery } from '@tanstack/react-query';
import { useDebouncedValue } from '../../../hooks/useDebouncedValue'; // assumere esista o creare

export function useSuggest({
  query,
  context,
  projectId,
  enabled = true,
  debounceMs = 300,
}: {
  query: string;
  context: 'bom.name' | 'bom.match' | 'process.input' | 'process.output';
  projectId: string;
  enabled?: boolean;
  debounceMs?: number;
}) {
  const debounced = useDebouncedValue(query, debounceMs);
  return useQuery({
    queryKey: ['suggest', projectId, context, debounced],
    queryFn: () => fetchSuggest({ pid: projectId, q: debounced, context }),
    enabled: enabled && debounced.length >= 2,
    staleTime: 60_000,
    gcTime: 300_000,
    refetchOnWindowFocus: false,
  });
}
```

**Comportamento**:
- Query <2 caratteri → no fetch (default React Query disabled).
- Debounce 300ms tipico, configurabile (input lento può scendere a 200ms, input rapido a 400ms).
- Cache 60s evita re-fetch spam quando l'utente esita.
- `gcTime` 5min (era `cacheTime` in v4 React Query) per riusare risultati appena dismessi.

### 3.4 Frontend — `useGhostText` state machine

State enum:
- `idle` — nessuna proposta visibile
- `loading` — query in corso, nessuna proposta da renderizzare
- `proposing` — proposta visibile, indice 0 dei top-K
- `cycling` — utente sta cyclando con ↓/↑ fra alternatives
- `dismissed` — utente ha premuto Esc, no propose finché query cambia

Transitions:
- `idle` + query ≥2 chars → `loading`
- `loading` + result ≥1 → `proposing(0)`
- `loading` + result 0 → `idle`
- `proposing(i)` + Tab → accept(results[i]), → `idle`
- `proposing(i)` + ↓ → `cycling(i+1)` (mod len)
- `proposing(i)` + ↑ → `cycling(i-1)` (mod len)
- `proposing(i)` + Esc → `dismissed`
- `dismissed` + query change → `idle`
- any + query empty → `idle`

L'hook ritorna: `{ ghostText, alternatives, confidence, source, accept, dismiss, cycleNext, cyclePrev, isLoading }`.

### 3.5 Frontend — `GhostInput` component

```tsx
// components/ghost-text/GhostInput.tsx
interface GhostInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  context: 'bom.name' | 'bom.match' | 'process.input' | 'process.output';
  projectId: string;
  onAccept?: (result: SuggestResult) => void;
}

export function GhostInput({ context, projectId, onAccept, value, onChange, ...rest }: GhostInputProps) {
  const ghost = useGhostText({ query: String(value ?? ''), context, projectId });
  // render: <input> + overlay assoluto col ghost text
  // keydown handler intercetta Tab/Esc/↓/↑ secondo state machine
  // accept → onAccept callback + onChange con il valore accettato
}
```

**Accessibility**:
- Input ha `aria-autocomplete="inline"` + `aria-haspopup="listbox"` quando alternatives sono visibili.
- Ghost text reso come `<span aria-hidden="true">` per non confondere screen reader (lui annuncia solo cosa l'utente sta digitando, non il suggerimento).
- Quando l'utente preme Tab e accetta, screen reader announce: `aria-live="polite"` con "Accettato: <label>, confidence X%, fonte Y" — questo è critico per non-vedenti che altrimenti non saprebbero cosa hanno accettato.
- Frecce ↓/↑ aprono visivamente il popup `<ul role="listbox">` con alternatives, con `aria-activedescendant`.

### 3.6 Aggancio BomTable (modifica chirurgica)

```tsx
// components/bom-table/BomRowCell.tsx (MODIFICA)
// Prima: <input type="text" value={row.name} onChange={...} onBlur={save} />
// Dopo:
<GhostInput
  type="text"
  value={row.name}
  onChange={...}
  onBlur={save}
  context="bom.name"
  projectId={pid}
  onAccept={(result) => {
    save({ ...row, name: result.label, matched_process_id: result.process_id });
    logTelemetry('accept', { context: 'bom.name', confidence: result.confidence });
  }}
/>
```

L'aggancio è limitato a celle dove ha senso: nome flusso, processo matched. **Non** alle celle quantity (numerica, ghost text non è il pattern giusto), **non** alle celle unit (drop-down esistente, no free text). Se Claude Code identifica altre celle naturali (es. "supplier", "geographical scope" se esiste), valuta caso per caso con escalation Mirko se non ovvio.

### 3.7 Comandi palette correlati G2

Nuovi comandi registrati al bootstrap (estendono il catalog G1 senza modificare le definizioni esistenti):

| ID | Label | Mnemonic | Action |
|----|-------|----------|--------|
| `act.accept-all-high-confidence` | Accetta tutti i suggerimenti AI ≥95% nella riga corrente | (no mnemonic) | scan riga, accept top-1 di ogni cella ghost-enabled se confidence ≥0.95 |
| `act.toggle-ghost-text` | Disabilita/Abilita ghost text temporaneamente | `⌘⇧Space` | flag in zustand store, persistito localStorage |
| `act.show-suggest-stats` | Mostra statistiche accept/reject ghost text (sessione corrente) | (no mnemonic) | apre toast/modal con counter |

Il primo comando è il più potente: il consulente può digitare un valore approssimativo, vedere il ghost text confidence ≥95%, e dopo aver lavorato la riga lancia `⌘P` (palette) → "accept-all" → accetta in batch.

### 3.8 Telemetry minimale (opt-in, off-by-default)

`lib/suggest/telemetry.ts`:

```typescript
type TelemetryEvent =
  | { type: 'accept'; context: string; confidence: number; rank: number }
  | { type: 'reject'; context: string; confidence: number; rank: number }
  | { type: 'dismiss'; context: string }
  | { type: 'cycle'; context: string; direction: 'next' | 'prev' };

// store in localStorage as ring buffer max 100 events
// expose via act.show-suggest-stats command (palette G1)
// no PII, no upload, just local diagnostic per Mirko durante review
```

Off by default. Toggle via comando palette. Risolve il carry-over G1.x #6 (telemetry) limitatamente al sotto-dominio ghost text. Privacy: nessuna persistence remota, solo localStorage locale, nessun upload. Mirko legge i dati personalmente da console o da modal dedicata.

---

## 4. Test design

### 4.1 Frontend — vitest target ≥6 nuovi

| # | File | Test | Cosa verifica |
|---|------|------|---------------|
| 1 | `useSuggest.test.ts` | `debounce delays fetch` | digitare 5 caratteri rapidi → 1 sola fetch dopo 300ms |
| 2 | `useSuggest.test.ts` | `query <2 chars no fetch` | "a" → no network |
| 3 | `GhostInput.test.tsx` | `Tab accetta proposta top-1` | mock useSuggest con 3 results, Tab → onAccept chiamato con results[0] |
| 4 | `GhostInput.test.tsx` | `↓↑ cycle alternatives` | ↓ → highlighted index 1; ↓↓ → 2; ↑ → torna a 0 |
| 5 | `GhostInput.test.tsx` | `Esc dismiss + persiste finché query non cambia` | Esc → ghost hidden; stessa query non ricompare; modificare query → reappear |
| 6 | `GhostInput.test.tsx` | `accept callback restituisce result completo` | onAccept signature: process_id, label, confidence, db_source |
| 7 | `GhostInput.test.tsx` | `aria-live announces accept` | accept → assert `screen.getByRole('status')` contiene label + confidence |

### 4.2 Backend — pytest target ≥3 nuovi

| # | File | Test | Cosa verifica |
|---|------|------|---------------|
| 1 | `test_suggest_endpoint.py` | `top_k bounds` | top_k=0 → 422; top_k=11 → 422; top_k=5 → 200 |
| 2 | `test_suggest_endpoint.py` | `q min length` | q="a" → 422; q="ab" → 200 |
| 3 | `test_suggest_endpoint.py` | `context filter applies` | context=process.output filtra correttamente flow types output |

Mock ChromaDB client per i pytest (la fixture matcher M1 lo fa già? Verificare in pre-flight, riusare). Niente test che richiedano l'index reale 23k processi al CI.

### 4.3 Test setup esistente

Riusa `setupTests.ts` di G1 (D-8 cross-sprint). Estensioni eventualmente necessarie (es. mock IntersectionObserver) sono additive, non distruttive.

### 4.4 Criteri qualità test

- Mock TanStack Query con `QueryClient` test mode + `wrapper`.
- Niente test flaky basati su timer reali — tutti i debounce testati con `vi.useFakeTimers()` + `vi.advanceTimersByTime()`.
- Idempotency: ogni test resetta zustand store ghost-text state.
- Assert con `screen.getByRole`/`getByLabelText`, no `getByTestId` se evitabile (testa il contratto utente, non implementazione).

---

## 5. Decisioni autonome

**5.1 Retrieval-only, no LLM in loop**. Il ghost text in G2 è puro lookup vettoriale ChromaDB — niente LLM nel critical path. Motivazioni: (a) latenza <200ms p95 raggiungibile, vs LLM 1-3s; (b) nessun rischio hallucination — il match è sempre un record ecoinvent reale; (c) costo zero runtime; (d) G2 è "AI Grounding versione minimale" come da MASTER_PLAN §12 partial — il LLM-in-loop arriva con V2 Agent Mode.

**5.2 Scope iniziale solo BomTable**. ProcessEditor, Wizard, altre celle del V1 — **rimandate a G2.x**. Il match BoM è il punto di alto valore (Journey A di Kimi, 23/25 mapping in 2 minuti) e bassa complessità (celle text già modificabili). ProcessEditor avrebbe campi più complessi (input multipli, output, allocation, location), e il valore marginale è inferiore. Prima G2 stabile, poi G2.x estende.

**5.3 Debounce 300ms default**. Tradeoff fra latenza percepita e load backend. 200ms troppo aggressivo (fetch ad ogni keystroke), 500ms troppo lento (utente vede ghost dopo aver smesso di digitare). 300ms è il sweet spot citato in più studi UX. Configurabile via prop per stretch.

**5.4 Top-K=5 default**. Mostra solo top-1 inline (ghost text), `↓` rivela popup con altri 4. Più di 5 sarebbero rumore (Hick's law: tempo decisione cresce con #opzioni). Configurabile via query param backend.

**5.5 Confidence threshold visibile sempre**. Niente proposta arriva senza badge "<X%>". Badge color-coded: verde ≥85%, giallo 65-85%, grigio <65%. Sotto 65% il ghost text si renderizza ma con opacità ridotta (suggerisce: "considera alternative"). P5 grounding non-negotiable.

**5.6 Telemetry locale opt-in**. localStorage ring buffer 100 eventi. Toggle palette. Niente upload remoto. Risolve carry-over G1.x #6 limitatamente a G2. V1.5 generale niente analytics infrastructure.

**5.7 BomTable modifica chirurgica**. Sostituzione `<input>` con `<GhostInput>` solo nelle celle name/match. Nessuna modifica a layout, sorting, colonne, eventi onBlur/save esistenti. Il wrapper Ghost\* eredita tutti i props HTMLInput non overridati.

**5.8 Niente integrazione palette comandi obbligatoria**. I 3 comandi palette G2-related (`act.accept-all-high-confidence`, `act.toggle-ghost-text`, `act.show-suggest-stats`) sono nice-to-have. Se Claude Code stima >2 settimane totali con tutti, taglia i 3 comandi e li riporta a G2.x. Il core ghost text inline può vivere senza.

**5.9 Niente i18n labels**. Italiano-only (D-3 cross-sprint).

**5.10 Cache TanStack Query 60s staleTime**. La risposta suggest è quasi-deterministica (ChromaDB index non cambia in sessione). 60s evita refetch spam, mantiene freschezza relativa.

---

## 6. Done criteria

**Funzionalità**:
- [ ] BomTable nel match page ha celle name/match sostituite da `<GhostInput>` senza regressioni di sorting/save/layout
- [ ] Ghost text appare in grigio chiaro quando query ≥2 chars + result ≥1
- [ ] Tab accetta top-1, callback `onAccept` chiamato con SuggestResult completo
- [ ] Esc dismiss + persiste finché query non cambia
- [ ] ↓/↑ cyclano alternative top-K (popup `<ul role="listbox">`)
- [ ] Confidence badge sempre visibile vicino al ghost text (verde/giallo/grigio)
- [ ] Fonte cliccabile/visibile (es. tooltip "ecoinvent 3.9, IT, ID 12345")
- [ ] Comando palette `act.toggle-ghost-text` (`⌘⇧Space`) abilita/disabilita feature globalmente, persistito localStorage
- [ ] Comando palette `act.accept-all-high-confidence` accetta tutti suggest ≥95% nella riga corrente

**Tecnico**:
- [ ] ≥6 vitest pass (target §4.1)
- [ ] ≥3 pytest pass (target §4.2)
- [ ] `npm run test` complessivo verde (no regressione su G1 12 pass)
- [ ] `npm run build` clean
- [ ] Bundle main +<8 KB gzip vs baseline post-G1 (cap stretto: G2 è feature più piccola di G1)
- [ ] Backend `pytest backend/` complessivo verde (no regressione su 366+4)
- [ ] Endpoint `/api/projects/{pid}/suggest` p95 <200ms su index ChromaDB esistente

**Accessibilità**:
- [ ] Input ha `aria-autocomplete="inline"` + `aria-haspopup="listbox"` quando applicable
- [ ] Ghost text è `aria-hidden="true"` (no spam screen reader)
- [ ] Accept event triggera `aria-live="polite"` con label + confidence + fonte
- [ ] Popup alternatives ha `role="listbox"` + `aria-activedescendant`
- [ ] Tutto navigabile da tastiera, no mouse required
- [ ] Test manuale VoiceOver/NVDA documentato nel REPORT con almeno: digitazione → ascolto annunci, Tab → ascolto accept announcement, ↓ → ascolto cycle

**Performance percepita**:
- [ ] Latenza visibile ghost text <500ms da fine digitazione (300ms debounce + <200ms backend)
- [ ] Niente flicker/glitch visivo quando il ghost text cambia
- [ ] Cycling ↓↑ istantaneo (<16ms, già in cache)

---

## 7. Constraints

**G2 NON fa**:
- ❌ Niente LLM nel loop (retrieval-only)
- ❌ Niente ProcessEditor / Wizard / altre celle al di fuori BomTable name/match (G2.x)
- ❌ Niente Agent Mode con plan visibile (V2)
- ❌ Niente real-time collaborative ghost text (V2/V3, irrilevante target attuale)
- ❌ Nessun major version bump
- ❌ Nessuna i18n
- ❌ Nessuna telemetry remota / upload analytics

**G2 PUÒ toccare**:
- ✅ BomTable cell components (chirurgicamente, vedi §3.6)
- ✅ Backend: nuovo endpoint + nuovo wrapper service. Nessun nuovo modello DB, nessuna migration.
- ✅ `package.json`: aggiunta dipendenze additive minori se servono (es. `use-debounce` se non c'è già un hook custom)
- ✅ `lib/commands/definitions/`: aggiunta file `ghost-text.ts` (estende registry G1)

**Vincoli design**:
- ✅ Tailwind only (D-2)
- ✅ Italiano-only (D-3)
- ✅ Bundle cap +8 KB gzip su main (più stretto di G1 perché feature più piccola e isolata)
- ✅ Zero regressione test esistenti (G1 12 vitest + 366+4 pytest)
- ✅ Niente nuovo router, niente nuovo state manager (D-1)
- ✅ Endpoint backend leverages ChromaDB matcher M1 esistente, niente nuovo index

**Vincoli tempo**: 2 settimane developer time. Se Claude Code stima >3 settimane dopo giorno 4, escalation Mirko per scope cut (probabile carry-over: i 3 comandi palette correlati).

**Vincolo coordinamento**: G2 introduce un endpoint nuovo backend. Se in parallelo l'Architect main sta lavorando su backend (es. M3.1.2 CF reali), Claude Code rebases su main quotidianamente per evitare conflitti. Comunicazione cross-chat via Mirko.

---

## 8. Branch & merge

**Branch**: `night/G2-ghost-text-inventory`

**Strategia commit**: micro-commit per layer (1. backend endpoint, 2. backend tests, 3. frontend hook, 4. frontend component, 5. integration BomTable, 6. tests, 7. palette commands), squash su PR finale (ADR 29 MASTER_PLAN: 1 PR squash per sprint singolo).

**PR title**: `[G2] Ghost Text inventory — AI-grounded suggest in BomTable`

**PR description template** (incluso ricapitolato §5 + carry-over + screenshot/gif demo).

**Merge criteria**: Done criteria §6 verde + Mirko approva + CI verde.

**Rollback plan**: feature additive (nuovo endpoint + nuovo modulo frontend + sostituzione chirurgica `<input>` in BomTable). Revert squash commit sufficiente, no migration backend.

---

## 9. Stretch (post Done verde)

**S1 — `<GhostTextarea>` per descrizioni multiline**. Wizard ISO+ILCD ha campi free-text "system boundary description", "geographical scope justification" — eccellenti candidati per ghost text che proponga frasi tipo da progetti simili. Stima 0.5-1 settimana. Fuori scope G2 perché tocca Wizard (G2.x).

**S2 — Highlighting matched chars nel ghost text**. Visualizzare in bold/underline i caratteri della query che matchano nel suggerimento. Es. query "elec" → ghost "**elec**tricity, medium voltage, IT". Stretch perché bello ma non funzionale.

**S3 — Pin favorites**. Permettere all'utente di "pinnare" 3-5 processi usati spesso che appaiono in cima ai suggest indipendentemente dal vector match. Persistito localStorage `lca-tool.suggest.favorites`. Stima 1 giorno.

**S4 — Proxy suggestion** (no match → "use similar X as proxy"). Quando confidence top-1 <50%, ghost text propone "(no match) use similar: <X>" come opzione fallback. Estensione UX, non backend new. Stretch.

**S5 — Backend LRU cache**. In-memory dict {q → results} con max 1k entries, TTL 5min. Riduce p95 latency su query frequenti (utente che ripete lo stesso prefisso su righe BoM consecutive). Stima 0.5 giorni.

**S6 — Telemetry visualization**. Modal dedicato che mostra grafico accept/reject rate, top context, confidence distribution. Solo su `act.show-suggest-stats`. Stretch — un toast con counter testuale è il done minimo.

---

## 10. Note

**Su rapporto con G1 e architettura emergente**. G2 stressa per la prima volta la API `useCommandRegistry` di G1 con comandi che vivono fuori dal bootstrap statico (i 3 comandi G2-related sono comunque registrati al bootstrap, ma S2 Agent Mode in V2 li registrerà dinamicamente al run). Se Claude Code in implementazione trova smell sull'API (es. mancata gestione di un caso edge), documentare nel REPORT come carry-over per refactoring V2 — non patchare in G2 unless trivial.

**Su data flow ghost text → BomTable save**. Quando l'utente accetta un ghost text, l'`onAccept` callback nella BomTable deve scrivere sia il `name` (label leggibile) che il `matched_process_id` (UUID ecoinvent). Questo bypass una doppia compilazione utente: prima scrive il nome, poi separatamente cerca il match. Con ghost text, una sola accept popola entrambi. È il vero valore di prodotto di questo sprint — non solo speed, ma elimination di un passo.

**Su qualità match e calibration**. Il matcher M1 è già stato calibrato (B2 margin-based, ADR 8) per uso batch. **Bug noto** documentato in `_CURRENT_STATE` V1.5 backlog #10 ("Matcher M1 quality ricalibrazione, PRIORITÀ ALTA"): sul project pilota DESSERT 4/6 BoM rows hanno mismatch semantici per BoM specialistico. G2 ghost text **mitiga lateralmente** questo bug: invece di accettare cieco un match batch, il consulente vede confidence color-coded sempre presente — verde ≥85% (probabile OK), giallo 65-85% (review), grigio <65% (sospetto). L'utente è quindi messo in condizione di ignorare attivamente i falsi positivi del matcher M1. Non è una soluzione del bug — è una mitigazione UX del bug noto, in coerenza con P5 (AI Grounding) e human-in-the-loop. Se Claude Code rileva durante implementazione che confidence ≥85% nel matcher M1 batch non si traduce in qualità ≥85% real-time (es. molti falsi positivi visibili nel ghost text), documentare nel REPORT come carry-over **`Matcher M1 threshold ricalibrazione real-time per ghost text`** (V1.5 backlog #10 sub-item, sblocca anche batch).

**Su accessibility e screen reader**. P5 + P6 richiedono ARIA grounding pulito. Pattern Cursor/VS Code è progettato per visione + tastiera, ha gap su screen reader. La nostra implementazione deve fare meglio: il `aria-live` su accept è il minimo, idealmente l'utente non vedente sente "ghost suggestion: X, Y%, fonte Z, premi Tab per accettare" mentre digita — questo è stretch (S7 implicit) perché significa announce live durante la digitazione, che può essere fastidioso. In G2 done minimum: announce su accept. V2: setting esplicito per "verbose ghost mode" SR-friendly.

**Su edge case BomRow esistenti**. La BomTable ha righe già compilate dal matcher M1 batch (post-import xlsx). Quando l'utente edita una riga esistente, il ghost text appare? Sì, normalmente — il behaviour è "se digiti, suggerisco". Se l'utente non vuole essere disturbato, `⌘⇧Space` toggle (`act.toggle-ghost-text`). Default ON. Decisione coerente con P5: AI Grounding sempre presente, ma rispettoso dell'agency utente.

**Su prossimi sprint**. Al merge G2, l'Architect-GUI scrive `SPEC_G3_optimistic_ui.md` (~2 settimane) che si appoggia su TanStack Query mutations già nell'app (esiste pattern in M2.x.\* per BomRow save). Totale V1.5 partial: ~7 settimane se G1+G2+G3 filano lineari. Decisioni di pivot stack V2 (TanStack-router / radix-ui / Tldraw) rimandate a fine V1.5.

**Su carry-over a G2.x**. Aspetti che G2 per scope deve lasciare fuori e che G2.x raccoglierà:
1. ProcessEditor ghost text (campi input/output)
2. Wizard ISO+ILCD ghost text (campi free-text)
3. Stretch S1 GhostTextarea
4. Telemetry visualization avanzata (S6)
5. Eventuale ricalibrazione Matcher M1 threshold real-time

**Su rapporto con M3.x backend**. G2 introduce `/api/projects/{pid}/suggest`. Se l'Architect main lo trova utile per altre feature backend (es. agente di matching automatizzato post-import xlsx), può estenderlo aggiungendo nuovi `context` enum. La signature attuale è progettata stabile e versionable.

---

**Fine SPEC G2 v1.1.**

*Changelog: v1.0 → v1.1: §2 Pre-flight allargato con verifica ambiente dev (venv path, uvicorn :8000, olca-ipc 2.6.2, rclone mount, branch convention) da `_CURRENT_STATE_20260505_0100.md`. §2 numero pytest backend reso esplicito (366 default + 4 preflight skip = 370). §2 no-go condition aggiunto check G1 in main. §10 nota matcher M1 quality espansa: cita esplicitamente bug noto V1.5 backlog #10 (4/6 DESSERT mismatch) e dichiara come ghost text mitiga via grounding visivo, non risolve.*
