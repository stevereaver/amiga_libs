---
file: defects
---
# Findings

- DATA hunk table entry (9 longs) exceeds file body (1 long) —
  reserved-unfiled-space linker quirk, replicated verbatim.
- h0 embeds a longword table of every Amiga hunk tag constant
  (0x3e9..0x3fa, 0x800003xx forms) near +0x898 — the library
  carries its own hunk-type table for the embedded loader path.
- -24 and -30 alias the same reserved stub.
- Identical vector offsets to wbstart_2.2 (same codegen
  skeleton; only version/idstring and minor data differ).
