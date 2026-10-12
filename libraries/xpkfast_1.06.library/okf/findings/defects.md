# xpkFAST 1.06 — quirks & defects

All reproduced faithfully in the reconstruction (the goal is
stream- and bug-compatible behavior, not a "fixed" codec).

1. **All three reset/stub vectors are no-ops.**  `-24`, `-48`
   (XpksPackReset) and `-60` (XpksUnpackReset) are all
   `moveq #0,d0;rts`.  In particular PackReset does NOT clear
   the hash/chain tables — unlike 1.2, where it zero-fills
   `(Sub[1]+1)*0x10000` bytes.  In 1.06 the only way to get
   fresh tables is to switch mode (PackChunk reallocates when
   the stored Sub[1] size differs).

2. **Workmem is not re-cleared between packs.**  Related to #1:
   repacking in the same mode reuses stale hash heads — the
   `in-4096` init fill happens inside each pack call, so this
   is masked in practice (the fill runs unconditionally).

3. **Crawler emits bytes past the input end.**  Its literal
   loop checks `a0 >= in+inlen+2` only when a flag word
   completes; between checks it emits literal bytes read past
   `inbuf+inlen`.  Decoded output of such a stream contains the
   garbage tail bytes — verified under emulation (observed
   `deadbeef` scratch bytes in decoded output).

4. **Crawler drain injects a `1` pad bit.**  The flag-register
   drain rotates until the sentinel pops; the first bit shifted
   in is X left by the last `asl.l` — which is 1, not 0.  The
   decoder consumes the pad bit as a real item flag only if it
   sits at a checked position (harmless in practice — it lands
   in the last, boundary-triggering position).

5. **Decoder asymmetric exhaustion checks.**  The four
   ping-pong paths (literal-A/literal-C/match-A/match-B) check
   `d1==0` (sentinel popped) only on the matchA->litA and
   litC->matchB transitions; after literalA and matchB the check
   is missing, so a popped sentinel bit is consumed as a real
   match flag.  On valid streams the a0>=a4 boundary check
   saves it; on corrupt streams it desyncs.

6. **Decoder has no output bound.**  It runs until the forward
   literal cursor meets the backward ctrl cursor; a corrupt
   stream writes past OutBuf or reads before InBuf without
   limit.  `xsp_OutBufLen` is never consulted.

7. **Speedy reads past input at head/tail boundary.**  The head
   loop's only end-check fires when a flag word completes;
   hashing `p[0..2]` near the end reads up to 2 bytes past
   `inbuf+inlen`.

8. **Stream-collision return path.**  When the backward ctrl
   region grows into the literals (`gap < 0`), the packer
   returns 0 and the wrapper maps it to -17 — large
   incompressible inputs reliably hit this (verified: random
   64 KB inputs -> -17 on both builds, identically).

9. **Mode select is unsigned.**  `xsp_Mode < 80` via `bcc` —
   negative modes select the crawler.

10. **Crawler wastes 192 KB of workmem.**    The hash index is
    `(0xffff0000|g)<<2` onto base `work+0x40000`: only slots
    `work+0..0x3fffc` are reachable; the 0x30000 bytes between
    the hash top and the chain table are allocated but never
    touched.

11. **Nonstandard InitStruct datatab.**  The `a0 0c` command
    writes a byte at lib+12 (inside `ln_Name`) instead of the
    conventional +8 (`ln_Type`).  Field layout still comes out
    right because the following `80 0a` long write covers it —
    cosmetic defect, preserved byte-for-byte in
    `xpkfast_lib.s`.

12. **EndSkip stub returns -1.**  The code+0 stub is
    `moveq #-1,d0;rts` — unusual (most libs use `moveq #0`).

## Verification evidence

- 86-case randomized regression (`work/regress2.py`), fresh
  machine per case, both modes: **0 diffs** — all packed
  streams byte-identical to the original, all round-trips pass,
  all -17 collisions agree.
- Descriptor/mode chain/strings: byte-identical modulo
  relocated pointers.
- Lifecycle: open/close/expunge/stubs produce identical
  register results and identical exec call sequences
  (remove+free on expunge).
- Divergence caveat: reusing emulator memory between cases
  produces misleading diffs because defects #3/#7 read stale
  heap — always verify on a fresh machine.
