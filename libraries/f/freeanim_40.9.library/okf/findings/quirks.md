# freeanim.library 40.9 — findings / quirks

- **Dead `-1` stub at h0+0** — `moveq #-1,d0; rts` before the
  RomTag, referenced by nothing. Probably a DOS/loader guard.
- **Packed RomTag** — matchtag at +6 (not longword-aligned +4),
  all fields unaligned-by-2 relative to h0. Works because
  RomTag parsing is offset-based.
- **RomTag flags 0x81** — AUTOINIT|RTF_EXTENDED bit set
  (unusual; normally 0x80 alone for AUTOINIT).
- **RELOC32 group order is scrambled** — `60 0a 88 76 5c 58 1a
  16 12 06` — the linker that produced this emitted records in
  non-ascending order; reproduced by `fixup.py`.
- **`4e71` nop at odd offset 0x51** — stray NOP inside the
  string/pad region, and another at 0x8c between datatab and the
  reserved stub.
- **initfn dead store** — `move.l a6,(a7)` writes execbase into
  a stack scratch slot that is never read; compiler artefact.
- **No public API** — only the 4 standard vectors; the library
  exists purely as a versioned placeholder (like 40.29, which
  was a full stub). 40.9 has a real open/close/expunge
  lifecycle but nothing to open *for*.
