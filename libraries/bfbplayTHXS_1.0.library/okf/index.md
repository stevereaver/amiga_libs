# bfbplayTHXS_1.0.library

"bfbplayTHXS.library V1.0 (11.08.1996)" — THX Sound-System player library
("THX Sound-System by Manfred Linzner (Pink/Abyss) and Martin Wodok
(Dexter/Abyss)."), CIA-timer driven software mixer. 5840B, m68000.

- Flat single-hunk AUTOINIT (CODE 0x586 longs = 5656B body), 33 RELOC32
  slots ->h0.
- Extended 26-byte resident @h0+4 (rt_EndSkip -> h0+0x1618 = end of
  body); `moveq#-1/rts` stub at body+0.
- Name ->h0+0x1e, id ->h0+0x32; embedded strings "dos.library",
  "ciaa.resource", "THX Sound-System", "BFBPlay CIA timer.".
- InitTable @h0+0xd8: dsize 0xb2, ftab->h0+0xe8, dtab->h0+0x124,
  initfn->h0+0x144. 14 absolute-longword vectors (LVO -6..-84).
- initfn opens dos.library (stored lib+0x28, seglist lib+0x2c).
- Player core pokes $dff000 audio regs directly and installs a CIA ICR
  interrupt via ciaa.resource (patched in-place to "ciab.resource" for
  the second chip).
