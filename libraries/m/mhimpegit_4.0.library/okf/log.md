# mhimpegit.library 4.0 — RE log

- Parsed hunk header: CODE(1692B)/DATA(84B)/BSS(16B). BSS hunk has no
  file body — the initial parser treated it as data and misread.
- RomTag at code+0x140, version 4, AUTOINIT; rt_Init is a data-hunk
  reloc → InitTable at data+4 `{dsize=0x2e, ftab→data+0x14,
  datatab→code+0x15e, init→code+4}`. 14-entry absolute-long functab.
- Discovered 68020+ ISA: `61ff` BSR.L misexecuted under M68000; the
  oracle uses CPUType.M68020. Memory-indirect EAs and divu.l confirm.
- Strings: mhimpegit.library / $VER id / dos.library / prelude.library /
  MPEGit / 4.0 (22.05.2022) / Thomas Wenzel.
- Init: stores lib→BSS+0, SysBase→lib+38 & BSS+4, seglist→lib+34; opens
  dos.library v36 → BSS+8 and lib+42; fail path frees the lib block.
- OpenLibrary stub needed byte-string keys (str/bytes mismatch made
  prelude open return 0 → create silently failed).
- Feature gate: `btst #0, prelude@(38)@(15)` — bit0 of
  `*(prelude+0x38)+0x15`; prelude flag lives at `*(prelude+0x8e)+0x10`.
- Verified on Musashi oracle: init fields, create taglist
  `{32:a0, 33:d0, 3f:100}`, append/iterate prelude@-60 notify + node
  marking, pop gating on flag>=count, drain sequence (-84/-36/Delay35),
  destroy teardown + BSS clear, classify map incl. string pointers,
  all 7 dispatch cases (ops 2/4 silent), expunge immediate + deferred.
- Reconstruction: C + thin asm stubs; built 4320B hunk library; all
  vectors verified identical modulo the documented heap-dependent OOB
  reads and stale-register high words.
