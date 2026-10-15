---
file: defects
---
# Findings

- PACKED Resident: matchtag/endskip/name/id/init fields are at
  byte offsets +2/+6/+0x12/+0x16/+0x1a — the assembler didn't pad
  after the MatchWord. Reloc slots land at these packed offsets.
- InitTable in a DATA hunk (h2) whose functab/datatab/initfn
  fields are stored as literal 0 and relocated into h3/h1 — clean
  but unusual; a naive file read suggests an all-null table.
- idstr is literally 'Version 1.0' (no lib name/date).
- functab mixes code hunks: h1 (lifestyle fns), h4, h5, plus a
  ->h0+0 dead entry (the moveq/rts stub).
