# xpkSQSH 1.10 — defects & inconsistencies

Codec defects identical to xpkSQSH_1.00 — see
`libraries/xpkSQSH_1.00.library/okf/findings/defects.md`.

File-level oddities:

1. **Damaged repack**: the file is `xpkSQSH_1.10(a).library` with its
   code hunk truncated at 525 longs (the 1.00 hunk size), a
   1.00-style reloc+END written over the middle, and the original
   file's tail (bytes 0x8b8–0xb77) left appended after the new
   HUNK_END. The appended 704 bytes are byte-identical to (a)'s bytes
   at the same offsets — in (a) they are live hunk code (the
   68000-style decoder tail) plus the start of (a)'s reloc table.
   Nothing in the loadable image references them.
2. **Version mislabel**: says "1.10" but the loadable code is
   byte-identical to the 1.00 build — see the `xpksqsh_1.10(older)`
   twin OKF. The real 1.10 code lives in `xpkSQSH_1.10(a).library`.
