# Workmem layouts

## Pack (xsp_Sub[0], alloc'd 0x3714 = 4 hdr + 0x3710 body, MEMF_ANY uncleared)

| offset | size | use |
|--------|------|-----|
| 0x00 | 40 | header: params copy + links/state |
| 0x28 | 24*256=0x1800 | node arena (24-B stride) |
| 0x3010 | 256 | length table (BYTES; nibble-pack on emit) |
| 0x3110 | 512 | code table (u16) |
| 0x3490 | 256 | histogram (u16) |

Header fields written at entry: xsp ptr, 0, inbuf, inlen.

## Unpack (xsp_Sub[0], alloc'd 0x1004 = 4 hdr + 0x1000 body)

| offset | size | use |
|--------|------|-----|
| 0x00 | 4*512=0x800 | binary trie nodes (2x u16 child/leaf) |
| 0x800 | 4*1024=0x1000 | fast decode table (10-bit index) |

Stream: `0001` sig, 4-bit len x256 (>=15 adds 8-bit `len-31`),
u16 codes x256 (skip len-0), then MSB-first delta-coded bytes,
then 4-byte pad long. Decoder: fast table on first 10 bits, else
trie walk; len>16 codes split 15+rest.
