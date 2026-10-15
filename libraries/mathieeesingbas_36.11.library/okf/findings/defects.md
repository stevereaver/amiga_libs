---
file: defects
---
# Findings

- NON-AUTOINIT resident (flags 0x01) — rt_Init is code, not an
  InitTable. Module bootstrap does MakeLibrary+AddLibrary itself.
- Three alternative word-offset functabs selected by AttnFlags
  68881 bit + presence of MathIEEE.resource — FPU-aware dispatch
  built into the resident init.
- init stores the seglist longword at absolute $1f2 (low-memory
  convention for deferred expunge on 1988 ROM modules).
- Expunge observed returning 0x80000000 — the deferred-expunge path
  returns a stale register value rather than the seglist under some
  states; preserved verbatim.
- Two zero-length hunks (h1 CODE, h2 DATA) — linker artifacts
  preserved in the rebuilt file.
