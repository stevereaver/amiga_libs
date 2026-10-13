# xpkTDCS.library 1.2 — OKF index

Binary: `binary/xpkTDCS_1.2.library` (2208 bytes, single CODE hunk)
ID string: `xpkTDCS 1.2 (20.01.2012)` — header `ln_Version` is 1,
`ln_Revision` 2.
xi_Name: "TDCS", LongName "The Doom that Came over Sarnath",
Desc "Lempel-Ziv-77 implementation with big window",
author credit "Based upon some experiments with packer, (c)DYNA-Tech".

## What it is

XPK compression sublibrary — an earlier generation of the
tiered-token Froehling LZ family than the completed 1.5(020)
sibling.  Same 2-bit flag stream and three token tiers, but the
matcher uses a pool-backed hash table of growable position
arrays (`CreatePool`/`AllocPooled`/`FreePooled`/`DeletePool`,
exec -696/-708/-714/-702) instead of a flat head/chain
workspace.  Single published mode "direct match" (upto 49,
packmem 0x800a0).

## Vectors (word-offset functab, offsets relative to table base)

| LVO | Function |
|----:|----------|
| -6 | LibOpen |
| -12 | LibClose |
| -18 | LibExpunge |
| -24 | null (`moveq #0/rts` shared stub) |
| -30 | XpksPackerInfo -> XpkInfo descriptor |
| -36 | XpksPackChunk — pool/hash lazy LZ encoder |
| -42 | null |
| -48 | null |
| -54 | XpksUnpackChunk — flag-long decoder |
| -60 | null |

## Token format

flag longs MSB-first, 16 items/long (flag long 0 → 16 literal
bytes copied as four longs, not 64):

| flag | token | len | dist bound |
|-----:|-------|----:|-----------|
| 00 | byte | 1 | — |
| 01 | word, d = (s16)tok>>2 | (tok&3)+3 | ≤16384 emit |
| 10 | word, d = (s16)tok>>4 | field0→3 else (f&7)+3+8*(f>>3) | ≤4096 emit |
| 11 | word d + byte len-3 | 3..258 | ≤65535 |

Terminator: flag 11 + zero word (only the 11 path tests it).
Decoder distances are SIGNED: `moveq #-1,d1` + `movew` keeps the
0xffff upper word, `lea dst@(0,d1:l)` is a backward reference.
Out-of-range encoder distances wrap into forward references and
corrupt output (see findings/defects.md).

## Layout

- RomTag at code+0x08: matchtag self-ref, flags 0x80 (AUTOINIT),
  ver 1, type NT_LIBRARY(9), name → "xpkTDCS.library",
  idstr → "xpkTDCS 1.2 (20.01.2012)\r\n", init → InitTable.
- InitTable: dsize 0x3c, functab (word-offsets, -1 terminator),
  datatab (byte-serial InitStruct cmds: a0/90/80/00), LibInit.
- LibInit: seglist → lib+0x26, gate AFB_68020 -> else return 0.
- Codec code follows; trailing XpkInfo descriptor + strings.

## Reconstruction

`source/` — Makefile + genfunctab.py (two-pass word-offset table),
xpkTDCS_lib.s (RomTag/InitTable/datatab/LibInit/stubs),
xpkTDCS_data.s (XpkInfo descriptor + strings), endmodule.s,
xpkTDCS.c (all non-null vectors incl. the full codec).

Oracle: `work/oracle.py` (machine68k M68020, emulates MakeLibrary/
InitStruct + exec mem/pool calls).  Verified: every test stream
byte-identical to the original, all round-trips pass; the only
residual diffs are relocated addresses and a one-bucket alloc
count delta on the -17 paths caused by an emulator `bcc`-on-
equality bug (documented in findings/defects.md).
