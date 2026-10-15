# muispecial_19.11 reconstruction log

- Parsed HUNK layout: CODE 2800B + DATA 88B, standard RELOC32.
- Found RomTag at hunk0+0x5c (mid-hunk, not at 0); flags=0 →
  non-AUTOINIT, rt_Init = direct initfn @0xf4.
- initfn calls exec.MakeLibrary(functab@0x988, 0,0, 0x54) manually,
  writes type/name/flags/version/idstr/seglist fields itself,
  InitSemaphore(lib+0x26) and gd+0x20, then AddLibrary.
- Identified vectors: Open/Close/Expunge/reserved + three stub
  vectors (-30/-36/-42) + _v48 launching "MUI-Audio-Process".
- `_audioproc` opens audio.device×2 + timer.device, writes AUDnVOL
  regs, plays gd-loaded waveforms in a 92-iteration WaitIO loop with
  SIGBREAKF_CTRL_C/D abort polling.
- `_finddata` opens `mui:docs/mti.data`/`s:mti.data`, or scans s:
  ExNext for fib_Size == 0x15a09.
- Reconstruction: capstone verbatim disasm via `work/genasm.py` with
  raw-emitted mode-5 disp16-zero EAs (25 sites gas would fold),
  noncanonical `moveq #-1/-2`, `exg` spelling. Descending RELOC32
  groups restored + DATA tag rewritten by `source/fixup.py`.
- **Byte-identical**: `e0bfd6a721a26f143b834b8dd041fcd9`.
- Runtime oracle (`work/oracle.py`, machine68k): initfn→MakeLibrary,
  Open×2 (lazy dep opens), stubs, _v48 process spawn incl. dos
  Open/Read magic + CreateNewProc tag parse, direct `_audioproc` run
  (devices, 92-iter loop, AbortIO path, Forbid cleanup), deferred +
  real expunge. Original vs rebuilt logs byte-identical.
