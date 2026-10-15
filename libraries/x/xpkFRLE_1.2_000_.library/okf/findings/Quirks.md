---
type: Finding
title: Quirks
description: Defects and oddities of the shipped V1.2 binary.
---

# Quirks

1. **OOB reads during scan.**  The literal scanner has no
   input-end check -- it reads until a 3-equal "triple" or
   the ~127-byte d2 budget expires, so it always reads past
   InBuf+InLen when a chunk ends in a literal (and the
   run scanner likewise overshoots at run tails).  Emission
   is clamped to the real end (a2), so output is correct;
   but the CAPACITY CHECK uses the inflated scanned length,
   so a tail literal almost always returns -17 even though
   a valid encoding exists (oracle: a pure-literal input
   always returns -17).  The C model (`make cmodel`) models
   the OOB scan deterministically as running to the cap; the
   byte-verbatim asm rebuild reproduces the OOB reads for
   real.

2. **>128-byte literal tail -> corrupt stream.**  If a tail
   literal longer than 128 slips past the (borderline)
   capacity check, its header `(len-1)^0x1f` has bit7 set
   and decodes as a REPEAT -- the stream cannot be
   decoded correctly.  Same defect class as V1.1's >128
   literal overflow, still unfixed.  Observed live: 129-byte
   literal tail emits `0x9f` + data.

3. **No OutLen write in the unpacker.**  Unlike V1.1 (and
   every other sublib in this repo), XpksUnpackChunk returns
   without storing xsp_OutLen -- xpkmaster must already
   know the size.

4. **xsp_OutBufLen ignored.**  The packer's bound is
   OutBuf + InLen; the unpacker bounds nothing.  Both only
   touch the first three arg-block longs (`moveml a0@`).

5. **InLen==0 -> -17 after OOB reads.**  Deterministic -17
   in the C model and under the (zeroed-memory) oracle; the
   shipped scan reads ~2-125 bytes OOB first (and on a
   garbage-equal byte can emit a corrupt stream instead --
   nondeterministic).

6. **Entry stub returns 0 and is triple-purpose** (module
   entry, null vector via negative functab offsets, and the
   branch trampoline for Close/Expunge tails).  V1.1 used a
   separate -1 stub and a dedicated `moveq#0` null.

7. **RT_ENDSKIP = 0** -- valid for a disk-loaded library
   (skip is only honoured by ROM scans) but unusual.

8. **Unterminated "EVE" tag** at the very end of the hunk
   (0x36d) -- an easter egg, unreferenced.

9. **Descriptor drift vs V1.1**: messages all NULL,
   MinPkInChunk 0, MaxPkInChunk 0x7fffffff, DefMode 100,
   Ratio 48 (vs advertised 2 in V1.1 -- the v1.1 figure
   looked bogus).