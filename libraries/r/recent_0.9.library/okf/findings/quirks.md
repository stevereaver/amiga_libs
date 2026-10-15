# recent.library — quirks & defects

## Defect (original binary)

- **`_save` writes garbage for empty groups.** The per-record write loop
  computes `d5 = used - 1` then enters `L82c: ... dbra d5` with no
  zero check. For a sub-block with `used == 0` the dbra iterates
  0x10000 times, writing 65536 phantom 1B-length/name/payload chunks
  read from uninitialized memory (record name pointers become
  arbitrary values -> wild `dos.Write(h, garbage, n)` reads / possible
  crash). Any group created by `_addblk` and never `_touch`ed hits this.
  Preserved byte-for-byte in the reconstruction.
- **`_savefree` discards the save status.** It returns `_free`'s result
  (0) regardless of whether `_save` succeeded.
- **`_addblk` returns 1 when the key already exists** (dedup early-out
  shares the success path) — callers cannot distinguish "added" from
  "already there".

## Compiler / encoding quirks (preserved verbatim)

- `CMP.L #imm, dn` encoded as the immediate-EA CMP form `b0bc`
  (12 sites), not the `0c80` CMPI form gas emits.
- Explicit mode-5 displacement-0 addressing where gas folds to plain
  `(aN)`: `movel dn,a5@(0)`, `moveal a0@(0),a0`, etc.
- Long-form `movel #imm,dn` for byte-range constants (`#0`, `#0xc`,
  `#-2`, `#-0x14`) where gas canonicalizes to `moveq`.
- `moveal #0,a3` for a null pointer (immediate-to-An long form).
- Reloc block written in `{count, hunk, offsets}` order rather than
  the usual `{count...}`-grouped layout; EndSkip points into the
  InitTable.
- Library-private bases at unusual offsets: dos at lib+0x26,
  gadtools at lib+0x2a.
