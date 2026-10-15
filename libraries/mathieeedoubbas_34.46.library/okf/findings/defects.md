---
file: defects
---
# Findings

- Resident flags 0x01 (not 0x80): this era marks
  RTF_AUTOINIT differently than later Kickstart builds —
  init is still COLDSTART code doing MakeLibrary itself.
- h0 declared size undershoots body by 4B
  (`f0b0ffff` before RELOC32) — linker slop, preserved.
- Two trailing 0-size hunks (CODE + DATA tags) — pure
  linker artifacts, no bodies.
- Functab select: AttnFlags bit4 (68881) takes the FPU
  table unconditionally; MathIEEE.resource presence picks
  the resource-assisted table on non-FPU systems.
