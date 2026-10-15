# Findings & defects

- Whole-hunk InitTable (h1) and CODE-typed functab/string hunk
  (h3) — unusual cross-hunk layout.
- initfn ->h0+0x20 = `moveq #0,d0; rts` stub (dummy init).
- Close underflows open count (65534); expunge returns 0.
- ~7 deterministic invalid reads at functab edge.
