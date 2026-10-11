# xpkTDCS.library 1.5 (020) — OKF index

Binary: `binary/xpkTDCS_1.5(020).library` (1632 bytes, single CODE hunk)
ID string: `$VER: xpkTDCS V1.5 (1 Oct 2013) by Niels Froehling`
xi_Name: "Sarnath's Doom", xi_ID 'TDCS'

## What it is

XPK compression sublibrary — "LZSS family 020+", the original of the
tiered-token Froehling LZ family (xpkLZW5's own description reads
"Very Similar to TDCS"). Lazy-matching LZ with a 64KB window,
head[65536] at workmem+0, chain[65536] at workmem+0x40000, and a
2-bit-flag tiered token stream.

## Vectors (word-offset functab @ hunk+0x94, offsets rel. marker)

| LVO | Function |
|----:|----------|
| -6/-12/-18/-24 | Open / Close / Expunge / null |
| -30 | XpksPackerInfo → XpkInfo descriptor |
| -36 | XpksPackChunk — tiered lazy-matching encoder |
| -42 | XpksPackFree — FreeMem(sub-4, buf[0]) |
| -48 | XpksPackReset — 70,577-long downward fill (underflows ~20KB) |
| -54 | XpksUnpackChunk — flag-long decoder |
| -60 | null |

## Token format

flag longs MSB-first, 16 items/long (flag=0 → 16 literal longs):

| flag | token | len | dist |
|-----:|-------|----:|-----:|
| 00 | byte | 1 | — |
| 01 | word [-dist:u14][len-3:u2] | 3..6 | ≤16384 |
| 10 | word [-dist:u12][len-3:u4] | 3..18 | ≤4096 |
| 11 | word dist + byte len-3 | 3..258 | ≤65535 |

Terminator: flag 11 + zero word (only the 11 path tests it —
the 01/10 paths read the word unconditionally).

Differences vs xpkLZW5: len fields are len-3 (LZW5: len-2), tier
caps are len≤6/len≤18 (LZW5: ≤5/≤17), terminator flag is 11
(LZW5: 01 via bset), and only the 11 path has the zero-word exit.

## Files

- `source/xpkTDCS_lib.s` — RomTag, strings, InitTable, datatab,
  LibInit (AFB_68020 gate), XpkInfo + XpkMode descriptor
- `source/xpkTDCS.c` — lifecycle + all five codec functions
- `source/genfunctab.py`, `functab_stub.s`, `endmodule.s`,
  `Makefile` — two-pass functab build
- `okf/functions/vectors.md`, `okf/algorithms/codec.md`,
  `okf/findings/defects.md`, `okf/log.md`

## Verification

- 1156 clean round-trips + 1002 defective-tier streams over a
  3000-trial randomized host suite (0 real failures).
- 120/120 sampled streams byte-identical to an independent Python
  model of the encoder, including corrupt-tier cases.
- Descriptor, strings and all 3 modes byte-identical to original.
- All 10 functab targets resolve; header/datatab byte-identical.
