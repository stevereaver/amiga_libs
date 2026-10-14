# xpkHUFF 0.62 — RE log

## Identification

- 2696-byte single-hunk binary (CODE hunk 0xa00 bytes),
  `xpkHUFF.library V.0.62 ($DATE: Mon Aug 10 10:31:44 1992 by
  M.Zimmermann)`.  AUTOINIT RomTag at code+0xc4, absolute-
  longword functab (10 vectors), dataSize 0xa8, negSize 0x3c,
  posSize 0xca.
- **1992 ancestor of xpkHUFF 0.64 (1997)**: same codec
  generation (identical algorithm/workmem/wire format), but
  the earlier skeleton — runtime-built XpkInfo/XpkMode
  descriptors in the library private data (xpkSQSH_1.10
  convention), dos entry stub, correct deferred expunge.

## Process

1. Parsed hunk/RomTag/InitTable/datatab; mapped all 10
   vectors via machine68k oracle (`work/oracle.py`).
2. Disassembled the whole hunk: lifecycle at 0x368-0x412,
   pack at 0x414-0x73c, unpack at 0x73e-0x9fc.
3. Found the codec to be instruction-level equivalent of the
   xpkHUFF 0.64 reconstruction — same histogram -> leaf
   records -> max-count-rescan sorted list -> pairwise merge
   -> serialized code records -> table+bit emit -> scramble
   pipeline and the same workmem maps; adopted the verified
   0.64 C code with the 0.62 lifecycle changes.
4. Reconstructed glue in asm (`source/xpkhuff_lib.s`):
   verbatim dos entry stub + 128B message, "$VER: "-skipped
   idstring, InitTable dataSize 0xa8, absolute functab,
   LibInit building mode@+0x7e then XpkInfo@+0x26 with
   pc-relative lea's, _subnoop, dead-data tail.
5. First build: `\xa0` in gas `.ascii` emitted 0x00 — GNU as
   m68k needs octal escapes; switched to `\240`.

## Debugging findings

- All pack streams byte-identical on first correct build —
  the 0.62/0.64 codecs are the same code at the semantic
  level (0.62 pushes dmarks on the stack where 0.64 used a
  table; unrolls the byte loop in decode; recomputes a4 per
  phase).
- Lifecycle probe confirmed the 0.62 deferred-expunge path
  is correct: Expunge-while-open sets flag bit 3 on the
  LIBRARY (flags 6->14); Close-to-zero then runs real expunge
  (Remove + FreeMem(lib-neg, 262) -> seglist 0x5a0000).
  Contrast 0.64 where the bit lands on ExecBase+14.
- `freemem` size observed = 262 = negSize 60 + posSize 202.

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
- Lifecycle (Open x2 / Expunge-while-open / Close x2 /
  real Expunge / stub vectors / dos entry stub Write):
  identical incl. the deferred expunge firing and the
  byte-exact 128-byte message.
- Descriptor: PackerInfo -> lib+0x26 in both; all fields,
  strings and the mode record identical.
- inlen=65537 unpack: streams identical; exact rc diverges
  (0xfff5 vs 0x30) because the wild tail walk traverses the
  library image itself — documented UB, all deterministic
  behaviour identical.
