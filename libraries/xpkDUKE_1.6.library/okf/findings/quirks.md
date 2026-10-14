# Quirks / defects (all reproduced, none "fixed")

## 1.6-specific

1. **Seglist stored in the code hunk.** LibInit does
   `move.l a0,code+0x7a` (absolute-long store with a RELOC32 on the
   operand) — the seglist lives in an 8-byte pad gap between the
   datatab and LibInit, i.e. self-modifying code. Expunge reads the
   same cell PC-relative (`move.l pc@(0x7a),d2`). Because
   `dataSize=0x22` the library node is a bare `struct Library` with
   no private data at all; `lib+34` reads whatever follows the
   allocation.

2. **Entry stub returns -1.** code+0 is `moveq #-1,d0; rts`
   (`70 ff 4e 75`), not the usual `moveq #0` — and nothing calls it:
   the -24 and -48 null vectors point at two separate `moveq #0`
   stubs (0x104 and 0x134).

3. **Dead stub calls in LibInit and Expunge.** Both do `bsr 0x134`
   (a routine that just returns 0) — LibInit additionally tests the
   result (`tst.l d0; bne fail`), which can never fire. Reproduced.

4. **`rt_EndSkip = code+0x106`** — points at the rts of the -24
   stub, *before* the name/idstr strings (in the middle of the
   module's front matter). Harmless but odd.

5. **Dead `cmpi.l #8` in both delta routines.** `d0 = len & 7;
   cmpi.l #8,d0; bcc done` — `(len&7)` is always < 8 so the branch
   never fires. Vestige in both 0x848 (encode) and 0x91e
   (integrate). Reproduced in C comments; semantically the routines
   are plain mod-256 delta / integrate over exactly `len` bytes.

6. **Branch-into-immediate in PackChunk's return path.** The
   success branch `bls` targets 0xada — the middle of
   `cmpi.w #0x7000,d0` at 0xad8, whose immediate bytes `70 00` are
   `moveq #0,d0`. So the code reads `-17` via one path and `0` via a
   constant smuggled inside a dead compare. Faithfully documented;
   the C source implements the same values.

7. **Scratch overflow is unbounded.** delta_encode writes InLen
   bytes into a fixed 0x8000 block; inputs > 32768 bytes (over
   MaxPkInChunk anyway) scribble past it. Verified: 'Z'*40000 packs
   to an 8-byte stream rc=0, unpacks to garbage — identical on both
   binaries (the overrun lands in the same emulated pool).

8. **PackFree/UnpackFree return FreeMem's leftover d0** (the size
   argument: 0x5c / 0x8000 in the oracle model), not a status.
   Both routines *do* clear their Sub pointers — the 1.8 stale-
   Sub[0] quirk does NOT exist here: realloc-after-PackFree
   performs a fresh 4-block allocation on both binaries.

9. **UnpackChunk allocates Sub[1] lazily** (0x8000, MEMF_ANY) even
   when PackChunk already allocated it — the pack-allocated scratch
   is simply reused if present.

10. **XpkInfo oddities**: starts at DATA+0x2a after a stray `0000`
    word pad (mode struct is 0x28 bytes + 2 pad); MinPkInChunk=10
    (1.8: 0); DefMode=50 (1.8: 100); version words {1,1,0,1};
    LongName is just "Duke"; idstring has **no `$VER:` prefix**.

## Inherited NUKE codec quirks (present identically)

11. **16-bit position domain.** Positions are words; inputs > ~64KB
    misdecode. `z40k` packs to an 8-byte stream but unpacks to
    garbage (`match=False`).

12. **`addaw` sign-extension** on `outmax`/`inlen` word fields:
    OutBufLen-4 ≥ 0x8000 sign-extends negative; reproduced via
    `(SHORT)` casts.

13. **Literal/stream overlap** detection only checks
    `litptr < outcur` *after* the streams were written — the output
    buffer can be scribbled before -17 is returned (tiny-outbuf
    test → -17 with OutLen=0xffffffff on both).

14. **Match demotion threshold**: len-code ≤1 && offset ≥ 336 →
    literal.

15. **`bls` success gate**: `outlen == inlen` counts as success
    (lit16 packs to 16 bytes, rc=0). Same BLS (`6304`) as 1.8 —
    the strict/loose boundary is unchanged between generations.

16. **Discarded first stream flush**: all four pending slots start
    at the work+80 scratch area, so each stream's first accumulator
    write is thrown away. No file data is lost; init artifact.

17. **No empty-input overrun** (differs from 1.8): the delta loops
    test `len <= 0` first, so `InLen==0` touches nothing and packs
    to an 8-byte stream that then fails the size gate (-17).
    Same for integrate at `OutLen==0`.

## machine68k notes

- Two `Machine` objects in one process interfere (trap dispatch is
  effectively global): run the original and the rebuild in separate
  processes when diffing.
- `m.execute` takes a cycle budget; long packs can silently
  "return" a stale d0 on expiry — always check xsp+16 against a
  sentinel.
