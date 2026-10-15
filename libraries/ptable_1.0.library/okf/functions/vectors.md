---
file: vectors
---
# Vectors

Word-offset functab (leading `0xffff` marker); offsets relative to
functab base at hunk0+0x6c.

| LVO | target | role |
|-----|--------|------|
| -6  | h0+0x90 | Open — bumps lib_OpenCnt, returns lib base |
| -12 | h0+0x9e | Close — decrements count, returns 0 |
| -18 | h0+0xb2 | Expunge — exec.Remove/FreeMem path, returns seglist |
| -24 | h0+0xf0 | Reserved — returns 0 |
| -30 | h0+0x1ea | RDB scan: AllocMem work buffers, opens `expansion.library`, walks `FileSystem.resource`/device list, probes RDSK/FSHD/PART/LSEG blocks, emits `[RDB] ...` progress via dos |
