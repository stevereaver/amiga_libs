# Vectors — memorymanage.library 1.01

Absolute-pointer functab (DC.L form), 11 vectors + `ffff ffff`.

| LVO | Name          | Args                                   | Notes |
|-----|---------------|----------------------------------------|-------|
| -6  | LibOpen       | a6=base                                | clears LIBF_DELEXP, ++OpenCnt; on wrap returns -1 (jumps _start stub) |
| -12 | LibClose      | a6=base                                | --OpenCnt; delayed-expunge at 0 via flags bit3 |
| -18 | LibExpunge    | a6=base                                | sets DELEXP; Remove+FreeMem(negsize+possize) |
| -24 | LibNull       | a6=base                                | moveq #0,rts -> returns 0 |
| -30 | MMUAttach     | a6=base                                | readregs; reject active TTRs; refcount++; adopt live SRP or build tables; map 16MB + FAST extents; patch profiles; WriteRegs(prof_att); returns base+38 (root node or adopted SRP) |
| -36 | MMUDetach     | a6=base                                | refcount--; last one: WriteRegs(prof_det) unless adopted, un-patch freelist slots, FreeVec allocs, clr +38/+42 |
| -42 | MMUMap        | a0=vaddr, a1=phys, d0=len, d1=flags    | 3-level walk/alloc; emits 4KB descs; returns entry-d0 (len) — leaf ptr in a2 is movm'd away (quirk) |
| -48 | MMUMapIdentity| a0=addr, d0=len                        | wraps MMUMap(vaddr=phys, flags=0) |
| -54 | MMUReadRegs   | a0=blk                                 | Forbid/Supervisor/Permit; fills 30-byte block |
| -60 | MMUWriteRegs  | a0=blk                                 | installs URP/SRP/DTT0/DTT1/ITT0/ITT1/TC + PFLUSHA |
| -66 | MMUTranslate  | a0=vaddr, a6=base                      | dfc=1, ptestw (a0), mmusr; returns phys&~0xfff + vaddr&0xfff; returns garbage d0 if no root |

## Register-block layout (a0 for Read/WriteRegs)

```
+0  URP   +4  SRP   +8  DTT0   +12 DTT1
+16 ITT0  +20 ITT1  +24 TC.w   +26 MMUSR (long store -> 4 bytes, +28/29 spill)
```

## Page descriptor low bits (built by MMUMap from flags/d1)

```
bit6 = flags.bit1    (flags<<5 & 0x40)
bit5 = flags.bit1    (flags<<4 & 0x20)
bit2 = flags.bit2    (flags & 4)
bit0 = !flags.bit0   (~flags & 1)
desc = (phys & ~0xfff) | above
```

Root/mid child pointers are `tableaddr | 2` (bit1 = indirect).
