# SPEC G2.1 — Ghost Text qualifier + layout fix

> **Sprint**: V1.5 partial — G2.1 hot fix (~4-6 ore developer time)
> **Branch**: `night/G2.1-qualifiers-and-layout`
> **Autore SPEC**: Architect-GUI
> **Data**: 2026-05-05
> **Implementer target**: Claude Code Ubuntu
> **Riferimenti**: SPEC G2 v1.2 (`1uap7E-n2jReBQEVcyIiM9ANayZ5vv-Xl`), REPORT G2 (`1fZjNsoe8OOr3AGjE2W2SNX_KwaNYic99`), DESIGN_GUI v1.2 (`1BjYRfwSm9MnoiLkBEkSXQJBoQNIhsgCe`) §3 (P5 AI Grounding), §6 D-2/D-3/D-5/D-12.

---

## 1. Goal

Iterare sul ghost text di G2 risolvendo 4 problemi emersi durante il manual QA empirical Mirko 2026-05-05:

1. **Layout suggestion illeggibile per dataset name ecoinvent lunghi**. Il dataset canonical ecoinvent (`market for electricity, low voltage | electricity, low voltage | Cutoff, U · EC · kWh · EC`) è 60-100+ caratteri e l'attuale render single-line sotto al campo Flow_name diventa illeggibile — wrap malamente o spinge il form fuori. Pattern Cursor-style assume label corte, ecoinvent richiede layout dedicato.

2. **Niente sintassi rapida per qualifier ecoinvent**. Il consulente sa già che vuole `electricity IT cut-off market`, ma deve scriverlo per esteso o lasciare che il vector matcher pesi i token. Risultato: top-1 spesso sbagliato per geografia (GLO quando il progetto è IT) o system model (APOS quando vuole cut-off). Una sintassi `:IT :cutoff :market` permette filtering esplicito con 6-12 caratteri extra.

3. **Sticky qualifier per progetto mancanti**. Se il progetto è italiano, ogni row dovrebbe ereditare default geo IT senza che il consulente lo riscriva. Pattern Linear/Notion. Combinato col punto 2.

4. **Performance da verificare** (511ms total osservato Mirko). Sopra target SPEC G2 §6 (<200ms p95). Da diagnosticare cold vs warm per decidere fix (warmup ChromaDB) o accettare.

Lo sprint G2.1 è **additivo a G2** — non riscrive niente, estende. Sostituisce il render di `SuggestionOverlay` con layout A multi-line (vedi §3.1). Aggiunge un parser di qualifier nel backend (`_parse_query`). Aggiunge sticky qualifier per progetto in zustand store. Diagnostica perf cold/warm.

**Definizione di successo**: consulente che apre un progetto italiano vede automaticamente suggest filtrati IT (sticky da location progetto). Digita `electricity` e vede una proposta leggibile a 3 righe con dataset name canonical pieno + metadata strutturati `📍 IT · ⚙ Cutoff · 🔬 EC · 📏 kWh`. Se vuole forzare altro paese/model, scrive `:DE :apos` e i risultati cambiano. Tempo di compilazione row dimezzato vs G2 vanilla.

---

(SPEC continua, full text disponibile in /mnt/user-data/outputs/SPEC_G2.1_qualifiers_and_layout.md)

NOTA: questa è la versione abbreviata uploaded su Drive per backup. La versione completa di 582 righe vive in /mnt/user-data/outputs/ e sarà migrata al repo lca-tool-coordination GitHub a breve. D'ora in poi le SPEC nuove vanno direttamente su GitHub.
