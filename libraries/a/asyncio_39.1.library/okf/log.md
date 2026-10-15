# asyncio.library 39.1 — reconstruction log

- Parsed hunk file: HUNK_HEADER magic 0x3f3, tablesize=2 at file
  offset 8, size table at 0x14 (0x307, 0x5 longwords).  hunk0 CODE
  body at file 0x24..0xc40 (3100B), single RELOC32 block (24 slots
  →hunk0 + 10 slots →hunk1, descending), END at 0xce0; hunk1 BSS
  (0x3eb, size 5, no body) + END at 0xce8; EOF 0xcf0 = 3312B.
- RomTag at h0+0x8c with rt_Init→h0+0x4c = InitTable
  `[dsize=0x22][functab→h0+4][datatab=0][initfn→h0+0x106]`.
- Function table at h0+4 (BEFORE the RomTag): 17 absolute-long
  vectors (-6..-102) + -1 terminator; h0+0 `moveq #0,d0;rts` doubles
  as the -24 reserved vector.  V39 adds five slots vs 37.2:
  ReadLineAsync/WriteLineAsync/FGetsAsync/FGetsLenAsync/PeekAsync.
- Transcribed hunk0 to verbatim GAS asm via `work/gen_source.py`
  (adapted from quickhelp_37.3): data spans 0x4..0xc1 (functab,
  InitTable, idstr/libname, RomTag, dos/utility names) and
  0x2ae..0x2b3 (OpenAsync's 3-word mode table) emitted as `.byte`;
  all reloc slots (functab, InitTable ptrs, RomTag fields, `lea 0:l,a4`
  sites) are raw literals since fixup.py splices the original RELOC32
  tails verbatim.
- Transcriber fixes needed vs the quickhelp template:
    * branch targets must not be collected from garbage disassembly
      inside DATA spans (the ASCII strings decode to fake branches).
    * objdump prints plain @() displacements in DECIMAL but indexed
      @(d,r) displacements in HEX — `a0@(18,d0:l)` means 0x18.
      fixops prefixes bare numerals only inside indexed operands.
    * objdump tokens can overhang a DATA span end (the `03ec` table
      tail merged into a `bset` covering the `9efc` opcode of the open
      worker) — emit leftover bytes + boundary label when skipping.
- Forced encodings kept raw (`.byte`/`.short`): `lea 0:l,a4`
  (abs-long, 10 sites), `movel a5,a4@(0)` (explicit zero disp),
  `movew a0@(0,d2:l)` (zero disp indexed), `pea 0x1`, the three
  `cmpiw` mid-instruction hidden ops (h0+0x4fc, 0x620, 0xbfe),
  all immediate-form ops, and the garbage-decoded bytes around the
  mode table.
- hunk1 emitted as a 20-byte zero `.data` blob at the end of
  asyncio_h0.s; fixup.py (pre-seeded pattern) verifies both bodies
  then splices the original header, hunk tags (CODE / body-less
  HUNK_BSS 0x3eb) and reloc tails verbatim.
- Build: `cd source && make` → byte-identical,
  md5 82a51e5a6602a98f76f48d8b83d95f3b.
- machine68k oracle (`work/oracle.py`, CPUType.M68020): fake
  exec/dos/utility stubs; PutMsg simulates instant dos-handler replies
  on a 2048-byte backing file with an LF every 50 bytes (dp_Type
  'R'→fill buffer+Res1, 'W'→record+Res1=Arg3).
  Scenarios: normal lifecycle (init→open×2→nullvec→OpenAsync read →
  ReadAsync 700 crossing buffers→PeekAsync buffered + refill/unget →
  ReadChar→SeekAsync BEG (block refill)→FGetsAsync→FGetsLenAsync→
  ReadLineAsync truncated+drain→SeekAsync beyond EOF (af_SyncFail,
  SetIoErr 219)→SeekAsync recovery→Seek END→ReadAsync to EOF→
  Peek/FGets at EOF→CloseAsync→CloseAsync(NULL)→OpenAsync write→
  WriteAsync 600→WriteChar→WriteLineAsync→WriteAsync 300→write-seek
  flush→CloseAsync flush→OpenAsyncFromFH (a4=BSS working config)→
  ReadChar→CloseAsync→expunge-while-open→close→close→deferred
  expunge), missing dos.library, missing utility.library
  (CloseLibrary(0) quirk), AllocVec failure (double-Close quirk).
  Original vs rebuilt traces: identical.
- Note: oracle discovered the OpenAsyncFromFH a4 defect live —
  without a4 preloaded it jsr's into unmapped space (see
  findings/defects.md §1).
