---
file: defects
---
# Findings

- Packed Resident again (no pad after MatchWord).
- rt_Version=37 but idstr says 'Version 1.0' — version/revision
  fields not synced with the marketing string.
- InitTable lives in DATA hunk1; functab/initfn fields stored as
  literal 0 and relocated ->h2/->h0.
- One functab slot is a dead ->h0+0 (moveq/rts stub) entry.
- Vectors use exec PutMsg for CD command packets + AllocMem for
  per-command state; expunge frees 0x104-sized lib + RemLibrary.
