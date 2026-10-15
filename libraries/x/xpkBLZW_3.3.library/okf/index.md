# xpkBLZW.library 3.3

XPK sublibrary by Bryan (?), "Bryan's turbo-charged LZW".
1,500 bytes, single code hunk (0x158 lw) + RELRELOC32.

Hash-chain LZW codec.  9..15-bit codes; hash table is a
0xa001-record x 6-byte open-addressed table (0x3c006 bytes
workmem, kept in xsp_Sub[0..1] across calls and re-used when
big enough).

## Structure

- Packed RomTag (RTF_AUTOINIT, ver 3, pri 0) at hunk+4 behind
  a `moveq #-1,d0/rts` trampoline.
- InitTable @0x1e: dataSize 0x28 (Library + seglist@36),
  word-offset functab @0x2e (leading -1, 10 entries, -1),
  datatab @0x46 (flags 6, ver 3 rev 3), initfn @0x178
  (stores seglist, returns base).
- Static XpkInfo @0xf8 + XpkMode @0x150 ("15 bits",
  PackMemory 0x3c006, UnpackMemory 0x20000, ratio 337).

## Stream format

`[u16 width][u16 stacksize]` then MSB-first codes.

- Codes 0..255 literals, 0x100 END, 0x101 RESET, 0x102 WIDTH-UP.
- width starts 9; packer emits 0x102 when a pending code no
  longer fits, up to width 15.
- Bit packing: 32-bit OR window at a word cursor; cursor += 2
  whenever the remaining-bit count goes negative, refill +16.
  Reader mirrors it exactly.

## Files

- `source/xpkBLZW_lib.s` -- RomTag/strings/InitTable/datatab/
  LibInit + static XpkInfo & XpkMode.
- `source/xpkBLZW.c` -- lifecycle + encoder + decoder in C.
- `source/genfunctab.py` + two-pass Makefile -- word-offset
  functab against measured symbol addresses.
- `work/oracle.py` -- bit-exact Python model (gitignored).

## Verification

- `work/oracle.py` transcribed from the IRA disassembly;
  Python pack<->unpack round-trips on ~620 generated inputs
  (random, RLE-ish, real binary), including width-up to 15,
  table-freeze and ratio-reset paths.
- C packer output is **byte-identical** to the oracle on 224
  packed streams (76 mutual rejects); C decoder round-trips
  all of them plus 112 large oracle-produced streams, 0 fails.
- Generated library: same packed RomTag, dataSize 0x28,
  byte-identical datatab, same functab shape & order.

See `functions/vectors.md`, `findings/defects.md`,
`structures/stream.md`.
