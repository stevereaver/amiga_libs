# Entry stub doubles as all four dead vectors

The hunk-0 entry stub is `moveq #0,d0 / rts` — already a perfect
"return 0" vector.  The functab exploits this twice:

- The dead slots (-24 reserved, -42 PackFree, -48 PackReset,
  -60 UnpackFree) store offset `-0x98` relative to the table at
  hunk+0x98, i.e. absolute target hunk+0x00 — the only negative
  offsets in the table.
- LibClose's early-outs use *word* branches (`bne.w`/`beq.w`) and the
  deferred-Expunge path uses `bra.w`, all three targeting the same
  stub — the only 16-bit branches in the library (a short branch
  would have reached too, so these are just unoptimised leftovers
  of the original assembler's branch sizing).

1.4 instead had a separate `moveq #0,rts` at hunk+0x12e after the
deferred-expunge `bset` (its entry stub returns -1, unsuitable as a
null vector).
