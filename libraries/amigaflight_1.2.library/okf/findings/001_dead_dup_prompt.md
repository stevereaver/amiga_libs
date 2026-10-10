# Finding 001 -- dead duplicate of the address-prompt routine

- **Location:** hunk+0x2d0..0x30a (58 bytes)
- **Evidence:** identical prompt structure to -42 AFEnterAddress
  (0x1f2) but loads the prompt string with `lea 0x62,a6`
  instead of `a0`/`d2`, then `bsr`s into the shared puts
  routine at 0x3e8.
- **Defect:** puts expects `a6` = library base and dereferences
  `a6@(40)` for the dos base. With a6 pointing at the string
  literal, a6+0x28 lands mid-string -> garbage "base" -> crash
  on the very first dos call.
- **Status:** unreachable from any vector or branch in the
  shipped binary -- a pre-refactor leftover the linker kept.
- Three more dead CRLF duplicates sit at 0x35c, 0x390, 0x3d6
  (each `moveq #10`/`bsr putchar`/`movew #13`/`bsr putchar`/
  `rts`), copies of the -36 helper.
