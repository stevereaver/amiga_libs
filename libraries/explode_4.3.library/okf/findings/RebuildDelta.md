# Rebuild delta

- Codegen: rebuilt .text 0xe54 vs shipped 0x55c.  GCC -O2 is far more
  verbose than the hand-tuned 1989 assembler core; all table bytes,
  the RomTag, strings and InitStruct match byte-for-byte.
- The decoder logic is a semantic port (same tables, bit order, record
  protocol, ring wrap).  Not binary-identical; no packed test corpus
  exists to verify output equivalence - flagged as the main risk.
- Resume-path enters the match copy with the wrap check included;
  the original skips it once (a5 already mid-ring) - harmless.
- Payload-record semantics documented as literal (see PayloadWrite).
