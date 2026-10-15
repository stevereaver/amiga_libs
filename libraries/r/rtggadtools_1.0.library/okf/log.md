# Log

- Parsed 5-hunk layout + DEBUG/SYMBOL records; decoded InitTable @h1+0 (dsize 0x7c, ftab->h4+0, initfn h0+0x20).
- Emitted all hunk bodies verbatim; resplit fixup restores original inter-record ordering incl. DEBUG blocks.
- Initial fixup drifted 4 bytes: functab hunk body starts 0x144c not 0x1450; corrected.
- Build: BYTE-IDENTICAL (5480B). Runtime: RUNTIME-IDENTICAL — 13 vectors traced, 53 deterministic invalid accesses match.
