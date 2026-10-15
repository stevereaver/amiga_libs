---
type: Finding
title: iff.library 22.3 findings
tags: [quirks]
timestamp: 2026-10-15T03:53:46Z
---
# iff.library 22.3 findings

- **Sign-on banner module entry** (same quirk as 23.2): opens
  dos.library, Output(), Write()s the 46-byte idstring,
  CloseLibrary, returns 5.
- **Vestigial DATA hunk**: a second 4-byte all-zero DATA hunk is
  shipped; nothing references it.
- **Reserved vectors share stubs**: -102/-108/-114 point at the
  -24 rts stub; -120 is a separate bare rts.
- Same private datatab opcode family as 23.2 (0xa0 2-byte /
  0x90 word / 0x80 relocated-long).
