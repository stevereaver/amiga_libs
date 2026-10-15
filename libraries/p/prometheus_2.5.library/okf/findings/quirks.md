# prometheus.library 2.5 — quirks & defects

## CPU requirements (bigger than advertised)

The library was linked for plain m68k output but the codegen uses
68020+ instructions:

- `bfextu dN{24:6/7},dN` (0xe9c2/e9c0) in all four indexed config
  accessors — used as a fused `(offset >> n) & mask`.
- `extbl d0` (0x49c0) in SizeToPri.
- `tst.l aN` (0x4a8a/0x4a8b) in rt_Init and WriteAddresses — **illegal on
  68000** (verified: on CPUType.M68000 the machine takes the illegal-
  instruction vector right after MakeLibrary returns).
- `pea a3@(16,d1:l:4)` style scale-4 indexed EA in QueryCard.

Net: this binary cannot run on a 68000 even though the Prometheus is a
Zorro III card theoretically usable with stock A3000/A4000 CPUs.

## Encoding / assembler-level quirks

- `moveq #67,d0; notb d0` produces 188 (`~67`) — the compiler's short
  way to materialise `sizeof(PCIBoard)` (188 > 127, can't use moveq).
  The same 188*4=752 shows up as the CreatePool puddle/threshold.
- `SizeToPri`'s loop enters via `bnes` to the exit and loops with
  `beqs` back to the `addqb` (not the `btst`) — i.e. a pre-tested
  do-while, not the more obvious while-test. Reproduced literally.
- Every PCI config access is bracketed by `exec.CacheClearU()` —
  data-cache flush per register read/write.
- Endianness is handled in software: `rol8/swap/rol8` for longs,
  `rol8` for words, and XOR swizzling of the index (`^1` for words,
  `^3` for bytes) — Prometheus cfg space is read big-endian on the
  Amiga bus.

## Init / RomTag

- `rt_Flags = 0` → COLDSTART; `rt_Init` is real code, not an InitTable.
- `rt_EndSkip` points at the `0000` pad word at 0x1e (just past the
  RomTag, before the name string).
- `rt_Version = 2` (the RomTag byte), while `lib_Version` written by
  init is also 2 and `lib_Revision = 5` — "2.5" is version 2 rev 5.
- MakeLibrary is called with `seglist = NULL` (d1=0); the real seglist
  (a0 at entry) is stored manually at lib+46.
- On init failure (pool or utility.library missing) the partially
  initialised library is NOT freed — MakeLibrary's allocation and the
  AddLibrary'd node leak (init returns 0 only via `d6`; the lib was
  already AddLibrary'd so it stays in the system list).
- Init failure path when expansion.library is absent still leaves
  d6=NULL and only closes utility — pool/lib still leak.

## QueryCard / scan quirks

- BAR size probe: write `0xFFFFFFFF`, read back, `size = -(mask)` after
  masking low bits (`&~3` for IO BARs, `&~15` for MEM BARs, `&0xF800`
  low word for the ROM BAR). A readback of all-ones is treated as
  size 0. A BAR that reads back 0 also yields size 0 → skipped.
- `type` for a request is the *mask*'s bit0 (1 = IO space), i.e.
  requests inherit PCI semantics directly.
- Slot probing is naive: cfg address = `board+0xF0000 + slot*0x2000 +
  func*0x100`, slots 0..3 always scanned; multifunction is decided from
  headertype bit7 (8 funcs) vs single-func (1 func). Ghost devices
  (vendor 0x0000 or garbage read) are NOT filtered — only 0xFFFF is
  treated as "no device", so empty slots that read back 0x0000 produce
  phantom boards with Vendor=0 (observed in the oracle).
- `ScanBoard` writes `cfg->command = 0x0700` and `cfg->latency = 0` via
  raw (non-swizzled) word/byte stores after each QueryCard — i.e.
  enables MEM+IO+BMIC (0x0007) with the byte order the bridge expects.
- `cd_Flags` is only *cleared* of bit1 and `cd_Driver` is set — the
  board is claimed regardless of `cdf_CfgInDev` state.

## Allocation-failure defect

If the `AllocPooled` for a PCIBoard returns NULL, QueryCard jumps to the
trailing-tag writer which stores `PRM_BoardOwner`, `PRM_SlotNumber` and
`PRM_FunctionNumber` through the NULL node pointer → wild writes into
low memory (0x0C + tagindex*8 …). Never triggered in practice (pool is
fresh) but a genuine latent defect.

## Request list / addressing quirks

- `WriteAddresses` assigns *window-relative* BAR values —
  `(cursor|1) & (boardsize-1)` for MEM requests (note the OR with 1:
  bit0 set on MEM BARs is a Prometheus-specific enable bit, not PCI
  semantics) and `cursor & (boardsize-1)` for IO requests. The absolute
  cursor goes into the node's MemoryAddr/ROM_Address tag.
- Requests are serviced in Enqueue order = descending `log2(size)` then
  FIFO — largest allocations first.
- The whole assignment loop **aborts** (not skips) the first time a
  request doesn't fit below the cursor floors — remaining BARs keep
  whatever value was left (e.g. the 0xFEFFFFFF probe value).
- Requests with `sr_Type` other than 0/1 consume neither window but do
  run the CacheClearU/advance path.
- `GetPhysicalAddress` uses a hardcoded window
  `[board+0x100000, board+0x1FFFFFFF]` (512 MB minus the first MB) —
  independent of `cd_BoardSize` — and returns `vaddr & 0x1FFFFFFF`
  (the masked offset form), 0 outside.

## API quirks

- `WriteConfig*` argument order is (a0=board, d0=offset, d1=data). The
  upstream changelog for 3.0 calls this the "data/offset registers
  reversed" bug — in 2.5 the order is baked into the binary and is what
  callers must use.
- `Read/WriteConfigWord` and Byte don't mask the offset the same way:
  word path masks with `&127` after `>>1`, byte path with `&255` —
  i.e. both effectively `&0xFF` on the raw offset.
- `AddIntServer` checks only `board != NULL` (a NULL interrupt struct
  is passed through to exec); `RemIntServer` checks both. Asymmetric.
- `AddIntServer` always returns 1 when board is non-NULL — the exec
  `AddIntServer` return is discarded.
- The interrupt number is hardcoded 3.
- `AllocDMABuffer`/`FreeDMABuffer` return/do nothing when the card
  can't be opened; FreeDMABuffer with NULL card silently leaks the
  caller's buffer.
- `Prometheus.card` is opened on first use and never closed until
  Expunge; failed opens retry on every call.
- ExtFunc (-24) is a reserved `clr.l d0; rts`.

## FindBoardTagList semantics

- `a0 == NULL` starts at the MinList head; otherwise resumes at
  `a0->mln_Succ` (post-increment iterator semantics).
- `a1 == NULL` returns the next board unfiltered.
- Caller tags are checked one-by-one: a tag *absent* from the board's
  taglist is skipped (does not disqualify); a tag *present but unequal*
  disqualifies the board. So `{unknown tag}` matches everything.
- Board taglists are NOT terminated with TAG_DONE — they end at the
  first zeroed TagItem left by the MEMF_CLEAR pool allocation.

## Binary-level quirks preserved

- hunk0 RELOC32 is stored as TWO groups: 7 ascending offsets to hunk0
  then a lone offset to hunk1 (`0x4dc`, the `_functab` lea). A natural
  ld output merges/emits differently — `source/fixup.py` rewrites the
  records post-link; it also asserts the hunk-1 group stays ascending.
- `lea functab.l`, `movel rt_Name.l` and `movel rt_IdString.l` are
  absolute-long (`41f9`/`2579`) with RELOC32 — gas would emit
  PC-relative (`41fa`/`257a`) for the same-section RomTag refs, so the
  source spells them as `.short opcode` + `.long target`.
- `beqs`/`bras`/`bcsw` widths chosen to match the original exactly
  (the one byte that differed on first build was the `beqs` in
  SizeToPri: target is the `addqb`, not the `btst`).
- hunk bodies carry `nop` pads at 0x92 and 0x672 (function alignment).
