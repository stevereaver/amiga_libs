---
file: defects
---
# Findings

- InitTable functab pointer stored as literal 0 and relocated ->h1
  (reloc lands mid-InitTable @h0+0x27a).
- initfn's exec -444/-558 calls wire a private msgport inside the
  lib data — nonstandard but deterministic.
- One vector (-48) returns -1 unconditionally in this build
  (unimplemented slot).
