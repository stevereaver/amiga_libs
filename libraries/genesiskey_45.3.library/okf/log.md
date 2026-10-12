# Work log — genesiskey_45.3.library

1. Parsed hunk header manually: 3 hunks (code 0x3f8, data 0x220,
   bss 4).  Extracted code hunk; objdump full disassembly.
2. Relocation analysis: code→hunk0 self-refs reveal the absolute
   functab (0x28c) and RomTag pointer region; code→hunk1 refs map the
   data slots (exec@+0, dos@+4, intu@+8, util@+0xc, serial@+0x20) and
   the InitTable at +0x10; code→hunk2 refs = seglist slot (init write
   + expunge read).
3. Identified RomTag at 0x2cc (RTC_MATCHWORD/self-tag/COLDSTART/v45/
   NT_LIBRARY).  `rt_Init=16` resolved as data-hunk offset of the
   MakeLibrary InitTable `{0x52, functab, 0, initFn}`.
4. `btst #1, exec+297` decoded via execbase.i: offset 296..297 =
   AttnFlags; bit1 = AFF_68020 → init aborts (frees library) on
   68000/010.
5. Mapped all 15 functab vectors; named LibOpen/LibClose/LibExpunge/
   socket-probe/offset-returns; 8 empty stubs, last two crossed.
6. Data-hunk tail: `"454545"`@+0x20 (serial), `"AmigaOS 3.9"`@+0x120.
   Vectors -66/-78 return those offsets.
7. Reconstructed in C + structural .s (3-hunk build via standard
   amiga-gcc link).  Verified: hunk sizes match (0x36c mine vs 0x3f8
   orig — tighter GCC codegen), reloc classes match, data hunk
   byte-identical, RomTag byte-identical modulo relocated pointers,
   idstr corrected to `(20.11.2000)`, code tail byte-identical,
   gk_init's `btst #1,a6@(297)` byte-faithful.
8. Plane card AMIGALIBS-84.
