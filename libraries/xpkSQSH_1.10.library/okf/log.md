# xpkSQSH 1.10 — reconstruction log

- cmp vs xpksqsh_1.10(older): first 2,232 bytes identical; the extra
  704 bytes begin at 0x8b8, immediately after HUNK_END.
- Verified all 22 hunk relocations target < 0xa0 — nothing references
  the overlay; no vector, InitTable, or descriptor field reaches it.
- Disassembled the overlay: hand-written `btst`-loop decoder fragment
  (no 68020 bitfields) — literal-run loop, width ladder with
  constants differing from the hunk decoder's, len/dist fetch, dbf
  match copy, `cmpw #31` litpress clamp, a widtab-like table at
  0xada, and a trailing `03ec` reloc block — the tail of whatever
  hunk it was cut from. Backward `bltw` at 0x91e -> 0x7b6 shows it
  was assembled contiguously against a same-prefix build.
- Conclusion: dead appended fragment; loadable image == the
  xpksqsh_1.10(older) twin. Reused that source verbatim.
- machine68k (M68020): rev=10, correct idstr/descriptor, PackerInfo
  -> lib+0x26. 16/16 sweep streams byte-identical to the original;
  all 11 packable inputs round-trip; 5 rejects return -17.
