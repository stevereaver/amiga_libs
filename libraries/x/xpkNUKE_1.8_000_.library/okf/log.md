# xpkNUKE_1.8(000) work log

- Extracted code hunk correctly (file offset 0x20, 0x268 longs =
  0x9a0 bytes) — the earlier pass had an 8-byte misalignment that
  produced spurious deltas (partial tab1 clear, nlits+1 copy).
- Mapped structure: entry stub + RomTag (rt_EndSkip=0), name@0x1e,
  $VER idstring@0x2e, InitTable@0x68 (dsz 0x26, functab@0x98,
  datatab@0x78, initfn@0xb0).  Functab = word-offset flavour; null
  vectors resolve to code+0.
- Lifecycle at 0xb0..0x130: LibInit stores seglist@lib+34;
  Open = opencnt++/bclr DELEXP; Close = opencnt-- ret-0-via-stub or
  falls into Expunge; Expunge = deferred via DELEXP then
  Remove+FreeMem returning seglist; PackFree at 0x116 frees work but
  leaves xsp_Sub[0] stale.
- Pack entry 0x13a: AllocMem(196700, MEMF_ANY) + scratch clear,
  common-path field init + full tab1/tab2 clears EVERY call.
- Pack core 0x2e4..0x6f2 and decoder 0x79c..0x8b6 verified
  instruction-by-instruction against the 1.9 reconstruction:
  identical codec semantics — same tables (seltab/nbtab/codetab/
  basetab/copytab values), same `cmpw d4,d6; bls` chain gate, same
  emit order, same literal-run code map {loop3,+4,+3,+2}, same
  match-length 2-bit {ext,+3,+2,+1}, same 16-n nibble extension.
- Decoder differs only in code arrangement (compact shared copy
  block; no unrolled run) — externally identical.
- Reconstruction: ported xpkNUKE.c/xpkNUKE_lib.s from the verified
  1.9 sources with the deltas applied (MEMF_ANY + scratch clear,
  every-call table clear, stale PackFree pointer, seglist@34,
  EndSkip=0, descriptor fields, null->stub vectors).
- Oracle (machine68k, work/oracle.py): 20-corpus pack streams
  byte-identical to the original; all round-trips match including
  the inherited z40k 16-bit-domain defect; lifecycle + deferred
  expunge + PackFree stale-pointer reuse + tiny-outbuf -17 verified.
  Only diffs vs original run = link-time addresses.
