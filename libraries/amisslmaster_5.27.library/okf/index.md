# amisslmaster.library 5.27 (wolfSSL-Wrapper)

`binary/amisslmaster_5.27.library` — 2512 bytes, 2 hunks (CODE 1576B
+ DATA 44B), RELOC32 relocs, plus a **full symbol hunk** and DWARF
debug hunk in the shipped binary.  AmiSSL-5 master library: a thin
wrapper that opens `amissl.library` once and hands out its base, with
an InitAmiSSLA path driven by tag lists.

Originally built with a C compiler (stack-arg calls, `pea`/`jsr`,
68020 `mulul` decimal itoa).  Symbols survive: `mLibInit`, `mLibOpen`,
`mLibClose`, `mLibExpunge`, `mLibNull`, `InitAmiSSLMaster`,
`OpenAmiSSL`, `CloseAmiSSL`, `OpenAmiSSLCipher`, `CloseAmiSSLCipher`,
`OpenAmiSSLTagList`, `mFuncTable`, `mRomTag`.

Reconstruction: `source/amisslmaster.c` (all functions incl.
lifecycle) + `source/amisslmaster_lib.s` (entry stub, strings,
extended RomTag, InitTable, .data functab).  Not byte-identical —
the rebuild is 1780 bytes vs 2516 code+data (the original also ships
sym/debug hunks; modern gcc codegen differs).  Behaviorally verified:
`work/oracle.py` drives init, all 10 vectors, the taglist matrix
(NULL/init=1 rc0,rc1/init=0+BasePtr/init=0-nobp/chain-3), lifecycle +
deferred expunge, and the RAM:awmaster.log byte stream — identical.

- [functions/vectors.md](functions/vectors.md) — LVO map + tag semantics
- [structures/layout.md](structures/layout.md) — hunk + lib data layout
- [findings/quirks.md](findings/quirks.md) — quirks and oddities
- [log.md](log.md) — work log
