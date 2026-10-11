# xpkHFMN 1.4 — defects & inconsistencies

1. **inlen=0 DBF wrap**: histogram loop is `SUBQ.W #1,D0 / DBF` —
   inlen 0 wraps to 65536 iterations, reading 64KB past InBuf; the
   data-emit loop and the decoder's symbol counter wrap identically
   (massive out-of-bounds read/write on empty input).
2. **Output budget = inlen**: both tree and data emits bail with -17
   once the write position reaches `OutBuf+InLen`; incompressible or
   very small inputs (even 1 byte) always fail — the library cannot
   expand data at all.
3. **Data-emit check is post-write**: the bound `a1+(d5>>3) >= a4` is
   tested *after* BFINS stored the bits — the stream can scribble up
   to a few bytes past the limit before -17 is returned.
4. **Decoder reads past stream end**: the 10-bit BFEXTU prefetch plus
   the single 32-bit deep-walk window are fetched unconditionally —
   up to ~5 bytes past the packed data are read.  Codes longer than
   10+32 bits would silently misdecode (unreachable in practice since
   inlen<=0xfffe bounds depth ~16).
5. **Unpack workmem overrun on hostile input**: the trie alloc covers
   512 nodes (2048B); a corrupt tree bitstream can create node #513+,
   writing node slots into/past the fast-table region and backptr
   writes past the 0x1000 body — no bound check on `d5`.
6. **Tree-size word masked to 0x1ff**: decoder ANDs the serialized
   byte count with 0x1ff — harmless since a 256-leaf tree serializes
   to <400 bytes, but a larger count would desync.
7. **CPU gate**: init refuses to run below 68020 — correct since the
   code needs BFINS/BFEXTU; the failure path is a branch to the
   hunk-0 stub which returns 0.
8. **PackFree/UnpackFree aliasing**: -42 and -60 are the same routine;
   freeing pack workmem frees whichever alloc is present.  Sub[0] is
   left stale after free.
9. **rt_EndSkip = 0**: the RomTag EndSkip points at hunk+0 (the entry
   stub) rather than past the module — unusual but harmless for
   library autoinit.
10. **-24 quirk**: the reserved vector uses offset -0x92 to wrap onto
    the entry stub (`moveq #0,d0`) instead of a dedicated stub.
