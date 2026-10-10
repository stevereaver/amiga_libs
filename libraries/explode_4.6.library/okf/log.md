# Work log

- objdump disasm -> work/code.bin (single CODE hunk)
- Full manual decode: AUTOINIT lib, one user vector -30
- Identified as "Executable exploder" V4.6 (1 Feb 1990): runtime
  decruncher + relocating loader, LoadSeg hook at init
- Diffed against the already-reconstructed 4.3 sibling: decoder
  core byte-identical; deltas = idstring, dead-end Alert, counter
  patch order, 4-signature check, NULL seglist check, 0x3e frame
- Fixed three fidelity issues vs the 4.3 C port while porting:
  bit-reservoir reload emits the new byte's MSB (not the sentinel),
  len is a wrapping UBYTE (byte-len 0 -> 256 copies), and the -23
  flag byte is read off the stream pointer, not the src cursor
- Ported ring decoder + record driver + teardown to C (explode.c);
  ABI glue (stubs, hook, tail-jump entry) in explode_lib.s
- Built with m68k-amigaos-gcc -m68000; RomTag/InitTable/datatab
  verified byte-identical; functab targets + hook verified
- OKF bundle written
