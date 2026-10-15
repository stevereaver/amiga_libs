---
type: Finding
title: Unrelocated Interrupt ln_Name
---

# Interrupt ln_Name = literal 973 (0x3cd)

GRArm installs the input-handler Interrupt with
`movel #973, a0@(10)` -- is_Node.ln_Name = 0x3cd.  The binary's
RELOC32 table has **no** entry covering that immediate (relocs
exist for every other pointer-sized field, including is_Code),
so the value is a literal small integer, not a pointer.

0x3cd lands mid-string inside "Setup GhostRider Launcher" (at
hunk+0x3c7 +6 = " GhostRider Launcher") -- consistent with the
author intending the node name to point near that string but
the assembler/linker emitting an unrelocated immediate.

Harmless in practice (input.device never dereferences ln_Name),
but a genuine shipped defect.  The reconstruction reproduces it
verbatim (`is_Node.ln_Name = (char *)973`); a corrected build
would use the intended string address.
