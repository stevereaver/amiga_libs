# xpkRDCN 2.4 — Shipped Quirks & Defects (reproduced faithfully)

1. **Speedy dist 1..2 encode incorrectly.** The speedy match window
   check is `d4 > 0x1002 -> literal` (signed BGT) — dist 1 and 2 are
   accepted and emitted as `enc = dist-3` = -2/-1, which wraps the
   12-bit field to 0xffe/0xfff. The decoder adds 3 back, producing
   dist 0x1001/0x1002 — a wrong backreference. Reachable via
   overlapping patterns whose bytes hash alike (e.g. "abab..."
   dist-2). The crawling packer explicitly skips dist < 3.

2. **Speedy overflow check granularity.** The out-limit
   (`out+OutBufLen-48`) is tested only once per 16-token group;
   output can temporarily exceed it within a group. Faithful.

3. **Crawler limit uses InLen, not OutBufLen.** `lim = out+InLen`
   means "output must be strictly smaller than input" regardless of
   the caller's buffer size — a large OutBuf can't rescue an
   incompressible chunk, and tiny inputs (< ~4 B) always fail -17.

4. **`subq #1,a1` on all match-loop exits** — including the
   count-exhaustion exit, which backs the input cursor into the
   already-emitted match by one byte. The next item then re-encodes
   that byte (redundant but harmless). Reproduced exactly.

5. **OOB reads.** The speedy RLE/match compares read past the input
   end when a run/match reaches the buffer boundary (bounded by the
   `a1 > end` checks that run *after* the read). The decoder likewise
   reads ctrl/item bytes past the input end on the last group.

6. **Chain table aliasing.** `chain[ptr & 0x1fff]` indexes by raw
   address mod 8192 — two positions 8 KB apart in *address space*
   share a slot. Stale (pre-reset) links also persist (PackReset
   clears only the hash table[s]). A corrupted/cyclic chain could in
   principle loop forever; the dist>=0x1003 exit is the only escape.

7. **Hash sign quirk (speedy).** `asr.b #4` on b0 sign-fills the
   low byte's high nibble for b0>=0x80, ORing away b2's low nibble
   in the XOR term — reduced hash quality for high-valued bytes.

8. **Degenerate inputs.** speedy rejects inlen<=0x12 (-17);
   crawler accepts any length but emits forced literals and then
   fails the out<in check for len < ~4. A 0-byte input packs to a
   ctrl+literal garbage byte (input OOB read), though the -17 limit
   intercepts it.

9. **All four XpkInfo message pointers are NULL** and
   `xi_DefPkInChunk = 0xffdc` (-36) — presumably a sentinel for
   "library default" consumed by the XPK master.

10. **Library name is `xpkRDCN.library`** despite the directory's
    `xpkRDCN_2.4(000).library` filename and 'd' in the apparent
    `dxpkRDCN` reading — the 'd' is the low byte of rt_Init (0x64).
