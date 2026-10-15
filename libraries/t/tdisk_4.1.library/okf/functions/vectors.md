# tdisk.library 4.1 — vector table

Functab at code+0xa8, 11 absolute longs + -1 terminator.  a6 = library
base on all entries (standard Amiga library ABI).

| LVO  | code+  | name        | args / behaviour |
|------|--------|-------------|------------------|
|  -6  | 0x29e  | Open        | `addq.w #1,lib+32; bclr #3,lib+14; return a6` |
| -12  | 0x2ac  | Close       | `subq.w #1,lib+32`; if 0 and flag bit3 set -> Expunge, else d0=0 |
| -18  | 0x2c2  | Expunge     | if opencnt: `bset #3,lib+14; d0=0`.  Else free each unit buf+struct, `Remove`, `FreeMem(lib, negsize+possize)`, return seglist (lib+34) |
| -24  | 0x336  | Reserved    | `moveq #0,d0; rts` |
| -30  | 0x33a  | InitUnit    | a0=unit: FindTask(NULL) -> unit+0x18?; `GetUnit(unit)` on diskres a6=lib+42; Wait/GetMsg reply loop; returns d0 status |
| -36  | 0x3b0  | UnitCleanup | a0=unit: `GiveUnit(unit)` via diskres base + store |
| -42  | 0x3cc  | Select      | a0=unit, d0=0 deselect / 1 select; CIA-A prb ($bfd100) drive-select bits, polls /RDY on CIAA pra ($bfe001 bit5); returns status |
| -48  | 0x43a  | Seek        | a0=unit, d0=track*2+side; steps via CIAB STEP/DIR, HEADS via SIDE bit; error path branches to pop+rts returning -1 |
| -54  | 0x4e0  | MFMRead     | a0=unit, a1=dest, d0=sel, d1=len; raw track DMA into 16 KiB buffer, decodes MFM sectors |
| -60  | 0x792  | MFMWrite    | a0=unit, a1=src; MFM encode + write; precomp thresholds at unit+5/6/7 select ADKCON precomp value; bounces via trkbuf when src < $80000 |
| -66  | 0x92c  | Verify      | wraps MFMRead then compares dest vs unit trackbuf (`a2`), 3261 longs |

## Exec LVOs used

| LVO  | call         | where |
|------|--------------|-------|
| -498 | OpenResource | init ("disk.resource") |
| -198 | AllocMem     | init (unit 32B + trkbuf 16KiB each) |
| -78  | InitStruct   | init (unit templates) — called with d0=0! |
| -210 | FreeMem      | init fail-path, expunge |
| -108 | Alert        | OpenResource failure — then FALLS THROUGH into Open (see quirks) |
| -294 | FindTask     | InitUnit |
| -318 | Wait         | InitUnit |
| -372 | GetMsg       | InitUnit |
| -252 | Remove       | Expunge |

## disk.resource LVOs used (a6 = resource base @ lib+42)

| LVO  | call       | where |
|------|------------|-------|
| -30  | GetUnitID  | init (d0=unit#, counted 3..0) |
| -18  | GetUnit    | InitUnit |
| -24  | GiveUnit   | UnitCleanup |
