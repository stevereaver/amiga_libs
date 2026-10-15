# xpkHFMN 1.4 (000) — defects & inconsistencies

Shared with the 020 build (see its defects.md for details):

1. **inlen=0 DBF wrap**: the histogram loop wraps to 65536 iterations
   on empty input (out-of-bounds read/write).
2. **Output budget = inlen**: emits bail with -17 once the write
   position reaches `OutBuf+InLen`; incompressible or tiny inputs
   always fail — the library cannot expand data at all.
3. **Bound check is post-write**: the emit overflow test happens after
   the bits are stored — a few bytes past the limit can be scribbled
   before -17 is returned.
4. **Decoder reads past stream end**: the lookahead window is fetched
   unconditionally (~5 bytes past the packed data).
5. **Unpack workmem overrun on hostile input**: no bound check on the
   trie node counter — a corrupt tree can write past the 0x1000 body.
6. **Tree-size word masked to 0x1ff**: harmless for real trees
   (<400 B) but a larger count would desync.
7. **PackFree/UnpackFree aliasing**: -42 and -60 are the same routine;
   Sub[0] is left stale after free.
8. **rt_EndSkip = 0**: the RomTag EndSkip points at hunk+0 rather than
   past the module — unusual but harmless.
9. **-24 quirk**: the reserved vector uses offset -0x92 to wrap onto
   the entry stub (`moveq #0,d0`).

Differences vs the 020 build:

10. **No CPU gate**: this build runs on the plain 68000 — LibInit is
    just `movea.l d0,a1; move.l a0,0x22(a1); rts`.  Correct since the
    000 codegen has no 020 instructions, but it means the two builds
    are NOT interchangeable on a mixed system.
11. **Different speed ratings**: PackSpeed 0x81 / UnpackSpeed 0xc0 vs
    the 020 build's 0x9d/0x133 — the 68000 build advertises itself as
    slower, which affects XPK mode selection.
12. **Same version string**: both builds carry `V1.4 (1 Oct 2013)` —
    they are distinguished only by the file name suffix and the
    longname ("Huffman V1.4" vs "Huffman 020+ V1.4").
