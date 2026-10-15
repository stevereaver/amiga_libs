---
file: defects
---
# Findings

- rt_Flags=0x00 — neither AUTOINIT nor COLDSTART-as-code in the
  modern sense; exec still calls rt_Init directly.  The "library" is
  a raw jmp table + hand-assembled node, pre-dating the InitTable
  convention.
- init leaves `clrb a3@` on the scratch block then AddLibrarys the
  jmp-table base; the lib node (LN_TYPE 9) sits right at the table's
  end (h0+0x90).
- Slot -108 jumps to h0+0 (`moveq #0,d0;rts` stub) — a dead
  vector kept for alignment.
- expunge path does RemLibrary + CloseLibrary + returns the stashed
  seglist (0x5a0000 observed).
