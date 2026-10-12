# explode.library — Executable Explode Wedge V6.0.64

1852 bytes, 1991. AUTOINIT library (ver 6, rev 0, pri 0). Runtime
**LoadSeg/NewLoadSeg wedge**: LibInit patches `dos.library`
`LoadSeg` (-150) and — on exec >= 37 only — `NewLoadSeg` (-768)
with 'jsr old' stubs inside this library's own hunk. Every load is
checked for the packed-program signature and inflated **in place**.

Intermediate version between 5.6.29 (single LoadSeg wedge) and 7.0
(dual wedge + SetFunction restore): this one keeps the raw slot-byte
save/restore of 5.6.29 but adds the NewLoadSeg hook. It also
tolerates a foreign 'moveq #n,d0 ; bra' wedge already in the slot —
the moveq argument is copied into the stub (stub+1) and the bra
target followed to find the real vector.

## Signature check (in the installed stub)

After `jsr`ing the real vector the shared checker runs:

1. `d0 <<= 2` — seglist BPTR to pointer; NULL passes through.
2. `hunk[4] == 0x48E7FFFF` — `movem.l all,-(sp)` decrunch-stub insn.
3. `hunk[40..] == "explode.library\0"` or the `"ed explode.libra"`
   prefix variant (16 bytes, no terminator check — loose match).

On match: save d1-d7/a1-a6, build the 54-byte a4 work frame,
a5 = hunk+32 (packed control block), call the decoder.

## Files

- `source/explode_lib.s` — RomTag/AUTOINIT header, datatab, strings,
  return-0 stub, _ExpMark (-36 bset), both wedge stubs, shared
  checker, -30 trampoline, verbatim decoder coroutine, tables.
- `source/explode.c` — LibInit (dual wedge install, slot-byte
  save/restore, execver>=37 NewLoadSeg hook), LibOpen, LibClose +
  shared expunge body.
- `source/Makefile`

The span _ExpMark.._TagEnd (0x49E bytes: -36 stub, wedge stubs,
checker, -30 trampoline, decoder, fin, tables) verifies
**byte-identical** against the shipped binary. Header region
byte-identical modulo relocated pointers.

## Decoder format (vs 5.6.29)

Same backward bitstream LZ/Huffman family; differences:

- tab2 records are 10 bytes apart (stride change), not 12
- hunk-walk inlined at all five use sites (5.6.29 has a helper)
- literal-run handler moved between match-xfer and block decrement
- match-source ring-top re-check inside the copy loop
- `andib #127` instead of `bclr #7` for the table sign bit
- 8-long `movem.l` burst copy instead of 8 discrete movels
