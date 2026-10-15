---
file: index
---
# notifyintuition.library 3.04 (26.10.97)

5796B single-hunk Amiga library by H.-W. Schober.
Reconstructed byte-identical from `binary/notifyintuition_3.04.library`
(`source/` emits the hunk verbatim as .byte lines; `fixup.py` splices the
original HUNK record tails; `make` ends in `cmp` + BYTE-IDENTICAL).
Runtime oracle `work/oracle.py` (machine68k, stubs exec/dos/intuition/
utility) produces identical logs for original and rebuild
(`work/orig.log` == `work/rebuilt.log`, invalids=0).

## Layout

- `functions/vectors.md`  — vector map, per-entry behaviour, request/
  node structs, external calls, fake screennotify.library vectors.
- `structures/layout.md`  — hunk map, RomTag, strings, InitTable/
  InitStruct, initfn, private data, patch table/trampolines, 3.04
  deltas vs 2.41.
- `findings/defects.md`   — quirks and carried-over defects.
- `log.md`                — reconstruction + verification log.

## Headline facts

- v3 rev 3, RTF_AUTOINIT RomTag @h0+0x04, InitTable @h0+0xf0
  (dataSize 0x9c), abs-long functab @h0+0x124, 7 entries.
- One CODE hunk, 0x58b longs; RELOC32 tail: 17 slots ->h0.
- Registers an embedded fake `screennotify.library` (base h0+0x180,
  vectors h0+0x144) into exec's LibList at init — the 3.04 addition.
- Expunge (-18) and reserved (-24) are the same `moveq #0,rts`
  stub: the library can never be expunged (no DELEXP logic left).
- Public API -30/-36/-42 (StartNotify/EndNotify/FindUniqueTask)
  keeps the 2.41 protocol and error matrix, now AllocVec-based.
