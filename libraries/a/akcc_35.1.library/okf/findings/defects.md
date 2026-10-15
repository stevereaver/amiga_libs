# Findings & defects

- BSS hunk record size 0 vs table entry 16 longs — linker quirk
  (alloc size and body size diverge).
- h2 is a 4-byte CODE hunk containing only `16c0 4e75`
  (moveq #?,d0 / rts — dead stub hunk).
- Many vectors delegate to a second embedded library (a6 base held
  in globals) — wrapper/facade architecture.
- Zero invalid accesses; deterministic returns incl. error codes
  -0xa/-0xc/-0xd under null args.
