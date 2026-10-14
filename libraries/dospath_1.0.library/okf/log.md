# dospath.library 1.0 — work log

- Parsed hunk file: CODE 0x268 longs + DATA (3-long alloc, 1-long body).
  18 h0->h0 + 12 h0->h1 RELOC32 relocs.
- Initial extraction was off-by-4 (hunk body starts at file 0x24);
  corrected decode showed a perfectly valid RomTag at h0+0x3a with
  MatchTag->itself, EndSkip->functab, COLDSTART, rt_Init->0x10a.
- Identified clone-per-open structure: Open rebuilds a library via
  MakeLibrary and opens dos.library/utility.library v37 into clone+36/40.
- Resolved all LVOs against NDK lvo includes (exec/dos/utility).
- machine68k probe confirmed MakeLibrary is called with a0=functab
  (the helper's `lea pc@(0x54),a0`), dsize=44.
- Transcribed all code verbatim to `source/dospath.s`; fixed label
  binding order issues, `beqs` vs `beqw` forms in _f768, and SUB.L
  vs SUBI encoding (raw .short).
- Build: `make` -> byte-identical, md5 `1ab7034ab9664be68b89b245289d29a1`.
  fixup.py patches header table hunk1 size (1->3) and rewrites hunk0
  RELOC32 groups in the original order.
- Oracle: fake exec (real MakeLibrary semantics writing jmp vectors),
  fake dos.library (Lock/DupLock/Examine/SameLock/CurrentDir/
  AllocDosObject/FreeDosObject) and fake utility.library (NextTagItem).
  Exercised init, clone open, -42/-36/-48/-54/-60/-66/-72/-78, close,
  expunge. Original and rebuild traces identical.
