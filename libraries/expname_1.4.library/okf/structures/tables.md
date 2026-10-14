# Name database tables

## Manufacturer table @ code+0x24a

12-byte entries `{long mfr, long nameoff, long ptaboff}`, sorted
ascending by `mfr`, terminated by a single `.long -1` (the lookup also
early-exits on `entry.mfr > needle`).  22 manufacturers:

    0x0100 Memphis            0x0201 Commodore (Braunschweig)
    0x0202 Commodore (West Chester)   0x0420 Supra
    0x07e1 Great Valley Products      0x07fe BSC
    0x0804 Jochheim           0x0807 Checkpoint Technologies
    0x0819 Golem              0x082c BSC   (second entry)
    0x0836 Advanced Systems & Software
    0x0845 XPert/ProDev       0x0877 VillageTronic
    0x087b Utilities Unlimited
    0x0891 Great Valley Products      (second entry)
    0x089b MacroSystem (USA)  0x0a00 Harms Professional
    0x2017 Vortex             0x2140 Phase5
    0x2222 Apollo             0x3ff7 Uwe Gerlach
    0x4754 MacroSystem (Germany)

## Product tables

8-byte entries `{long prod, long nameoff}`, single `.long -1`
terminator, sorted ascending.  Notable contents:

- mfr 0x0201 (Braunschweig) only lists prod 1 "XT Bridgeboard".
  All the classic C= Amiga products (A2091=2, A2091/A590=3, A2060=9,
  A205x=10, A2232=70, A2630=81, A2065 Ethernet=112) live under mfr
  **0x0202 (West Chester)**.
- mfr 0x05fc table (Golem): prod 5 "Oktagon 2008", 6 "Tandem",
  16 "Par/Ser Card", 18 "MultiFace III", 64 "ISDN Master".
- mfr 0x2140 (Phase5): prod 10 "FastLane RAM", 11 "FastLane SCSI",
  34 "CyberVision".
- mfr 0x077a (Golden Gate): prod 7 "Golden Gate 80386 Board",
  8 "Golden Gate RAM", 9 "Golden Gate 80486 Board".
- mfr 0x0854 (MacroSystem Germany): 3 "Maestro", 4 "VLab",
  5 "MaestroPro", 6 "Retina Z2", 8 "MultiEvolution".
- mfr 0x0720 (Utilities Unlimited): prod 21 and 32 both named
  "Emplant Deluxe".

Strings and tables are interleaved in the code hunk; string storage is
packed (strings share trailing alignment, several begin on odd
boundaries — see findings).
