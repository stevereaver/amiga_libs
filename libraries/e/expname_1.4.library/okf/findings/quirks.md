# Quirks / oddities

- **"#%ld" fallback**: unknown ids are formatted via RawDoFmt with the
  format string `"#%ld"`, so unknown manufacturers/products render as
  `#2457` / `#3` etc. (leading '#'), NOT plain decimal.
- **Return convention is inverted vs intuition**: -1 means both names
  resolved, 0 means at least one fell back to `#N`.  Both output
  buffers are always written.
- **`bcs` early-exit relies on sorted tables**: entries after the
  insertion point are never scanned.  Duplicate/unsorted data would be
  silently unreachable.
- **IdString skips "$VER:"**: rt_IdString -> "expname.library 1.4
  (20.7.95)\r\n" — the `4:` bytes before it are the literal "$VER:"
  prefix, and the string ends in CRLF+NUL.
- **Dead code at code+0x10e**: `moveq #0,d0; bra.s` back into init's
  register-restore tail — unreachable leftover.
- **Orphan string**: "Blizzard 1230-II" (code+0x80d) is not referenced
  by any table entry — presumably a dropped product.
- **Shared name strings**: mfr 0x07fe and 0x082c share the same "BSC"
  string; 0x07e1 and 0x0891 share "Great Valley Products".
- **Init stores libbase at an absolute long in the code hunk**
  (code+0x8b2, written via relocated `move.l d0,abs`).  Nothing else
  reads it — external users could find the libbase through the hunk.
- **RomTag MatchWord and EndSkip DREL16 order**: the original linker
  lists offsets strictly descending except the last two (0x6 MatchWord
  before 0xa EndSkip); `drel16.py` reproduces this.
- **ExName register calling convention** is unusual for a library:
  args in a0/a1/a2/d0/d1, not the standard register-per-arg docs form.
