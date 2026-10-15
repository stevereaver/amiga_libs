# xpkHUFF 0.62 — memory layouts, descriptor, stream format

## Code hunk map (single CODE hunk, 0xa00 bytes)

| off    | contents                                                |
|--------|----------------------------------------------------------|
| 0x00   | dos entry stub (OpenLibrary/Output/Write/CloseLibrary)  |
| 0x38   | "dos.library"                                            |
| 0x44   | 128-byte "You can't execute" message                     |
| 0xc4   | RomTag (RTF_AUTOINIT, ver 0, NT_LIBRARY)                 |
| 0xde   | "xpkHUFF.library"                                        |
| 0xee   | "$VER: " prefix (NOT pointed to)                         |
| 0xf4   | id string (rt_IdString target)                           |
| 0x160  | InitTable {dataSize 0xa8, functab 0x170, datatab 0x19c,  |
|        |   initfn 0x1bc}                                          |
| 0x170  | functab: 10 absolute longs + -1                          |
| 0x19c  | datatab (type 9, name, flags 6, ver 0, rev 62, idstr)    |
| 0x1bc  | LibInit (fills descriptor into lib data)                 |
| 0x2d4  | "HUFF", 0x2dc "Huffman V\xa00.62", 0x2ec description     |
| 0x338  | "Crunching"/"Decrunching"/"Crunched"/"Decrunched"        |
| 0x368  | LibOpen / 0x376 LibClose / 0x38a LibExpunge              |
| 0x3d0  | -24 zero stub                                            |
| 0x3d4  | _subnoop (moveml/nop/moveml/rts) — dead Expunge call     |
| 0x3e0  | XpksPackerInfo (lib+0x26)                                |
| 0x3ea  | pack wrapper / 0x3f6,0x3f8 bare rts / 0x3fa unpack wrap  |
| 0x408  | -60 bare rts / 0x40a dead data {0,8,0x32e}               |
| 0x414  | pack body / 0x73e unpack body / 0x9e4 free helper        |

RELOC32 entries: msg ptr (0x1c), RomTag fields (0xc6..0xda),
InitTable + functab + datatab pointers (0x164..0x1b4).
The LibInit string lea's are pc-relative — no relocs.

## Library base (dataSize 0xa8 = 168, built by LibInit)

| off    | contents                                                |
|--------|----------------------------------------------------------|
| 0x00   | struct Library (34 bytes)                                |
| 0x22   | hb_SegList — seglist, read by Expunge                    |
| 0x26   | XpkInfo descriptor (88 bytes)                            |
| 0x7e   | XpkMode descriptor (40 bytes)                            |
| 0xa6   | 2 pad bytes                                              |

XpksPackerInfo returns `a6 + 0x26` — a pointer into the live
library base, not a code-resident record.

## XpkInfo descriptor (88 bytes, lib+0x26, run-time built)

| field | value                                   |
|-------|------------------------------------------|
| xi_XpkInfoVersion / xi_LibVersion / xi_MasterVersion / xi_ModesVersion | 1 / 0 / 1 / 0 |
| xi_Name       | "HUFF"                            |
| xi_LongName   | "Huffman V\xa00.62"               |
| xi_Description| "Dynamic huffman crunch algorithm, cache optimized byte decrunch algorithm" |
| xi_ID         | 'HUFF'                            |
| xi_Flags      | 0x2009                            |
| xi_MaxPkInChunk  | 0xfffe                       |
| xi_MinPkInChunk  | 1                            |
| xi_DefPkInChunk  | 0xfffe                       |
| xi_PackMsg / xi_UnpackMsg / xi_PackedMsg / xi_UnpackedMsg | "Crunching" / "Decrunching" / "Crunched" / "Decrunched" |
| xi_DefMode    | 50                              |
| xi_ModeDesc   | -> lib+0x7e                     |
| xi_Reserved   | 6 cleared longs                 |

Mode record (single, lib+0x7e): xm_Next=0, xm_Upto=100,
xm_Flags=1, PackMem=0x7324, UnpackMem=0x1141a, PackSpeed=0x58,
UnpackSpeed=0x8a, Ratio=0xf1, ChunkSize=0x3f,
xm_Description "normal" — only 8 of 10 name bytes written.

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
