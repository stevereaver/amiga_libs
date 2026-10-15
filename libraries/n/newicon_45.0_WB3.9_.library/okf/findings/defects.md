---
type: Findings
title: newicon 45.0 quirks
---

# Findings / quirks

- Initfn frees a private 0xa2-byte block at init time.
- Emulation build: idstring says 'emulation', h0 carries the
  'NewIconEmu' tooltype template; h1 tail carries the
  '*** DON'T EDIT THE FOLLOWING LINES!! ***' + IM1=/IM2=
  marker strings NewIcons uses to patch icon files.
- Uses DREL16 relocations rather than the usual RELOC32.
