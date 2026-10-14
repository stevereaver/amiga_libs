---
type: Finding
title: xpkMASH_1.98 defects and quirks (reproduced)
---

All items below are present in the original binaries and are
preserved verbatim in the byte-identical reconstruction.

## Packer

- **pass1 reads in[inlen]** — for even inlen the pair-key loop reads
  one byte past InBuf end (reads = 1 + 2*pairs).  For inlen == 0
  `gaps[-1] = -1` writes before the gap array.  Deterministic under
  the oracle because INBUF is zero-padded by 0x11000 bytes.
- **pass2 record overflow** — the 6-byte match records are written
  over the live gap table at wk+0x20000; once records exceed the
  2*inlen reservation they overlap live state.
- **literal runs >= 32776 hang** — `emit_gamma`'s span register is
  16-bit; a span wrap to 0 loops forever.  Untested in the oracle
  (would hit the 200M-instruction execute cap) but present in the
  code.
- **lazy eval reads past end** — the lazy matcher calls find() at
  cur == end and beyond; no bounds check, so hashes/compares run on
  bytes past InBuf end (deterministic given the pad).
- **chain table aliasing** — engine B indexes chain[] by
  sign-extended pos.w*2 (positions mod 0x8000) and reads
  uninitialised chain slots; allocator garbage can influence the
  stream for inlen >= 0x10001.  Oracle zero-fills allocations so the
  behaviour is reproducible.
- **len-2 matches with dist >= 512 dropped** — emit is rejected on
  both engines.
- **head[] seeded with in.w** — near a 64K boundary a dist-0
  self-match can be produced.
- **bound = OutBuf + InLen - 10** — the xsp OutBufLen field is never
  read; output must beat input by >= 11 bytes or PackChunk returns
  -17 (XPKERR_EXPAND).  Consequently every input under 11 bytes
  fails, as does empty input.

## Decoder

- a 0x00 flag byte consumed inside a distance gamma loses its
  trailing zeros
- distance-0 matches read unwritten output
- the '00' end marker reads past the stream end and can write 2
  bytes past OutBuf end

## Lifecycle / init

- InitStruct data writes byte 9 at lib+0x0c — inside the ln_Name
  pointer field written by the next table entry.  Harmless debris;
  real MakeLibrary also sets ln_Type itself.  Reproduced verbatim.
- Flags byte at lib+0x0e is set to 6 by InitStruct (CHANGED|SUMUSED);
  the deferred-expunge flag is bit 3 of the same byte.
- No PackFree state: xsp+0x34 is never touched; allocs are freed
  inline and vectors -42/-48/-60 are return-0 stubs.

## Alloc behaviour (oracle-verified)

- `inlen < 0x10001`: single `AllocMem(0x20010 + 2*inlen, MEMF_PUBLIC)`
  e.g. 300-byte input -> 131,688 bytes.
- `inlen >= 0x10001` or first alloc fails: `AllocMem(0x10000)` then
  `AllocMem(0x20000)` halving up to five tries (observed:
  allocmax=0x10000 -> fails 0x20000, succeeds 0x10000, packs fine).
- Allocs freed before PackChunk returns; failure returns -7.
- Runtime probe: `allocallfail` -> rc -7; `allocmax64k` -> rc 0.
