# Rebuild delta

Rebuilt via m68k-amigaos-gcc -m68000.  RomTag, function table and the
embedded XpkInfo/XpkMode data match the shipped layout; code size and
instruction selection differ (GCC vs hand asm).  Algorithm verified
against the shipped bit-level semantics.
