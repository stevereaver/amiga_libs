# akcc_35.1.library

"akcc 35.1 (08 Jan 92)" — AKCC library (AmigaKit? Boese/Bethke-era util
set; vectors forward to an embedded second library). 5564B, m68000.

- 6-hunk HUNK file: h0 CODE (resident+strings+small code, 0x294B),
  h1 BSS (declared 16 longs, record size 0 — no body),
  h2 CODE (4B: `moveq #-?`,rts-style stub `16c04e75`),
  h3 CODE (0xdb0B — main code), h4 DATA (0x68B), h5 CODE (0x23cB).
- Resident @h0+4 (26B extended: extra ptr @+0xa -> InitTable h0+0x72);
  flags 0x80 AUTOINIT, ver 35, type 9, pri 1.
- Name ->h0+0x1e "akcc.library"; id ->h0+0x2b "akcc 35.1 (08 Jan 92)";
  init ->h0+0x72 (InitTable inside code hunk).
- InitTable: dsize 0x2a, ftab->h0+0x82, dtab->h0+0x136, initfn->h0+0x156.
- initfn opens dos.library, intuition.library, graphics.library.
