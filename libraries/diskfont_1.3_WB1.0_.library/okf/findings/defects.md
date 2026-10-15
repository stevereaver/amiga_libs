---
type: Findings
title: diskfont 1.3 (WB1.0) quirks
---

# Quirks / defects in the original binary

- **lib_IdString never set**: the InitStruct table (h0+0x130)
  has no entry for offset 0x18; ln_Name and version/revision are
  initialized but lib_IdString stays NULL even though the id
  string exists in the resident ('diskfont 1.3 (5 Sep 1985)').
  No 'c000 0018' pair is present.
- **Private counters instead of lib_OpenCnt**: Open/Close/
  Expunge bump a private WORD at lib+0x26 and a font count at
  lib+0x28; the real lib_OpenCnt@+0x20 is never touched.
  AddLibrary callers using lib_OpenCnt see 0.
- **rt_Init returns AddLibrary's return** (d0 passthrough) and
  stores its INCOMING a0 (seglist) at lib+0x22 for Expunge to
  hand back.  moveml a0/a2 saves the caller's registers, so the
  seglist survives only in a0.
- **AvailFonts memory pass skips the list tail**: it walks
  GfxBase->fontResidentList via succ and tests `ln_Succ != 0`
  BEFORE emitting the current node, so the last node in the
  chain is never reported.  With a single-resident-font system
  (topaz 8 only) AFF_MEMORY yields 0 entries; with 2 fonts it
  yields 1.
- **AFF_DISK pass opens every '*.font' file in FONTS:** and
  trusts the first 4 bytes (must be 0x0f00 fileID) then reads
  NumEntries x 260B without bounds-checking the count against
  the buffer.
- **OpenDiskFont relies on graphics.library AddFont(-480)** and
  pokes the font node's internal accessors word (node+0x54) and
  flag bit node+0x4d|=2 directly; it also checks a hard-coded
  magic word 0x0f80 at seg+8+0x16 after LoadSeg (topaz font
  header tf_Style field position).
- **No CloseFont/RemoveFont path on Close**: Close only
  decrements the private count (and self-expunges on DELEXP);
  loaded font nodes are only unloaded by Expunge (accessors<=0).
- **Two empty hunks** (DATA h8, CODE h9) — zero-length table
  slots left in the load image.
- **Stray 0000 pad words** inside the h10 thunk table (0x1a,
  0x4a, 0x66, 0x96, 0xb2) and one at h11+0x36 — assembler
  alignment leftovers between leaf thunks.
- **Reserved vector -24 is a bare rts** (h0+0x21c) returning
  whatever d0 the caller set — non-deterministic result.
- **rt_EndSkip covers only 0x4c** (resident header + strings);
  rt_Init lives inside the same hunk body.
- **COLDSTART boot path**: flags=0x00, so exec runs rt_Init
  directly; no AUTOINIT InitTable. The MakeLibrary initfn
  OldOpenLibrary's dos+graphics each time and on failure frees
  (lib-negsize, neg+pos bytes = 92) and returns 0.
