# dsp3210.library — research log

- Binary 1652B; RomTag non-AUTOINIT (flags 0, ver 2, NT_LIBRARY pri 0).
  rt_Init = code at hunk+0x64 doing MakeLibrary(functab, 0, libInit, 46)
  + AddLibrary, returns 1 on success.
- $VER string at hunk+0x2e; rt_IdString points at +0x34 (skips the
  "$VER: " token — points at "dsp3210.library 2.1 (4.3.2021)").
- functab = 8 absolute longs (-6..-48) + 0xffffffff.
- Identified as AT&T DSP3210 COFF loader: magic 0x166, BE COFF fields,
  40B section headers, 18B syms, 10B relocs.
- -36 loader engine transcribed verbatim — reads exttab pointer from
  caller stack frame (entry+12), reloc dispatch must stay bit-exact.
  Verified: 0x270-byte region byte-identical after one beqw/beqs fix.
- -30/-42/-48 reconstructed in C. dos calls via base+42 with a6
  swap per call (memorymanage convention).
- Defects found: caller-frame exttab read, dead a2/-2 path, desc[0]
  write base, unchecked Examine, 16-bit stroff trunc, bound wrap.
- Build: m68k-amigaos-gcc -m68000 -O2 -ffixed-a5. Verbatim regions
  byte-identical; functab targets verified.
