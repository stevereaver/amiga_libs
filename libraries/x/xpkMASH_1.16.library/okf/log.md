# Session log — xpkMASH 1.16

## Reverse engineering

- IRA disassembly of the 2036-byte single-hunk library.
- RomTag RTF_AUTOINIT v1, NT_LIBRARY, pri -127; dataSize 0x4a
  (exec@+34, seglist@+38 — order swapped vs other xpk sublibs).
- Functab: 10 LONG offsets rel. lib base + -1 terminator.
- -36 = XpksPackChunk, -54 = XpksUnpackChunk; -24/-42/-48/-60 stubs
  return 0; -30 returns the XpkInfo descriptor via `exg a0,d0`.
- Packer: hash-chain LZ77, 32KB window, lazy 1-step lookahead,
  next-byte match filter, `1<<(mode/10)` rejection budget,
  dynamic second-allocation sizing (0x20000 halved to >=0x800).
- Bit emitter: MSB-first sentinel accumulator; the code byte occupies
  a reserved slot while literal bytes pass it in the same stream
  ("2 mixed streams").
- Decoder: `1`+run code then always a match; len classes
  `0`->2 / `10`->3 / `1`+unary->lclass; 3-bit dist class + payload.

## Reconstruction pitfalls hit and fixed

- `moveb a4@-,d5` is a PREdecrement — a4 lands ON the mismatch byte so
  `len = a4-a0` is correct; naive C `p-cur` emits len+1 (corrupts).
- Chain index `a2@(0,d1:w)` sign-extends `pw*2` — positions >=0x8000
  alias into alloc1's lower half. `& 0xffff` indexing corrupts heap.
- `dbeq` filter: equal bytes at `len` -> accept candidate & evaluate.
- Chain walk restarts at the candidate base (`a5 = d4`), not the
  advanced compare pointer.
- Compare loop count is 522 (`d0=521`, dbne to -1).
- The literal-run table is used for r<8 with excess `r-8`, and the
  decoder always parses a match after the (possibly empty) run —
  initial "runs >= 6 broken" theory was wrong; the format is sound.

## Confirmed original defect

`match len2` emits `dist[10:0]` as one 11-bit field — the top 2 bits
double as the `00` token prefix.  `dist >= 0x200` sets them -> decoder
reads a different token and desyncs.  Reproduced bit-exact: my C
decoder and an instruction-level model of the original decoder diverge
at identical offsets on all corrupting inputs.

## Test results (host harness, -m32/-O2)

- 27 clean round-trips (zeros, ramps, text, periodic, random pads).
- 9+ faithful-corruption cases — all at first `len2, dist>=512` token.
- 13 faithful -17 rejections (bound = inlen-50).
- 200KB mixed input: packs to 184925; corrupt at first len2/dist>=512.
- dist >= 0x7ea0 unreachable in practice (chain aliasing retires
  candidates first), so `emit_dist`'s unbounded table walk never fires.
- Decoder OOB reads on desynced streams are original behaviour; host
  harness pads buffers (front 0x8000 — max reachable dist 0x5e9f).
