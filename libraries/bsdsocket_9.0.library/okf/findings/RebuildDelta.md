# Rebuild delta

- Semantic port, not byte-identical.  C model reproduces the
  marshal/dispatch skeleton and the decoded opcodes; exact per-call
  arg packing beyond socket/bind/listen is stub-shaped (marked).
- RomTag rt_Name/rt_IdString stored offsets are small - the shipped
  binary's name/idstring pointers are relocated into the data hunk;
  reproduced with direct symbol refs.
