---
file: defects
---
# Findings

- Word-offset functab with ffff marker — same MakeLibrary
  format as the 1.1/3.0 siblings.
- Only 5 relocs (resident fields); all other internal refs are
  pc-relative — the DSP firmware blobs ride inside code hunk.
- initfn sets lib_Version=4 while resident ver is also 4 —
  idstr 'dsp3210.library 4.0'.
