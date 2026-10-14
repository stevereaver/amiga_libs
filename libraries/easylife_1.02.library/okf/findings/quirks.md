# easylife.library 1.02 — quirks & defects

- **Dead InitStruct entry**: datatab writes INITBYTE 9 @ lib+0x0c, then
  INITLONG name-ptr @ +0x0a overwrites it — net effect leaves ln_Type
  (+8) = 0 forever. Oracle shows `type=0` on the open library.
- **Uninitialized allocator hook**: lib+42 is never written by the
  datatab; if lib+240==0, -36 (and every API path through _f236) does
  `jsr a2@` on a2=0 unless the application installed a hook. A
  hardcoded crash-on-first-use unless apps always set +42 before use.
- **a5 context ABI**: -90/-96/-102 file vectors require caller's a5 to
  point at a block with dos.library base at +696 — outside the
  library's own data (dsize only 0xfc). Calling them via normal
  exec/LVO convention reads arbitrary memory.
- **Inverted-looking bound check** in _f364: `cmpl d3,d2; bcs fail`
  rejects index<bound pairs (d2 must be >= bound) — semantics preserved
  verbatim.
- **Inverted compare loop** in -66: returns -1 when element bytes differ
  ascending, +1 descending — arg order (a0 vs a1 d4) matters.
- **movew #4,%ccr error exits**: fail paths set Z via ccr constant
  rather than tst; byte-identical to compiler output.
- IdString ends with `\r\n` (unusual: keeps newline inside version str).
- Revision in datatab = 2 while idstring claims "1.02".
