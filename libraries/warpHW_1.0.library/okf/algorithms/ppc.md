# warpHW.library — PPC control algorithm

The 68k functions drive the Phase5 Blizzard PPC card through
its CSPPC register window at `$00f6xxxx`:

1. `-48` performs a fixed byte-write sequence to the config
   registers (reset/enable/memory-map the PPC), pausing with
   short `NOP` delays so the hardware settles.
2. `-54` writes `$01` to `$f60038` (a single control bit).
3. `-60` yields a pointer to a native PPC routine the kernel
   uploads/executes on the PPC side (`lis r11,0xf6 /
   ori / stb / blr` — the PPC-side register poke).

`-42` locates the PPC's address window by scanning a SysBase
list for a node whose range starts at/above 0x40000000 and
ends below 0x80000000.
