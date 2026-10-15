# xpkSQSH 1.2 (020) — vector map

AUTOINIT, word-offset functab (leading -1 marker, signed word offsets
from the table base, -1 terminator). Hunk-relative targets in the
original:

| LVO | target | function |
|-----|--------|----------|
| -6  | 0x0bc  | Open — OpenCnt++, clear DELEXP, return base |
| -12 | 0x0ca  | Close — OpenCnt--; last close + DELEXP -> expunge |
| -18 | 0x0dc  | Expunge — unlink node + FreeMem, return seglist@+34 |
| -24 | entry stub | `moveq #0,d0;rts` |
| -30 | 0x0f2  | XpksPackerInfo — `lea 0x660,a0; rts` (returns descriptor) |
| -36 | 0x0fa  | XpksPackChunk — a0=xsp; pack |
| -42 | 0x10e  | XpksPackFree — FreeMem(Sub[0], 0x22080) if set |
| -48 | 0x118  | Pack reset/cleanup — same family as -42 |
| -54 | 0x126  | XpksUnpackChunk — a0=xsp; unpack |
| -60 | 0x10e  | UnpackFree — same routine as -42 |

LibInit (in the init table tail): stores seglist at lib+34, then
`btst #1,AttnFlags(SysBase)` — requires AFF_68020; returns NULL on
plain 68000 (the packer/decoder use `bfins`/`bfextu`-style 020
bitfield semantics in the original).

Entry stub @0: `moveq #0,d0;rts`.

All offsets resolve through the generated word-offset functab; the
reconstruction uses the same 10-entry table as the HFMN siblings.
