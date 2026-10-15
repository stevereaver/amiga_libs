# explode.library 7.0 (28.08.96)

1784 bytes, 1996. AUTOINIT library (rt_Version 7, pri 0). Written by
P.Struijk & A.J.Brouwer; "68040/60 bugfix by Grzegorz Calkowski".

Same job as the 5.6.29 wedge — in-place decompression of packed
executables — but the 7.0 series patches **two** dos.library entry
points instead of one:

- `LoadSeg`   (LVO -150) — the 1.x/2.x loader
- `NewLoadSeg` (LVO -768, `$FD00`) — the 2.x+ tag-list loader

Each vector gets its own six-byte `jsr old-target` stub living inside
this library's code hunk; the NewLoadSeg stub ends with `bra +6` so it
hops over the LoadSeg stub into the shared post-call checker.  Both
stubs lead into the same signature test and, on a match, the same
in-place LZ/Huffman inflate.

## Signature check (installed stub, hunk+0x200)

After `jsr`ing the real loader the stub runs:

1. `d0 <<= 2` — seglist BPTR to pointer; NULL passes through.
2. `hunk[4] == 0x48E7FFFF` — `movem.l all,-(sp)` decrunch-stub head.
3. `hunk[40..54]` matches either of two signatures:
   - `"explode.library\0"` (first compare `'expl'`, then `'ode.'`,
     `'libr'`, `'ary\0'`), or
   - `"ed explode.libra"` (`'ed e'`, `'xplo'`, `'de.l'`, `'ibra'` —
     the tail of a second marker string; the final bytes are never
     compared).
4. On a match: save d1-d7/a1-a6, 54-byte work frame, a5 = hunk+32,
   run decoder, then **unconditional `CacheClearU`** (the 040/060
   bugfix — split caches need a flush after in-place inflate).

## Decoder

Same Imploder-family backward-reading LZ + static-table Huffman
coroutine as 5.6.29 — identical tab1/tab2 tables, same 54-byte a4
frame, same ring-buffer-in-last-hunk scheme — but the code was
restructured (presumably by the 040/060 patcher):

- The hunk-link walk (`a1 = (a1<<2) follow, count d6`) is **inlined**
  at all six call sites instead of a shared subroutine.
- Every ring-long read inlines `cmpa.l a6,a2/bne/bsr refill` — the
  `_exp_rdlong` helper is gone.
- The bulk copy uses 32-byte `movem.l` bursts instead of eight
  `move.l`s.
- Decoder block order changed (literal-run check moved after the
  match-transfer loop); algorithm is identical.

## Files

- `source/explode_lib.s` — header/strings/functab/datatab, the two
  installable stubs + signature check, the -30 trampoline, and the
  full decoder + tables, all verbatim from the binary (byte-identical).
- `source/explode.c` — LibInit (dual wedge), LibOpen, LibClose,
  shared expunge body, ExpMark.
- `functions/vectors.md`, `structures/layout.md`,
  `algorithms/decoder.md`, `findings/defects.md`, `log.md`.
