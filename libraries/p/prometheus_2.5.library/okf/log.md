# prometheus.library 2.5 — reconstruction log

## Parse & map

- Hunk walk (python + `struct '>I'`): HUNK_HEADER, 2 hunks —
  hunk0 CODE table 0x266 longs (body 0x998 B @ file 0x024, completely
  fills the table), hunk1 DATA 0x13 longs (@ 0xA00). EOF exactly 0xAA8.
- RomTag @ h0+0x04: `4afc`, MatchTag reloc -> itself (h0+4), EndSkip ->
  0x1e, bytes `00 02 09 00` = flags 0 (COLDSTART), ver 2, NT_LIBRARY,
  pri 0; name -> 0x20, idstr -> 0x34, init -> 0x4ce.
- Relocs extracted verbatim from the file:
  h0: {h0: 06 0a 12 16 1a 4fc 516}, {h1: 4dc};
  h1: {h0: 00..44 step 4} (18 entries = functab).
- Disassembled hunk0 with `m68k-amigaos-objdump -D -b binary -m m68k`
  in slices around the embedded strings (0x1e..0x78, 0x4ac..0x4ce,
  0x8e6..0x8f6, 0x826..0x82e data); cross-checked with xxd.

## Identification

- Found upstream: `Sakura-IT/Prometheus` (PromLib/driver_2.c plus a
  2.5-era `driver_2.5.c` snapshot) — confirmed routine names
  (SizeToPri, AddRequest, QueryCard, WriteAddresses, ScanBoard
  semantics incl. the `while(node->mln_Succ)` iterator idiom) and the
  public API. The prometheus_lib.fd-style vector order matches the
  hunk1 table exactly (18 entries incl. reserved -24).
- All negative `jsr a6@(-N)` resolved against NDK lvo headers; library
  disambiguation done by which base register was loaded (a6=exec,
  a6=utility via lib+38, a6=expansion in init, a6=card in DMA helpers).

## Reconstruction

- Single `source/prometheus.s`: `.text` for hunk0 (stub, RomTag,
  strings, code, tag array, card string) + `.data` functab for hunk1.
- gas emits PC-relative for same-section symbol refs — the three
  absolute-long operands (`lea _functab`, `movel rt_Name/rt_IdString`)
  are written as `.short` opcode + `.long` target to force `41f9`/`2579`
  + RELOC32.
- `bfextu`/`extbl`/scale-4 index need `-m68020` (encoding identical for
  the 68000-class rest).
- First build differed in exactly ONE byte: SizeToPri's `beqs` — the
  original loops to the `addqb` (pre-tested do-while), not to the
  `btst`. After that fix: **byte-identical**
  (`md5 25a899335bb6689d619ebe1025edcd39`).
- `fixup.py` rewrites hunk0's RELOC32 to the original two-group order
  (natural ld output orders groups h0-then-h1 too, but is asserted, not
  assumed); hunk1's single ascending group is verified in place.

## Oracle (work/oracle.py)

- machine68k, **CPUType.M68020 required** — on M68000 rt_Init hits
  `tst.l a2` (illegal) right after MakeLibrary and vectors to low mem.
- Fakes: exec (MakeLibrary writing real JMP vectors, AllocPooled heap,
  Enqueue by signed pri, AddTailMin, CreatePool, OpenLibrary by name,
  FindConfigDev-free init loop, Remove/FreeMem/DeletePool/
  CacheClearU/AddIntServer/RemIntServer), utility (NextTagItem,
  FindTagItem, TagInArray), expansion (FindConfigDev -> one cdev then
  NULL), Prometheus.card (-42 alloc -> 0xC0000, -48 free).
- Fixture: cd_BoardAddr=0x400000, cd_BoardSize=0x400000; PCI cfg space
  at 0x4F0000 with slot0/func0 a real card (vendor 0x1234, headertype
  0x80 multifunction, empty BARs + ROM BAR readback) -> 4 boards total
  (slots 1-3 read vendor 0x0000 -> phantom boards, a real quirk).
- Exercises: rt_Init (full scan path incl. QueryCard/AddRequest/
  WriteAddresses/Enqueue), Open, Close, deferred Expunge -> Close ->
  seglist, FindBoardTagList (head/match/miss/iterator/filter),
  GetBoardAttrsTagList (hit/miss-count), SetBoardAttrsTagList
  (acquire/already-owned/release/non-settable), all six config
  accessors with byte-order verification, AddIntServer/RemIntServer
  (incl. NULL board), AllocDMABuffer/FreeDMABuffer (lazy card open),
  GetPhysicalAddress (window edges), ExtFunc.
- `python3 oracle.py <bin> 020` on original vs rebuild → identical logs.

## Verification

- `cmp` clean; md5 `25a899335bb6689d619ebe1025edcd39` both sides.
- git check-ignore: `*.o`, `source/*.library`, `work/` all ignored.
