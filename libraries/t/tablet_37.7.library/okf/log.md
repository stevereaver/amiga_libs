---
type: Log
title: tablet 37.7 work log
---

- 2-hunk build; Resident@h0+4; InitTable inside the DATA hunk at
  h1+4 (rt_Init relocated h0->h1, slot value 4).  Leading h1+0
  longword is unused zero.
- RELOC32 tails only: h0 has two groups (14 slots ->h0, 2 slots
  ->h1), h1 one group (2 slots ->h0).  No DREL16, no BSS.
- rt_Version byte is 0x21 (33) although the library reports 37.7 —
  initfn writes lib_Version=37/lib_Revision=7 itself since
  InitTable.datatab is NULL (no InitData at all).
- functab is absolute-long with a genuine 0 hole at slot 3
  (reserved -24 vector); exec keeps the default vector there.
- initfn does a manual data-hunk copy (0xc4 bytes h1->lib+0x2e)
  plus a 1-entry self-fixup table at h1+0xc4/0xc8 — strings thus
  live inside the library node, not the (unprotected) data hunk.
- Installer h0+0x964 opens intuition v37, registers a public
  'TabletPatch' port (pri -128), opens input.device and issues
  DoIO io_Command 10 then 9 (payloads at ioreq+40: intuition
  patch target +0x704/+0x76e, and a 22B Interrupt 'is' node whose
  ln_Name points at the second 'intuition.library' string,
  is_Code = h0+0xc8c v39 / h0+0xc54 v37).  Uninstall re-opens
  input.device and replays the same commands with payloads
  swapped.
- gen_source: DATA ranges {h0+4..0x20 resident+pad, h0+0xca2..
  0xcf8 functab+strings+pad byte}; entry labels added for all
  vectors/helpers.  Byte-identical first pass.
- Oracle identical original vs rebuild under utility v39 (fast
  CopyMem getdata path) and v36 (semaphored path) with intuition
  v37 (patch path); exec list/sem/msgport/tag calls trapped and
  logged; expunge exercises the uninstall branch incl. RemPort of
  'TabletPatch'.
