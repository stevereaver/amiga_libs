# write_4.2.library — reconstruction log

- Parsed hunk file: CODE 0x868 + CODE 0x40 + DATA 0x54; RELOC32 records
  in original linker's descending-by-target order.
- RomTag at h0+4 (after `moveq #0,d0;rts` DOS stub); AUTOINIT; rt_Init
  reloc→hunk2+4 = InitTable (5th long of hunk2 region, preceded by pad).
- InitTable: `[dsize=0xb0][functab→h1+0][datatab=0][initfn→h0+0x20]`.
- Function table in hunk1: 8 absolute-long vectors (-6..-48) + -1 term.
- Transcribed hunk0 to asm; original is compiled C (stack args in most
  vectors, but reg args a1/a2/a3 in -42/-48).
- Discovered the compiler's overlapping-instruction idiom used 5 times:
  a `cmpiw #N,d0` whose immediate word is itself a valid opcode, jumped
  into mid-instruction:
    0x86/0x88: `0c40 12da` — imm = `moveb a2@+,a1@+` (copy loop body)
    0xbe/0xc0: `0c40 12db` — imm = `moveb a3@+,a1@+` (second copy loop)
    0x142/0x144: `0c40 10d9` — imm = `moveb a1@+,a0@+` (ctx copy loop)
    0x4b6/0x4b8: `0c40 7002` — imm = `moveq #2,d0` (return-2 tail)
    0x1f0/0x1f2: `0c40 200a` — imm = `movel a2,d0` (return-ctx tail)
    0x642/0x644, 0x7ce/0x7d0, 0x830/0x832: `0c40 7000` — imm = `moveq #0,d0`
  Emitted with `.short 0x0c40` + label + `.short <word>`.
- Forced abs-long forms: `lea`/`moveal` to small constants emitted as
  raw `43f9`/`45f9`/`4df9`/`2079` + `.long` (orig used abs.l throughout).
- GNU ld emitted sorted reloc offsets; fixup.py rewrites each hunk's
  RELOC32 groups in the original order (h0: self 2, →h1 4, →h2 7;
  h1: →h0 8 descending; h2: →h0 7 descending + →h1 1).
- Result: byte-identical, md5 0b4c797b31b85c4ece510e7ed70a2a0b.
- machine68k oracle: lifecycle + vec calls traced identically; deferred
  expunge verified (flags 06→0e, close returns seglist).
