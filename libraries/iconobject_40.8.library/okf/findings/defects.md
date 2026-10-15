---
type: Findings
title: iconobject.library 40.8 quirks
---

# Findings / quirks

- SAS/C a4-data build: Resident embedded at DATA+0x16c; exec
  finds it via the all-hunks InitResident scan.  There is no
  stub or resident in the code hunk at all.
- datatab is NULL — InitStruct not used; all lib fields written
  by initfn.
- initfn self-frees (exec Remove + FreeMem on the lib base) when
  the msg-port setup fails, then returns 0 — observed under
  stubbed exec; identical in rebuild.
- 69-entry descending h0->h1 reloc group — code operands into
  the DATA strings/globals.
