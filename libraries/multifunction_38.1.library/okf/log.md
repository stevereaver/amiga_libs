# Log

- Parsed single-hunk AUTOINIT + extended 26B resident; decoded
  InitTable @h0+0x7c and 31-vector absolute-longword functab @h0+0x8c.
- Verbatim .byte emission of the hunk body + fixup splicing the
  original RELOC32/END tail.
- Build: BYTE-IDENTICAL (5432B).
- Oracle: generic loader + initstruct + full 31-vector probe.
  RUNTIME-IDENTICAL, incl. ~1.34e9 deterministic invalid accesses.
- Oracle upgraded post-commit with full dep stubs
  (commodities/intuition/graphics/misc.resource); re-verified
  RUNTIME-IDENTICAL with the richer trace (39.8M invalids).
