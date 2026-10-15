# icon_34.2.library

Commodore "icon 34.2 (22 Jun 1988)" — WB1.3-era icon.library.
5688B, m68000. Four shipped copies are byte-identical:
`icon_34.2`, `icon_34.2(WB1.3)`, `(WB1.3.2)`, `(WB1.3.3)`
(md5 63f57fa8279cfa98baea9c70d64ffa7b).

- 10-hunk per-function build: 9 CODE + h4 DATA (".info"/".copy"
  strings), all records/tails preserved.
- Resident @h0+4 (extended 26B, extra ptr ->h0+0x280); ver 34 rev 2.
- InitTable @h0+0x48: dsize 0x2e, ftab->h0+0x58, dtab->h0+0xa4,
  initfn->h0+0x148. 17 absolute-longword vectors.
