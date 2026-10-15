# tdisk.library 4.1 — quirks and oddities

- **Alert fall-through into Open**: if `OpenResource("disk.resource")`
  fails, init pushes d7/a5-a6, issues `Alert(0x80058021)`, pops, and
  **falls through directly into Open** — there is no `rts` between the
  init-failure tail and Open's entry.  The net effect is that a failed
  init returns the (useless) library base with opencnt incremented.
  Preserved verbatim in the reconstruction.

- **InitStruct called with d0=0**: the per-unit `InitStruct` call passes
  size 0.  InitStruct ignores the size argument (it walks the table to
  the zero terminator), so this is harmless but unusual.

- **GetUnitID ordering**: units are probed with d2 counting *down* 3..0
  via `dbf`, so higher unit numbers get first pick of free drive ids.

- **Select on an uninitialised unit**: Select dereferences a0=unit
  unconditionally; calling it with a NULL unit pointer (as happens when
  GetUnitID returned -1 for that slot) reads through address 0 — the
  original makes no attempt to guard.  Verified in oracle: identical
  garbage on both builds.

- **No DSKRDY timeout on write**: the write path polls
  `DSKBYT bit1` with a `beq` loop and no escape counter — a hung drive
  wedges the library.

- **Byte-exact reconstruction notes**: the original assembler emitted
  `move.l #imm` (6-byte) where gas would shrink to `moveq`, and explicit
  `An@(0)` displacement addressing where gas emits plain `(An)`.  All
  such sites are forced with raw `.short`/`.long` directives in
  `source/tdisk_lib.s` (marked with comments).  RELOC32 offset groups
  are emitted descending by the original linker and ascending by GNU
  ld — `source/reorder_relocs.py` post-processes.
