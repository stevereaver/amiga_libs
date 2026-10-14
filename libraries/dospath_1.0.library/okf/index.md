# dospath.library 1.0 — OKF index

`dospath.library` 1.0 (25.8.96) — a compiled-C DOS path/lock-list utility
library. Public API builds and prunes BPTR-linked `{flag,lock}` node chains
from name arrays, lock arrays, taglists and the Workbench process's
device/volume list.

- binary: `binary/dospath_1.0.library` (2664 bytes, 2 hunks)
- source: `source/dospath.s` — pure 68k asm (gas)
- build: `cd source && make` → byte-identical (md5 `1ab7034ab9664be68b89b245289d29a1`)
- oracle: `work/oracle.py` (machine68k, fake exec+dos+utility) — lifecycle
  (COLDSTART rt_Init, clone-per-open, close, expunge) plus all 7 real API
  vectors; orig vs rebuild trace identical

## Layout

- hunk0 CODE 0x268 longs (2464B): dead ret0 stub, `dospath.library` name,
  `$VER` idstr, RomTag (COLDSTART, flags=0, ver 1), rt_Init→0x10a,
  absolute-long functab (13 vectors), MakeLibrary/FreeMem helpers,
  Open/Close/Expunge, path-list builders, embedded strings, tail stub row
- hunk1 DATA: header table says 3 longs (12B alloc) but record body holds
  1 long only; globals `{libbase, seglist, sysbase}` reached via
  `a4 = h1+0x7ffe` wrap-around addressing (`a4@(-32758)` = h1+8 etc.).

## Quirks

- rt_EndSkip points at the functab (h0+0x54), not past the resident tail.
- `_init` ignores exec version < 37 silently (returns 0).
- Expunge checks `opencnt < 0` (signed) to expunge immediately; opencnt==0
  defers via DELEXP — the count is maintained on the master library while
  clones carry their own +32 word.
- `subl #imm,d0` was emitted by the original assembler as generic SUB.L
  (`90bc`) rather than SUBI (`0480`); source uses a raw `.short`.

See `functions/vectors.md`, `structures/layout.md`, `findings/quirks.md`,
`log.md`.
