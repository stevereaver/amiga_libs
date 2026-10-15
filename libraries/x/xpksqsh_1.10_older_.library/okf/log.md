# xpksqsh 1.10(older) — reconstruction log

- cmp vs xpkSQSH_1.00: 15 differing bytes, all metadata — idstr
  ("1.10 (6.3.94)", 2 shorter + 2 extra pad), datatab revision
  (0x000a vs 0x0000), longname ("Squash 1.10" vs "Squash 1.0").
  Verified all 2,100 code-hunk bytes identical.
- cmp vs xpkSQSH_1.10 (2,936 B): this file is its exact first 2,232
  bytes; the rest is a 704-byte post-HUNK_END overlay.
- Reconstruction = 1.00's xpkSQSH.c verbatim + skeleton with the three
  metadata edits. No codec work needed.
- machine68k (M68020): lib loads at 0x100000, rev=10, idstr and
  descriptor correct, PackerInfo -> lib+0x26, mode block matches.
  16/16 sweep streams byte-identical to the original; 11 packable
  inputs all round-trip through the rebuilt decoder; 5 rejects return
  -17 like the original.
