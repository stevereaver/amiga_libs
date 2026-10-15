# xpkHFMN 1.36 (020+) — work log

- Disassembled with objdump (`-m m68k:68020`) — IRA missed the 68020
  indexed/bitfield forms (`a2@(0,d2:w:4)`, `bfins`, `bfextu`) and
  rendered them as data.
- Established the codec is the 1.4 algorithm verbatim: same
  histogram, 1-based min-heap with identical BLS tie-break, signed
  parent table, child records, preorder tree serialization
  ('1' internal / '0'+8 LSB-first sym per leaf), inlen word, codes.
- Implementation deltas vs 1.4:
  - scaled-index + `bfins` pack-side bit writer;
  - `bfextu` 10-bit fast-table index + 32-bit deep window;
  - unpack synthesizes a threaded decoder (bcc chain interior,
    moveq/move.b/dbf leaves) into the workbuf at +0x13fa, then
    CacheClearU (exec -636) on 030+/exec>=36, else -21;
  - per-call `AllocMem(0x1a0a/0x19fa, MEMF_CLEAR)` + `FreeMem` —
    PackFree/PackReset/UnpackFree collapse to bare `rts`;
  - pack bound is `OutLen > OutBufLen` post-hoc (1.4: `out+inlen`
    during emit);
  - pack gates on AFB_68020 (-21).
- Vector map verified from raw bytes: -42/-48/-60 are `4e 75` stubs;
  -54 is the real unpacker (the earlier "unpacker at 0x3fa" guess was
  off by one slot — 0x3fa/0x3fc are the two stub vectors, 0x3fe is
  the unpack entry).
- Reconstruction: `source/xpkHFMN.c` (full codec + lifecycle +
  host shim), `xpkHFMN_lib.s` (RomTag/AUTOINIT long-offset functab/
  descriptor/mode record — byte-exact metadata vs original).
- Host harness (`work/host.c`, `edge.c`, `xdec14.c`, `cmp14.c`):
  - 12-fixture round-trip all pass;
  - edge: -21 w/o 68020, -17 on too-small OutBufLen, 1-byte and
    40 KB same-byte round-trips, deep-code (>10 bit) corpus round-trip;
  - cross-decode p136->u14 and p14->u136 all pass;
  - pack streams vs 1.4 reconstruction are byte-identical on every
    input both accept (the -17 differences are the bound change).
- Fixed during write-up: trie node slot order (slot0='1' child is the
  HIGH word of the 32-bit node under the original BE byte layout),
  unpack gate ordering (alloc -> build -> 030+ gate -> flush ->
  decode; -21 still FreeMems), SysBase = `*(4)` not `(void*)4`,
  parent-table base is 0x604 with +2+2*id indexing.
- m68k build: single code hunk, functab resolves, metadata
  byte-exact. gcc does not emit literal bfins/bfextu (semantically
  equivalent sequences) — noted.
