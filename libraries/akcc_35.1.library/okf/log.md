# Log

- Parsed 6-hunk layout; standard extended-26B resident; InitTable in
  h0; dtab fills header via reloc'd pointers.
- Verbatim .byte emission of all 5 non-empty hunk bodies; fixup
  splices the original record stream (BSS hunk has no body).
- Build: BYTE-IDENTICAL (5564B).
- machine68k oracle: init (dos/intuition/graphics opens), open/close
  /expunge, all 41 vectors probed — RUNTIME-IDENTICAL, 0 invalids.
