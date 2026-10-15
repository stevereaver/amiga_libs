# Framework / XpkSubParams

LibInit stores the seglist at base+0x22 (dataSize 0x26),
returns base.  Open/Close/Expunge are the standard AUTOINIT
trio (Remove -252, FreeMem -210).  PackFree reads buf[0]
(the AllocMem size) and calls FreeMem(-210); XpksPackChunk
lazily allocates via AllocMem(-198).

## xsp_Sub

`a0@(52)` = xsp_Sub[0]: points at buf+4 (just past the
4-byte size word) -- sub is the workmem base.

## Workmem (0x80004 = 524,292)

| off | size | use |
|-----|------|-----|
| buf+0x00000 | 4 | alloc size word (PackFree's FreeMem arg) |
| sub+0x00000 | 262144 | ULONG hash[65536] |
| sub+0x40000 | 262144 | ULONG chain[65536], ring pos&0xffff |

Advertised xm_PackMemory = 0x80004 matches the alloc.

## PackReset (-48, @0x138)

`addil #262144,d0` -> a6 = sub+0x40000 (hash top); fill
downward 3 + 4*1260*13 = 65,523 longs = 262,092 bytes:
the whole 256 KB hash plus 68 bytes BELOW sub -- which
includes the buf[0] size word and ~64 bytes under the
allocation.  The chain ring at +0x40000 is not cleared.
