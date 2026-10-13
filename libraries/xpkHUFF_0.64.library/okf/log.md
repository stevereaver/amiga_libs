# xpkHUFF 0.64 — RE log

## Identification

- 2284-byte single-hunk binary, `xpkHUFF 0.64 (01.04.1997)`.
  AUTOINIT RomTag, absolute-longword functab (10 vectors),
  dataSize 0x22, negSize 0x3c, posSize 0x44.
- Distinct generation from the completed xpkHUFF 1.0(000)
  (2013 rewrite): different workmem maps, vector stubs,
  LibInit, and decode loops — fresh RE, only the wire-format
  family is shared.

## Process

1. Parsed hunk/RomTag/InitTable/datatab; mapped all 10
   vectors via machine68k oracle (`work/oracle.py`).
2. Disassembled packer: histogram -> contiguous leaf records
   -> max-count-rescan sorted list -> pairwise merge ->
   serialized code records -> table+bit emit -> scramble.
3. Disassembled unpacker: header/hash check -> descramble ->
   10-byte-node trie build -> byte-bounded decode loop ->
   symbol-bounded tail loop.
4. Reconstructed in C (`source/xpkHUFF.c`) + asm AutoInit
   glue (`source/xpkHUFF_lib.s`, absolute functab, static
   descriptor/mode records, code-cell seglist, dead `bsr`s).
5. Oracle fix: `AllocMem` trap now honours MEMF_CLEAR
   (stale workmem had been corrupting the histogram).

## Debugging findings

- First unpack attempt produced 1999/2000 bytes — trap on
  the tail entry showed produced=1999 with the last symbol's
  code finishing 4 bits into the final input byte. Root
  cause: the tail `dbf d0` branches to the BIT-walk head and
  is only decremented after an emit — d0 counts SYMBOLS, not
  bits. Rebuilt tail emits exactly expected-produced symbols.
- Lifecycle probe showed the original's flags never change
  on Expunge-while-open: `bset #3,14(a6)` uses a6 AFTER it
  was reloaded with SysBase (micro-tested in the emulator).
  Reproduced as `EXECBASE[14] |= 8`.
- 80k input packed to outlen 10304 in the original vs 55650
  in the first C draft: the pack histogram/emit loops are
  `dbf` word counters on inlen-1. Converted all
  inlen/outlen-counted loops to USHORT dbf semantics —
  boundary cases (65536/65537/65538/131072/131074) now
  byte-identical.

## Verification matrix (orig vs rebuild, machine68k)

- 16-case standard corpus: identical rcs and stream bytes
  (only `snd` fits the budget at 2000->1800; rest -10).
- 5 skewed large inputs (2-64 syms, 4-16k): identical
  streams + round-trips.
- NULL / empty / real / wrong / mismatched passwords:
  identical, incl. -32 wrongpw.
- Bad magic -> -26; alloc failure -> -7; NULL-pw budget
  -> -17; pw-ptr budget -> -10.
- Truncated stream, expected<produced (>64k garbage emits),
  expected>produced: identical, incl. byte-level wild writes.
- Lifecycle (Open/Close/Expunge-while-open/real Expunge/
  null vectors): identical incl. the ExecBase+14 defect.
- inlen=65537 unpack: both go wild through unmapped memory;
  exact rc diverges (0xfff5 vs 0x30) because the wild walk
  traverses the library image itself — documented UB, all
  deterministic behaviour identical.
