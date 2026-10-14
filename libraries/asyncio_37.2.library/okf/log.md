# asyncio.library 37.2 — reconstruction log

- Parsed hunk file: CODE 0x990 + BSS 0x014; single RELOC32 record
  after hunk0 body in the original linker's descending-by-target
  order (h0→h0 group + h0→h1 group); HUNK_END after each hunk.
- RomTag at h0+0x78 with rt_Init→h0+0x38 = InitTable
  `[dsize=0x22][functab→h0+4][datatab=0][initfn→h0+0xf2]`.
- Function table at h0+4 (BEFORE the RomTag): 12 absolute-long
  vectors (-6..-72) + -1 terminator; h0+0 `moveq #0,d0;rts` doubles
  as the -24 reserved vector.
- Transcribed hunk0 to GAS asm; original is compiled C with register
  args (a0/d0/d1) and stack args (openworker bufsize/ownsFH).
- Forced encodings vs gas defaults:
    * `.short 0x49f9; .long _bsx` — abs-long lea for the globals hunk
      (gas wanted pc-relative or short forms); used at 6 sites.
    * `.short 0x294d,0x0000` — `movel a5,a4@(0)` with explicit zero
      displacement (gas elides `(0)` → `movel a5,a4@`, 2B short).
    * `.short 0x0c40` + label + `.short 0x70ff` — ReadCharAsync's
      `cmpiw #0x70ff,d0` whose operand is jumped into mid-instruction
      (`bles 0x5b6` → `moveq #-1,d0`).
    * indexed EA `a5@(0x18,d0:l)` — displacement is hex 0x18, not 18
      (4 sites: af_Buffers[curbuf]/[1-curbuf] indexing).
    * SeekAsync uses TWO epilogue labels: 0x7e6 `movel %d7,%d0` and
      0x7e8 `moveml` — error branches target the latter.
- GNU ld emitted sorted reloc offsets; fixup.py rewrites hunk0's
  RELOC32 groups to the original descending order (19 h0→h0 offsets
  descending by group, 10 h0→h1 offsets descending), and converts
  the DATA hunk to BSS tag 0x3eb with 5-long zero body.
- Result: byte-identical, md5 f723fbc9472de7efcc8e51ce6515c66a.
- machine68k oracle (`work/oracle.py`): fake exec/dos/utility stubs;
  PutMsg simulates instant dos-handler replies on a 300-byte backing
  file (dp_Type 'R'→fill buffer+Res1, 'W'→record+Res1=Arg3).
  Scenarios: normal lifecycle (init→open×2→nullvec→OpenAsync read →
  ReadAsync 700B crossing both buffers to EOF→SeekAsync read-path→
  ReadChar→CloseAsync(NULL)→OpenAsync write→WriteAsync 600→
  WriteChar→WriteAsync 300→CloseAsync flush→OpenAsyncFromFH→
  CloseAsync→expunge-while-open→close→close→deferred expunge),
  missing dos.library, missing utility.library (CloseLibrary(0)
  quirk), AllocVec failure (double-Close quirk).
  Original vs rebuilt traces: identical.
