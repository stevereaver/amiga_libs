# Work log

- Parsed hunk: 1 CODE hunk 0x8bc bytes + DREL16 (108 offsets, hunk 0).
- RomTag @+0x04 AUTOINIT; InitTable @+0xaa (posSize 0x2c).
- Vectors: Open/Close/Expunge/null + ExName@-30.
- Reverse-engineered ExName: board-ptr or (mfr,prod) args, sorted
  12-byte mfr table, 8-byte product tables, "#%ld" RawDoFmt fallback.
- Wrote `work/gen.py` to emit the table/string region verbatim from
  the original (interleaved strings + product tables, packed strings).
- Hand-wrote the code region.  Byte-level details preserved:
  `moveal 4:w` (not :l), word branches throughout ExName but short
  branches in lifecycle, `cmpl #-1,d0` emitted as raw `0xb0bc`
  (original assembler's CMP.L encoding vs gas CMPI), dead stub at
  +0x10e, orphan "Blizzard 1230-II" string.
- `drel16.py` converts GNU RELOC32 -> DREL16 (descending order,
  MatchWord/EndSkip tail swap) -> byte-identical output.
- md5 5e1d4ddd4bb15aa4f6c8fe7f9c398f9a both files.
- `work/oracle.py` (machine68k): init/datatab/vector install,
  ExName 9 cases (known mfr+prod, unknown prod, unknown mfr,
  board-pointer form), null vector, deferred expunge.
  Original and rebuild produce identical logs.
