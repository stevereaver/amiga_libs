# explode.library — Executable Explode Wedge V5.6.29

1644 bytes, 1991. AUTOINIT library (ver 5, pri 0). A runtime
**LoadSeg wedge**: LibInit patches the `dos.library` `LoadSeg` vector
(LVO byte offset -150) with an 8-byte stub that lives inside this
library's own code hunk. Every subsequent successful `LoadSeg` call is
checked for the packed-program signature and, on a match, the freshly
loaded segment is inflated **in place** before the caller sees it.

Companion to a 1991-era executable packer ("Explode"); packed programs
begin with `movem.l d0-d7/a0-a6,-(sp)` ($48E7FFFF — the decrunch stub
they would use if the wedge were absent) and carry the literal string
`explode.library` inside a control block at hunk0+40.

## Signature check (in the installed stub)

After `jsr`ing the real LoadSeg the stub runs:

1. `d0 <<= 2` — seglist BPTR to pointer; NULL passes through.
2. `hunk[4] == 0x48E7FFFF` — first instruction is `movem.l all,-(sp)`.
3. `hunk[40..54] == "explode.library\0"` — five longword compares.

On match it saves d1-d7/a1-a6, builds a 54-byte work frame on the
stack, points A5 at `hunk+32` (the packed control block) and calls the
decoder.

## Files

- `source/explode_lib.s` — RomTag/AUTOINIT header, datatab, strings,
  return-0 stub, the installable `_ExpStub`, the -30 trampoline, the
  verbatim decoder coroutine, hunk-walk helper, decoder tables.
- `source/explode.c` — LibInit (wedge install), LibOpen, LibClose +
  shared expunge body, ExpMark.
- `source/Makefile`

The asm span `_ExpStub`..`_TagEnd` (0x3F6 bytes: wedge stub, -30
trampoline, decoder, hunk-walk, tables) verifies **byte-identical**
against the shipped binary.
