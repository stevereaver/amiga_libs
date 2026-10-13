# xpkHUFF 0.64 — memory layouts, descriptor, stream format

## XpkInfo descriptor (88 bytes, code+0x104)

| field | value                                   |
|-------|------------------------------------------|
| xpi_ID        | 'HUFF'                            |
| xpi_Flags     | 0x2009                          |
| MaxPkInChunk  | 0xfffe                          |
| MinPkInChunk  | 1                               |
| MaxPkOutChunk | 0xfffe                        |
| DefMode       | 0x32 (50)                       |

Mode record (single): xm_Next=0, xm_Upto=100, xm_Flags=1,
PackMem=0x7324, UnpackMem=0x1141a, PackSpeed=0x58,
UnpackSpeed=0x8a, Ratio=0xf1, ChunkSize=0x3f.

## Pack workmem (0x7324 = 29476 bytes)

| off     | contents                                          |
|---------|---------------------------------------------------|
| +0      | xsp pointer                                       |
| +4      | libbase                                           |
| +8      | u16 hist[256]                                     |
| +520    | shadowed xsp fields (+0 in, +4 inlen, +8 outbuf,  |
|         | +12 outlen, +16 xsp+12, +20 outlen copy)          |
| +544    | 256 leaf HuffN, 32 B each                          |
| +8768   | 255 internal HuffN, 32 B each                      |
| +16928  | root pointer                                       |
| +16932  | 256-entry code-record pointer array                |
| +21028  | 256 code records, 33 B each {len, code bytes...}   |

HuffN (32 B): link L@0, count W@4, sym B@6, flag B@7
(leaf 4, internal 1, root 5), parent L@8, child0 L@12,
child1 L@16, mark W@20.

## Unpack workmem (0x1141a = 70682 bytes)

| off     | contents                                          |
|---------|---------------------------------------------------|
| +0      | xsp, +4 libbase, +8 magic, +10 hash                |
| +14     | data start (in+6 or descr buffer)                  |
| +18     | bit-stream start (after table)                     |
| +22     | outbuf, +26 inlen-6, +30 expected outlen           |
| +34     | trie root pointer                                  |
| +38     | trie nodes, 10 B each (510 slots + root = 5110 B)  |
| +5148   | descramble buffer (0xfffe bytes)                   |

Trie node (10 B): mark B@0 (0 internal / 0xff leaf),
sym B@1, left L@2, right L@6. Reads use `move.w (a2)` —
{mark,sym} < 0 => leaf, emit sym.

## Stream format

    u16 flag          normally 0; != 0 -> -26
    u32 hash          0xABADCAFE (NULL pw) else pwhash(pw)
    table[256]:       0xff = absent
                      else len-1, then ((len-1)>>3)+1 code
                      bytes (MSB-first)
    bits:             MSB-first Huffman bit stream

Password scrambling (bytes from stream offset 6):
pack:   c = (plain ^ pw[i % pwlen]) + prev_cipher; prev = c;
        prev seed = pw[0]
unpack: plain = (c - prev_cipher) ^ pw[i % pwlen]

## pwhash() — the 0xC0 contamination quirk

    h = 0xABADCAFE;  t = 0xC0DE;
    stage1: for each byte: t = (t & 0xff00) | b;
            h.w0 += t;            // adds 0xC0xx, not the byte!
    swap h;
    stage2: for each byte: t = (t & 0xff00) | b;
            h.w0 = rol8(h.w0 ^ t);

The `move.b`-into-word quirk leaves 0xC0 in t's high byte, so
every character contributes 0xC0xx.  Empty password ->
0xCAFEABAD (swapped seed); NULL -> no hash call, 0xABADCAFE.
