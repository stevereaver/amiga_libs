# Rebuild delta

- Byte-identical rebuild achieved (verbatim h0.s + fixup.py RELOC32
  rewrite verified by cmp).
- C model: IDN_Normalize and IDN_Free are exact ports; the punycode
  encode/decode vector cores are documented structurally (full C port
  is future work - the asm model IS the byte-exact build).
- IDN_Normalize shipped code does not append a NUL terminator;
  callers clear/shorten dst themselves.  The C model terminates.
- Function naming is reconstructed (no fd shipped).
