# XpksPackReset (-48, @0x12a)

`d0 = xsp_Sub[0]`; if NULL, return.

Zero-fills with `movem` pre-decrement stores: a6 starts at
`sub + 0x40000` (the TOP of the hash table) and writes
downward: 3 longs + 1260 iterations of 5x11-long stores =
277,212 bytes total.

Effective coverage: `[sub - 15,068, sub + 262,132)` -- the
whole 256 KB hash table PLUS ~15 KB BELOW the allocated
block (shipped heap underflow defect).  The 16 KB chain
ring at sub+0x40000 is NOT cleared -- chain entries start
as whatever AllocMem left (see findings).

## Reconstruction note

The C version clears exactly the hash table (the intent);
the ~15 KB underflow is documented as a defect rather than
reproduced, since it is a heap-corruption edge effect, not
a semantic of the stream format.
