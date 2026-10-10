# Dead INITBYTE in InitStruct

The datatab begins `e000 000c 0900` = INITBYTE(0x0c, 9) - byte offset
0x0c sits INSIDE the ln_Name pointer field (0x0a-0x0d), and the very
next entry INITLONGs the name over it.  Net effect: zero.  Either a
dead leftover or a mistaken offset (ln_Type lives at 0x08; lib_Flags
at 0x0e gets its own init).  Reproduced verbatim in the rebuild.
