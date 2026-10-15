---
file: defects
---
# Findings

- -30 ParseTuple reads `a0@` with no NULL guard; a NULL
  tuple pointer dereferences low memory.
- Tuple-code bound is `<0x46` but dispatch bound is
  `(code-1)<=32`: codes 0x22-0x45 still clone via the
  ptr array (71 entries, zero entries -> empty taglist),
  just skipping post-processing.
- Jumptab compare uses `32 < n` so index 32 (code 0x21)
  is in range — the table is exactly 33 entries; off-by-
  one style bound, harmless here.
- Close decrements word opCount even at 0 -> wraps to
  0xffff (observed under oracle close-after-expunge).
- ln_Name/ln_IdString pointers land inside the CODE
  hunk image (InitData src values are reloc slots
  +0x86/+0x98) — normal for flat libs.
- Only utility.library is opened (v36); no
  card.resource usage — parsing is pure-software over a
  caller-supplied CIS tuple byte stream.
