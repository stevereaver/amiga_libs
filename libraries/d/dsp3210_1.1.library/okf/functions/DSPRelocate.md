---
type: Function
title: DSPRelocate
description: Loads a d32 blob to a target address and applies relocations.
lvo: -36
timestamp: 2026-10-10T20:10:00Z
---

# Signature

```c
LONG DSPRelocate(UBYTE *blob, UBYTE *target,
                 const struct DspExtSym *extsyms, ULONG bound);
/*               a0            a1
                                a2                        d0        */
```

Matches `DSPRelocate(blob,targetmem,globsymhdr)(A0/A1/A2)` in the FD —
except this build's third argument is a plain `{name,value}` pair
array, not the later `DSP3210GlobSymHeader` (see
[ApiDrift](../findings/ApiDrift.md)), plus the undocumented d0 bound.

# Semantics

1. Same header validation as [DSPCalcLen](DSPCalcLen.md) → -1.
2. `AllocMem(nsec*4, MEMF_PUBLIC|MEMF_CLEAR)` pointer table → -3.
3. Pass 1: for each section record, store the running load address,
   byte-copy `size` bytes from `blob+dataOff`, advance by `align4(size)`.
4. Pass 2: for each section's reloc records (16 bytes each:
   `{u32 patchOff, u32 symIdx, u16 type, pad}`):
   - resolve the symbol: internal → `value - linkedBase + loadAddr`
     of its 1-based defining section; external (sect 0) → look the
     name up in `extsyms` (inline name at +0 if its first byte is
     nonzero, else strtab + u16 index at +6); negative sect → -20;
     unresolved → -21.
   - apply by type: `0x2c` write u32; `0x2e` write low u16 at +2;
     `0x2f` write high u16 at +2; `0x1c` write low u16 at +2 then
     fail -30 if the value overflows 16 bits; else -10.
5. `FreeMem` the pointer table on every path; return 0 or the error.

Errors: -1, -3, -10, -20, -21, -30 — see
[ErrorCodes](../findings/ErrorCodes.md).
