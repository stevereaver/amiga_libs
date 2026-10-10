# warpHW.library — notes & inconsistencies

## 1. Embedded PowerPC code

Vector -60 exposes a buffer of native PowerPC machine code
(big-endian `mflr`/`stwu`/`lis`/`stb`/`blr`) embedded as
68k-executable-space data.  The 68k disassembler garbles it;
it is only meaningful when run on the Blizzard PPC.

## 2. Three-hunk far-data layout

The original puts the FUNCTABLE, aux globals and strings in
a separate DATA hunk and reaches them via cross-hunk
relocations — a SAS/C far-data build.  The reconstruction
folds these into one CODE hunk (functional equivalent).

## 3. Nonstandard InitFunction

`INITFUNCTION` stores execbase and seglist into DATA-hunk
globals and calls a private sub-init rather than the usual
"store seglist@44" convention.

## 4. Reserved vector -> entry stub

Vector -24 points at `_start` (`moveq #-1,d0; rts`),
returning -1 rather than 0.

## 5. Reconstruction caveat

This library was reconstructed as a FUNCTIONAL equivalent:
the observable API and hardware side-effects are preserved,
but the internal far-data/multi-hunk layout and the exact
PPC-code placement differ from the shipped binary.
