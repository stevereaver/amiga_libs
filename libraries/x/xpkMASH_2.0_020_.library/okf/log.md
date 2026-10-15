---
type: Log
title: xpkMASH 2.0(020) reverse-engineering log
---

# Reverse-engineering log — xpkMASH_2.0(020).library

Source: `binary/xpkMASH_2.0(020).library`, 2096 bytes,
one CODE hunk (1976), 17 RELOC32 entries.
Plane: AMIGALIBS-97.

## Phase 1 — structure

RomTag @code+4 (RTF_AUTOINIT, ver 2, NT_LIBRARY).
InitTable @0x62: dataSize 38, word-offset functab @0x92
(`ffff` marker), datatab @0x72 (8x=long / 9x=word /
ax=byte offset-opcode InitStruct form — NOT the nibble
form the 1.16 sibling uses), init @0xaa.
Functab decoded: -24/-48/-60 all route to the entry stub
at code+0 via offset -146.  reloc[0] patches code+0 —
corrupts the stub at load.

## Phase 2 — lifecycle

InitStruct fills the standard Library fields (the two
string longs are hunk-relocated).  LibInit stores the
seglist, checks AFB_68020, refuses below 020.  Open/Close
are the standard count/DELEXP pair; Expunge does
Remove + FreeMem(NegSize..PosSize) and returns the
seglist.  No exec field — all calls via abs-4 SysBase.

## Phase 3 — codec

Disassembly (objdump; IRA was dropping extension words).
- pass1 @0x26e: rolling 16-bit pair key over a 64K-entry
  UWORD head table; `pairs = inlen>>1` longs of gap words;
  second phase (>=16203) clamps gaps >= 32415 to -1;
  `gaps[inlen-1] = -1` sentinel.
- pass2 @0x320: lazy gap-chain matcher, tries=1024,
  unbounded `cmpmb`, records = 6-byte triples
  `{pos.w, dist.w, len-2.w}` over the head table.
- emit @0x4ce: flag-slot byte + literal interleave,
  runw/lenw/distw/distor tables at 0x496/0x476/0x436/0x456.
- unpack @0x518: unrolled bit extractor, bcc-gamma for
  runs/lens, bcs-gamma for distance with the 8-bit
  raw-byte reload optimization; tables dclass @0x638,
  lclass @0x658, rclass @0x690 (with the +6 fall-through
  run base and the overlaid 16th lclass entry).

## Phase 4 — oracle verification

Built a Musashi harness (amitools/machine68k) that loads
the original HUNK, applies relocs, fakes AllocMem/FreeMem/
Remove/CacheClearU, runs LibInit, resolves the word-offset
functab and calls the real vectors.  Traced pass2 record
writes and the decoder's bit flow to confirm the grammar;
probed emit() with controlled inputs to pin down the
flag-slot mechanics.

Results:
- packed output byte-identical on all 38 regression inputs
  + named/edge cases, modulo the uninitialized final
  flag-slot byte (documented defect)
- all 38 original-produced streams decode correctly
- round-trips clean; -17 reject path verified
- defects confirmed by trace: unbounded cmpmb (~2MB reads
  past input), 1MB garbage output on dirty workbuf reuse,
  wild write to 0xfffffffe, dangling xsp_Work

## Phase 5 — reconstruction

`source/xpkMASH.c` — codec + C_* vector bodies
(transliterated, defects preserved; UWORD cursor for the
records via a word cursor keeps host byte order out).
`source/xpkMASH_lib.s` — RomTag/InitTable/datatab verbatim,
lifecycle asm, vector stubs, XpkInfo + mode record.
`genfunctab.py`/`functab_stub.s`/`Makefile` — two-pass
link that emits the word-offset functab.

m68k build: 5356 bytes (gcc codegen is larger than the
original's hand asm — layout/descriptor/functab all
verified byte-exact where they matter).  The BUILT
library was run under the same oracle: loads, inits,
packs and unpacks correctly — streams identical to the
original on all working inputs; the two divergent cases
(t07/t20 in batch) are heap-dependent UB present in the
original too (1MB garbage / wild write vs clean -17).

Host harness `work/host_mash.c` + `dbgemit`/`recdump`
for record-level tracing.
