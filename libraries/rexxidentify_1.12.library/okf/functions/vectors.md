---
file: vectors
---
# Vectors

Absolute-long functab @hunk0+0xf0.

| LVO | target | role |
|-----|--------|------|
| -6  | +0x22e | Open — bumps count, returns lib base |
| -12 | +0x23c | Close — count--; on 0 closes the four dep libs |
| -18 | +0x250 | Expunge — Remove + FreeMem(0x6c) |
| -24 | +0x2c6 | Reserved stub — returns 0 |
| -30 | +0x2ca | ARexx function-host entry — dispatches ID_* / query commands via rexxsyslib |

initfn opens rexxsyslib.library v33, expansion.library v36,
commodities.library v36, identify.library v13.
