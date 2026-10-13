# xpkSQSH 1.10 — defects & inconsistencies

Codec defects identical to xpkSQSH_1.00 — see
`libraries/xpkSQSH_1.00.library/okf/findings/defects.md`.

File-level oddities:

1. **704-byte dead overlay after HUNK_END**: appended code fragment
   (btst-based 68000-style decoder with a different width-ladder
   constant set and its own reloc tail at the end). Never loaded,
   never referenced — probably a mis-assembly or a cat'ed fragment
   from a related build that shipped inside the release.
2. **Version mislabel**: says "1.10" but the loadable code is
   byte-identical to the 1.00 build — see the `xpksqsh_1.10(older)`
   twin OKF. If the overlay is the real 1.10 decoder it was never
   wired into the image.
