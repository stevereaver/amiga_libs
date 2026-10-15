---
file: defects
---
# Findings

- WB3.9's mathieeedoubbas is still COLDSTART (flags 0x01) — the
  resident init pointer is CODE, not an InitTable. It performs
  MakeLibrary/AddLibrary manually, same pattern as the 1988
  mathieeesingbas 36.11.
- Three word-offset functabs selected by fpsp.resource presence +
  AttnFlags bit4 (040-FPU style gate) — the tables swap in fpsp
  trampolines vs direct FPU code.
- Seglist stashed at absolute $17e (low-mem slot) for deferred
  expunge; expunge returns it verbatim.
- functab word offsets include negative entries (vectors before the
  table base).
