---
file: vectors
---
# Vectors

Absolute-long functab @hunk0+0x110 (identical layout to 1.15).

| LVO | target | role |
|-----|--------|------|
| -6  | +0x24e | Open — bumps count, returns lib base |
| -12 | +0x25c | Close — count--; on 0 closes the four dep libs |
| -18 | +0x270 | Expunge — Remove + FreeMem(0x6c) |
| -24 | +0x2e6 | Reserved stub — returns 0 |
| -30 | +0x2ea | ARexx function-host entry — ID_* / query commands via rexxsyslib |

initfn opens rexxsyslib.library v33, expansion.library v36,
commodities.library v36, **identify.library v41** (1.15 wanted v39).
