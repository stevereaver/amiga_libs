# xpkBLZW 3.4 — Work log

- Parsed the 0x6ec-byte code hunk: RomTag (COLDSTART, ver 3),
  AUTOINIT datatab, word-offset functab, XpkInfo + 7 modes.
- Decoded packer at 0x166: compress-style LZW, 6-byte hash entries,
  unmasked hash ((c<<(bits-8))^pfx)*6, sizes 641..40961 (>2^bits).
  Codes 256=end, 257=clear, 258=width++; next starts 259, width 9.
- Decoded the ratio-checkpoint machinery: on width==maxw writes the
  width header, parks nextcode at -1, snapshots {in,out,ratio};
  every 256th failed insert compares
  ((in-chk_in)<<8)/(out-chk_out) vs stored ratio and emits
  {prefix,char,257}+reinit on degradation (<127 bytes left skips).
- Decoded decoder at 0x3c2: {firstchar@0, prevcode*2@2} entries,
  literal markers -(256-c), specials -32768/7/6 via V-flag chain,
  KwKwK via `e >= nextfree`, downward string stack sized by maxlen.
- Reconstructed in C + asm skeleton; m68k cross build OK.
- Host verification:
  * C pack output -> independent Python decoder: byte-exact on a
    200KB stream (19 width bumps, 3 CLEARs).
  * independent Python encoder -> C decoder: byte-exact on 16
    streams (widths 9/12/15, KwKwK, dict-full, random).
  * -17 faithfully returned when the (inlen&~31)-8 budget is
    exceeded (small/incompressible inputs).
- Documented quirks: sp@(8) emit bound bug, inlen<32 clear
  underflow, single-step width bump, moveaw sign-extension.
