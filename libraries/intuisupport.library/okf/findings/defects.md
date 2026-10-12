# intuisupport.library -- defects

All preserved faithfully in the reconstruction.

1. **Make3DBorder (-30) ignores the `next` argument.**
   a0 is zeroed at function entry (`subal a3,a3; moveal a3,a0`),
   so b2.NextBorder is always NULL and the partial-failure return
   is always 0.

2. **Make3DBorder leaks the 24-byte XY block** when the third
   allocation (b2) fails: it frees b1 and returns NULL, xy is
   never freed.

3. **AbortAlert (-84) never copies the caller text** into the
   alert buffer.  The text is strlen'd for centring (x =
   320-4*len written at buf+0) and the string area is zeroed, but
   the bytes themselves are missing -- the piece the caller text
   was meant to occupy is an empty string, and the visible
   "Nach Betaetigung..." piece lands at (0xcc00?, 0x501c...) as
   a {x,y} header `00 cc / 00 50`, i.e. offscreen anyway.

4. **AbortAlert y-coordinate low byte = first byte of the
   callback's machine code.**  A 1-byte exec CopyMem from a3 into
   buf+3 executes unconditionally -- a NULL callback dereferences
   absolute address 0.

5. **ResetBufList (-54) clears only Count = size-1 bytes** of each
   buffer, leaving the last byte uncleared.

6. **Broken inittab** (see quirks.md): funcTable/initRoutine are
   raw code offsets in the DATA hunk; initRoutine (0x20) is not
   even the real init offset (0x24).  Cannot load under stock exec.
