# freeanim.library 40.29 — layout

h0 body (108 B):
- 0x00 `moveq #-1,d0; rts` — DOS-exec stub (returns -1)
- 0x04 RomTag: 4afc, matchtag->0x04, endskip->0x6a, 80 28 09 00,
  name->0x1e, idstr->0x2f, init->0x4a
- 0x1e "freeanim.library\0"
- 0x2f "freeanim 40.29 (1.4.94)\r\n\0" (odd-aligned, packed)
- 0x49 pad byte
- 0x4a InitTable: dsize 0x2a, ftab->0x5a, dtab 0, initfn->0x66
- 0x5a functab (word mode): ffff, 000c x4, ffff — offsets are
  relative to the functab base, 0x5a+0xc = 0x66
- 0x66 `moveq #0,d0; rts` — the one shared stub
- 0x6a EndSkip target; 0x6a-0x6b pad

Relocs (h0->h0): {0x6,0xa,0x12,0x16,0x1a,0x4e,0x56} — RomTag
matchtag/endskip/name/idstr/init + InitTable ftab/initfn.
EndSkip relocated too (harmless).
