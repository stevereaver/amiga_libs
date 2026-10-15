# xpkHUFF 1.0 — defects and quirks (all preserved in reconstruction)

1. **Magic check off by 2** — the unpacker tests `0xABADCAFE` at
   stream offset 0 (`cmpi.l #$ABADCAFE,(a1)`), but the flag word
   there must be 0; the real marker is at offset 2.  The
   plaintext fast-path can never trigger — harmless because the
   +inlen alloc bump is unconditional anyway.

2. **Descramble over-reads ~6 bytes** — the scramble loop
   iterates `u16(inlen)` times starting at `in+6`, reading
   6+2 bytes past the payload (the code-table region is long
   enough that this is benign in practice).

3. **Password hash contaminated with 0xC0** — `pwhash` loads
   `d1 = 0xC0DE` once and only `move.b` refreshes `d1.b` per
   character, so each char adds `0xC0|c`, not `c`.  Both sides
   share the routine, so interop is unaffected.

4. **16-bit `dbf` length wraps** — histogram loop and decode
   loop use word `dbf`; `inlen==0` packs 65536 phantom samples,
   `outlen>=65536` decodes only `outlen mod 65536` symbols.

5. **Workmem reuse ignores size** — unpack `tst.l 52(a3)` reuse
   accepts a pack-allocated 0x3208 body; `0x1004+inlen` can
   overflow it (inlen > 0x2204 on a live pack session).

6. **Pack budget is word-bounded** — emit budget is
   `u16(inlen)-7`; inputs >= 65535 wrap the counter, and the
   flag/hash bytes consume none of it (upfront reserve).

7. **Split return codes on overflow** — output-budget bail
   returns -17 normally but -27 when `xsp_Password` is set.

8. **Uncleared workmem** — `AllocMem(0x3208,0)`; the histogram
   region is cleared but node arena/parent fields are not —
   safe only because every live path writes before reading.

9. **PackFree leaves a stale pointer** — `xsp_Sub[0]` keeps the
   freed body address; a subsequent call reuses freed memory
   unless the master re-zeroes the params block.

10. **Single-symbol tree degenerate root** — a one-leaf tree
    gets a pseudo-root with only the '0' child wired; the
    unpacker's root-mirror patch (`child1 = child0` when '1'
    empty) is what makes its 1-bit codes decode.
