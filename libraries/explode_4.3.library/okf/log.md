# Work log

- ira disasm -> work/explode_4.3.asm
- Full manual decode: AUTOINIT lib, one user vector -30
- Identified as DSI "Executable file exploder" V4.3: runtime
  decruncher+relocating loader, LoadSeg hook at init
- Ported ring decoder + record driver + teardown to C (explode.c);
  ABI glue (stubs, hook, tail-jump entry) in explode_lib.s
- Built with m68k-amigaos-gcc -m68000; header/RomTag/datatab verified
  byte-identical through the string region
- OKF bundle written
