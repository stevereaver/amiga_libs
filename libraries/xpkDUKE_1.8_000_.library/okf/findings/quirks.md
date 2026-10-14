# Quirks / defects (all reproduced, none "fixed")

## DUKE-specific

1. **PackFree frees the wrong size.** The workspace is allocated as
   0x3758c (226700) bytes but PackFree calls `FreeMem(wm, 0x3005c)`
   — the NUKE workspace size. DUKE grew the block (delta buffer) but
   the free size wasn't updated. Observed: `freemem(0x300010,
   196700)`.

2. **PackFree leaves a stale `xsp_Sub[0]`** (never cleared). A
   subsequent PackChunk reuses the freed block — verified:
   `realloc-pack rc=0 outlen=32` runs against freed memory with no
   realloc.

3. **`bls`, not `bcs`, on the pack-success check.** `cmpl
   a5@(4),d0; blss` treats `outlen == inlen` as success (0), not as
   XPKERR_EXPAND (-17). Observable: 'abcdefghijklmnop' packs to a
   16-byte stream and returns rc=0. (NUKE 1.8 has the identical
   `6304` sequence; it just never hits equality in the usual tests.)

4. **Delta pre-pass overruns for InLen==0.** The dbf loop runs
   0x10000 times, reading 64KB past InBuf and writing 64KB from
   work+92 (overrunning the 0x7530 delta buffer into the tab1
   region; the tables are cleared afterwards so it's harmless).
   Empty input packs to an 8-byte stream then fails the size check.

5. **Delta post-pass writes past OutLen.** Integration runs in
   8-byte groups with dbf, so up to 7 bytes beyond OutLen are
   touched (and up to 0x7fff8 bytes for OutLen==0).

6. **`rt_EndSkip = 0`** — shared 1.8-generation quirk; the RomTag
   end marker points at the tag itself.

7. **Null vectors land on the code+0 stub** and Close's non-expunge
   return is a long branch (`66xx`) to offset 0 rather than a local
   `moveq #0,d0; rts`.

## Inherited NUKE codec quirks (present identically)

8. **16-bit position domain.** Positions are words; inputs > ~64KB
   misdecode. `z40k` (40000 zero bytes — exceeds MaxPkInChunk anyway)
   packs to an 8-byte stream but unpacks to garbage (`match=False`).
   The pack itself emits nothing past position 0xffff semantics.

9. **`addaw` sign-extension** on `outmax`/`inlen` word fields: an
   OutBufLen-4 ≥ 0x8000 sign-extends negative. Reproduced verbatim
   via `(SHORT)` casts in C.

10. **Literal/stream overlap** detection only checks
    `litptr < outcur` *after* the streams were written — the output
    buffer can be scribbled past its end before -17 is returned
    (e.g. lit40 writes 52 bytes into a 20-byte buffer → -17 with
    outlen 0xffffffff on the tiny-outbuf path).

11. **Match demotion threshold**: len-code ≤1 && offset ≥ 336 →
    literal (off by one vs the 0x150 boundary class).

12. **Packs can be very slow** (not infinite): n=30000 of random
    'a'/'b' (delta ≈ ±1, huge candidate chains) needs ~215M cycles —
    > the oracle's old 200M budget. Both original and rebuild behave
    identically; the budget was raised to 3e9 in `work/oracle.py`.

13. **Discarded first stream flush**: all four pending slots
    (ptr1..4) start at the work+80 scratch area, so each stream's
    very first accumulator write — `acc == 0`, triggered when the
    counter first goes negative on the first emit — lands in scratch
    and is thrown away. No file data is lost; it's an init artifact.

## machine68k notes

- Two `Machine` objects in one process interfere (trap dispatch is
  effectively global): run the original and the rebuild in separate
  processes when diffing.
- `m.execute` takes a cycle budget; packs can silently "return" a
  stale d0 when it expires — always check xsp+16 against a sentinel.
