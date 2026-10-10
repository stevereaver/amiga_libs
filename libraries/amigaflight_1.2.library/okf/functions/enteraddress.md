# AFEnterAddress (-42, @ 0x1f2)

Interactive address prompt used by the debugger.

1. `FPuts` the string `"  Enter Address : "` + Flush.
2. Reads hex via -66: non-hex char terminates.
3. If terminator != CR (13): bell (FPutC 7) + newline,
   re-prompt from step 1.
4. If value is odd (`btst #0`): prints
   `"  *** INVALID ADDRESS *** "` + bell + newline, re-prompt.
   The parity test doubles as a 68k word-alignment check.
5. Returns address in `a0` (d0/d1 are restored junk from
   the wrapper's `moveml` -- a0 is the live result register).

Quirk: an immediate CR (zero digits) accepts address 0 --
`d1` starts at 0 and the count in d2 is never checked.

## Dead duplicate at 0x2d0

A second, older copy of this routine sits at hunk+0x2d0,
unreachable from any vector or code path. It keeps the
prompt string in `a6` then calls the puts routine at 0x3e8 --
which reads `a6@(40)` expecting the library base. With a6
pointing at a string, `a6+0x28` yields garbage
(`"S  *"`-ish bytes) used as the dos base -> crash if ever
entered. Classic pre-refactor leftover.
