---
type: Finding
title: iff.library 22.1 findings
tags: [quirks]
timestamp: 2026-10-15T00:00:00Z
---
# iff.library 22.1 findings

- **Sign-on banner module entry**: opens dos.library, Output(),
  Write()s the first 42 bytes of the idstring ("IFF 22.1
  (02.06.92) by Christian A. Weber\n"), CloseLibrary, returns 5.
- **Vestigial DATA hunk**: a second 4-byte all-zero DATA hunk is
  shipped; nothing references it.
- **Reserved vectors share stubs**: -102/-108/-114 point at the
  -24 rts stub; -120 is a separate bare rts.
- Same private datatab opcode family as 22.3/23.2 (0xa0 2-byte /
  0x90 word / 0x80 relocated-long).
- **22.1 vs 22.3 delta** (+12 bytes of hunk): in OpenIFF's
  post-xpkmaster path, 22.1 inserts `Seek(d4, 0, OFFSET_END)`
  (dos -66) before the FORM re-check — a file-size probe that
  22.3 removed; the only other differences are the version/date
  string, a dropped 2-byte alignment pad before the CloseIFF
  area, and shifted functab offsets.
