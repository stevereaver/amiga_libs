---
file: layout
---
# xpkSHR3 3.0 (020) layout

File 4232B. Single CODE hunk: declared 0x3fe longs @0x1c
but the body physically extends to 0x1016 (2B overrun past
the declared bound, then pad + RELOC32 tail: 23 slots all
->h0, END).

Resident @h0+4 (file +0x24): packed RomTag, flags 0x80
AUTOINIT, ver 3, type 9 library; name/id -> "xpkSHR3.library"
/ "$VER: xpkSHR3 V3.0 (1 Oct 2013) by Matthias Meixner".
InitTable @h0+0x64: dsize 0x94, functab->h0+0x90 (10 word
offsets, 0xffff-terminated), datatab->h0+0xa0, initfn->h0+0x74.

Pack context (xpk sublib state, allocated lazily on first
XpksPackChunk): hash table 3*hashsize + 36928 B hung off
xsp+0x34; unpack allocs 2016 B (ring-buffer decoder) or
67552 B (literal decoder) depending on xsp+0x14 bit 1.
