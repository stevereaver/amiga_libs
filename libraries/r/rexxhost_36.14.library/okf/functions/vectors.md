---
file: vectors
---
# Vectors

21-entry absolute-long functab @h1+0x0c, all ->h0.

| LVO | target | role |
|-----|--------|------|
| -6   | +0x17a | Open |
| -12  | +0x1b2 | Close |
| -18  | +0x202 | Expunge (Remove + FreeMem(0xc6... observed d0=c6)) |
| -24  | +0x2a4 | Reserved -> 0 |
| -30  | +0x2be | query -> 0 |
| -36  | +0x390 | query -> 0 |
| -42  | +0x3ee | exec-390 (GetMsg-family) path, returns 0 |
| -48  | +0x496 | echo A0 arg |
| -54  | +0x4d4 | echo A0 arg |
| -60..-114 | +0x53a..+0x8ec | host-management ops (init REXX port etc.) |
| -96  | +0x77e | echo A0 arg |
| -102 | +0x83a | returns 0x31 |
| -120 | +0xa14 | returns 4 |
| -126 | +0xa4c | returns 4 |

initfn opens dos.library + rexxsyslib.library (unversioned, d0=0 —
v0 request = "any").
