---
type: Finding
title: "040" build is byte-identical 68881 code
description: Only the idstring and init gate differ from the FPU sibling.
timestamp: 2026-10-10T23:10:00Z
---

# "040" build is byte-identical 68881 code

The shipped `mathieeedoubbas_40.6(040).library` executes the
same 68881 instruction stream as `mathieeedoubbas_40.6(FPU).
library` — including `fintrzd` and `fintx`, which the 68040
does **not** implement and must trap into 68040FPSP (bundled
with exec on OS3.x, hence the added `AFF_FPU40` requirement
under `lib_Version >= 39`).

The init gate:

```asm
btst   #3,AttnFlags.byte(a6)   ; AFF_68040 required
beq    fail
cmpi.w #$0027,lib_Version(a6)  ; exec >= 39?
bcs    ok                      ; older exec -> pass
btst   #6,AttnFlags.byte(a6)   ; AFF_FPU40
bne    ok
fail:  moveq #0,d0
```

Everything else — framework, private DELEXP byte, the twelve
vector bodies — is identical to the FPU build (see its
[OKF](../../mathieeedoubbas_40.6_FPU_.library/okf/index.md)).
