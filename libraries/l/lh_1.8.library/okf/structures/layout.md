# lh.library 1.8 -- data layout

## CODE hunk (2728 bytes)

| Range | Contents |
|-------|----------|
| 0x00  | entry stub `moveq #-1,d0; rts` |
| 0x04  | RomTag (AUTOINIT, ver 1, rev 8) |
| 0x1e  | "lh.library\0" |
| 0x2a  | idstr, 104 bytes + NUL + pad |
| 0x94  | InitTable (dsize 0x22, ftab 0xa4, dtab 0xc8, initfn 0xec) |
| 0xa4  | functab: 8 absolute longs + 0xffffffff |
| 0xc8  | InitStruct datatab (type/name/flags/ver/rev/idstr) |
| 0xe6  | pad word |
| 0xe8  | seglist cell (written by initfn, read by Expunge) |
| 0xec  | initfn: `movel a0,0xe8:l; rts` (abs.l reloc'd to h0+0xe8) |
| 0xf4  | vectors -6..-48 |
| 0x20e | pad word == rt_EndSkip target (rt_EndSkip is RELOCATED) |
| 0x210 | decode entry + model init + main loop |
| 0x22c | 60x unrolled `moveb a2@+,a1@+` literal-copy table |
| 0x428 | packed decode table, 256 words (len.hi | code.lo nibble pairs) |
| 0x628 | encode entry, match/model/emit helpers |
| 0x9b2 | packed encode position table, 64 words |
| 0xa32 | literal path, lookahead store/advance, loop tail |

## Handle (28 bytes, allocated by -30)

| Off | Type | Meaning |
|-----|------|---------|
| +0  | ptr  | src cursor (init: src base) |
| +4  | long | src byte length (encode) -- end is src+len |
| +8  | ptr  | dst base |
| +12 | long | out: produced length (encoder stores, decode too) |
| +16 | ptr  | model/work buffer |
| +20 | long | model size (4500 decode / 40000 encode) |
| +24 | --   | unused (struct is 28B, +24..27 untouched) |

## Model buffer

Decode (4500B): tree arrays at +634 (freq), +1902 (child index),
+3168/+3802 (left/right links), root at +1264, rebuild flag at +3166.
Encode (40000B): same prefix layout plus 60-entry lookahead window at
+12506/+8312-window stores at a3-8312, hash/sym/freq/pos arrays at
+4434..+29646.
