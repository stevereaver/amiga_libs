# config_1.0 reconstruction log

- HUNK: CODE 2404B + DATA 0x154B; AUTOINIT RomTag in the DATA hunk;
  SAS/C small-data with `a4 = _h1+0x7ffe`.
- Functab (h1+0x128): Open/Close/Expunge/null + setstr/setnum/
  getstr/getnum — an INI `[section]`/`key = value` file
  read-modify-write library.
- setstr parses the whole file via FGets into a MinList of strdup'd
  lines, then rewrites it via VFPrintf (`%s = %s\n`, `%s%s\n` section
  headers), substituting/appending the requested key.
- Reconstruction (started by subagent, completed here): generated
  verbatim asm in `source/config_h0.s`/`config_h1.s`; `fixup.py`
  restores the scrambled-order RELOC32 groups and the header
  0x56-vs-0x55 size quirk.
- **Byte-identical**: md5 `3251b43caed885d8c0ba93b8ac1c3d1e`.
- Runtime oracle (`work/oracle.py`, machine68k): AUTOINIT InitTable
  emulation (datatab cmd decode), dos FGets fixture + VFPrintf
  capture, real AddTail/RemHead/RawDoFmt. Exercises lifecycle,
  setstr rewrite, setnum, getstr, getnum, null, deferred+real
  expunge. Original vs rebuilt logs byte-identical.
- Defects recorded: ver 3.0-vs-1.0 disagreement; hunk-table
  off-by-one-long allocation; `_setnum`/`_getnum` FreeVec stack
  addresses; sloppy returns.
