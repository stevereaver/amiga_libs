# mathieeedoubbas 31.3 — work log

## Decode

- Hunk parse: 5 entries; CODE 324/660/1172 + empty CODE + empty DATA.
  RomTag at hunk0+0x08 (AUTOINIT, ver 31, NT_LIBRARY, pri 0).
- InitTable at hunk0+0x58: dataSize 0x22, functab->0x98 (14 abs longs),
  datatab->0x70, initfn->0x68 (stores seglist, rts).
- Functab entries 4..13 relocate against hunk1: the public vectors live
  in the second hunk; hunk0 is header+lifecycle only.
- Hunk2 is byte-identical to the FP core in mathieeedoubbas 33.9 (WB1.2)
  — Commodore carried the arithmetic core verbatim between releases.
- Full 68k disassembly transcribed to `source/h0.s`, `h1.s`, `h2.s`.

## Reconstruction issues hit

- ld merges all objects into one hunk: fixed with a generated linker
  script (`hunks.x`) mapping each object to its own output hunk.
- Missing `.globl` exports for the h1 vector stubs referenced by the
  h0 functab.
- GAS relaxed `movel #10/#9/#20` to `moveq` in the mul preamble
  (12 bytes total): forced explicit opcode+`.long`.
- h1 `bges`/`dbcs` label placement: original branches land on the
  `moveq #31` and `lsll` instructions respectively.
- h2 add-path denormal loop: `dbf` target is the `asrl`, while the
  `blts` entry from the shift-count check targets the preceding `subql`.
- h2 div loop is non-restoring; `blts` jumps over the restore block.
- `bras` at the overflow tail targets the pop, not `tstl a0@`.
- `fixup.py` rewrites the hunk table to 5 entries (+ 2 empty trailer
  hunks) and restores the original RELOC32 group order verbatim.

## Verification

- `make` produces a byte-identical file:
  MD5 `02b255ba151f46c732ea7f1a83959047` (both files).
- `work/oracle.py`: builds the library via replicated AUTOINIT
  (datatab+functab+initfn), exercises all 10 vectors on normal,
  negative, subnormal, overflow and div-by-zero inputs, then the
  Open/Close/Expunge deferred-expunge lifecycle. Trace identical
  between original and rebuild.
