# utility 41.0 (020) — structure layouts

## Library node (dataSize 0x30)

Standard exec Library header (0..35), then:

| off | size | field |
|-----|------|-------|
| +36 | 4 | SysBase |
| +40 | 4 | default named object ("" with 62-byte ns block) |
| +44 | 4 | GetUniqueID counter |

## Named object

Object pointer = node + 16.

| off (node) | off (obj) | field |
|------------|-----------|-------|
| +0  | -16 | ln_Succ |
| +4  | -12 | ln_Pred |
| +8  | -8  | ln_Type |
| +9  | -7  | ln_Pri (ANO_Priority) |
| +10 | -6  | ln_Name (copied after 28-byte header + ns block) |
| +14 | -2  | refcount (word) |
| +20 | +4  | namespace block pointer (obj[4]) — set by alloc when ANO_NameSpace, overwritten by AddNamedObject |
| +24 | +8  | stored msg for deferred reply (obj[8]) |
| +16 | +0  | userspace pointer (obj[0], ANO_UserSpace, aligned up) |

Allocation = 28 + strlen(name)+1 + (ns?62:0) + (us?us+3:0).
ns block sits at blk+28, name string after it, userspace after name.

## Namespace block (62 bytes, ns+0)

| off | field |
|-----|-------|
| +0  | mlh_Head  = ns+4 |
| +4  | mlh_Tail  = 0 |
| +8  | mlh_TailPred = ns (== &mlh_Head) |
| +12 | SignalSemaphore (46 bytes, InitSemaphore) |
| +58 | flags LONG (ANO_Flags) — read as byte at +61: bit0 = dup-check on add, bit1 = exec FindName |

## Tag list

Standard TagItem pairs {ti_Tag,ti_Data}; NextTagItem handles
END(0)/IGNORE(1)/MORE(2)/SKIP(3 -> skips 1+ti_Data items), all other
tags returned.

## Pack/unpack table

Longword stream (NOT pairs): first two longs are {tagbase, pstg};
each later iteration consumes ONE pstg long (tag base stays stale);
a pstg of -1 resyncs a new {tagbase,pstg} pair; 0 ends.

pstg bits:
- bits 0-12 : byte offset (with bit-field entries, 13 bits)
- bits 13-15: bit index (bit entries only)
- bit 26    : bit op "always set" (pack)
- bit 27/28 : type — 00 byte, 01 word, 10 long, 11 bit-field
- bit 29    : UNPACK_ONLY — skipped in pack (single-longword step)
- bit 30    : PACK_ONLY — skipped in unpack
- bit 31    : unpack: sign-extend byte/word, invert bit result;
              pack: bit op toggles after set/clear (PKCTRL_FLIPBIT)
- tag lookup = tagbase + ((pstg>>16) & 0x3ff)
