# freeanim.library 40.9 — RE log

## 2026-10-15 (byte-exact pass)

- An earlier committed C reconstruction (05b89be: freeanim.c +
  two-pass genfunctab) produced a valid but non-identical
  1528 B image. Superseded by verbatim `source/freeanim.s`;
  stale plumbing (freeanim_lib.s, datatab.s, endmodule.s,
  functab_stub.s, genfunctab.py) removed; freeanim.c kept as
  semantic reference.
- Byte-identical, 396 B, MD5 `03cd7bf7fd38450a49c3bc53d25f7dcf`.
- `work/oracle.py`: machine68k full-lifecycle oracle —
  RUNTIME-IDENTICAL vs original.


- Parsed hunk: single CODE hunk, 0x4c longs body @file 0x20,
  RELOC32 @0x150 (10 self-rels), HUNK_END. File 396 B.
- RomTag @h0+4 (packed): AUTOINIT v40 r9, InitTable @0x54.
- Word-offset functab @0x64: 4 vectors -> open 0xf0,
  close 0xf8, expunge 0x94, stub 0x90.
- Disassembled tail (0x88-0x130): open/close/expunge/initfn —
  all trivially decodable, exec-only calls.
- Reconstruction: `source/freeanim.s` verbatim transcription.
  GNU `movea.l (4).w` needed `(4).w` syntax for abs.w mode.
  Reloc-group order fixed by `source/fixup.py`.
- Build: byte-identical, 396 B.
- Oracle (`work/oracle.py`): machine68k, real Remove/FreeMem
  traps, word-mode functab parser, InitStruct runner.
  Exercised: initfn seglist store, Open x2 (cnt 1,2), -24 stub
  ->0, dead h0 stub ->-1, close, deferred expunge (flags
  0x08 set), final close -> real expunge
  (`remove(0x100000)`, `freemem(0x100000-24, 96)`), close
  returns seglist. orig vs rebuild logs identical:
  RUNTIME-IDENTICAL.
- MD5 rebuilt = original = `03cd7bf7fd38450a49c3bc53d25f7dcf`.
