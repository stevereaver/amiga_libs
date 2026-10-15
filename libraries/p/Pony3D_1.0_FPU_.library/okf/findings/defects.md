---
type: Findings
title: Pony3D 1.0 quirks
---

# Findings / quirks

- idstring ' Pony3D.library 1.0 (13-Feb-2000).' leads with a
  space; separate '$VER:' string lives in hunk2.
- initfn returns 0 despite successful init (return-value quirk —
  AUTOINIT uses the MakeLibrary-allocated base, so harmless).
- Functab spans hunks: -30..-48 relocate into hunk1.
- 'OKAY' string in data hunk (dialog/reqtools convention).
