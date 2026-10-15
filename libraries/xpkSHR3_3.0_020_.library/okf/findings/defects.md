---
file: defects
---
# Findings

- Declared hunk0 size 0x3fe longs undershoots the physical
  body by 2 bytes (body runs to 0x1016, pad before RELOC32)
  — preserved verbatim.
- initfn stores its seglist at lib+0x22 — nonstandard slot
  (seglist normally at lib-4 of the *loaded* segment, but
  this sublib keeps it inside the library structure for
  xpkmaster's Remove path).
- initfn tests AttnFlags bit 1 (SYSB+0x129): 020+ gate,
  since this is the 020 build; stubs on plain 68000.
- Reserved vectors -24/-60 are a shared moveq#0/rts stub.
