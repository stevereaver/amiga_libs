# xpkHFMN 1.36 (020+) — vector map

AUTOINIT, **long-offset** functab at hunk+0x98 (offsets relative to lib
base, 0xffffffff terminator) — unlike 1.4's word-offset/two-pass table.

| LVO | target | bytes at target | function |
|-----|--------|-----------------|----------|
| -6  | 0x0610 | `52 6e 00 20 08 ae 00 03 00 0e 20 0e 4e 75` | LibOpen — `addq.w #1,OpenCnt(a6)`; `bclr #3,Flags` (DELEXP); `move.l a6,d0; rts` |
| -12 | 0x061e | `70 00 53 6e 00 20 66 0a 08 2e 00 03 00 0e 67 ..` | LibClose — `d0=0; subq.w #1,OpenCnt`; if 0 and DELEXP -> expunge |
| -18 | 0x0632 | `48 e7 01 02 22 4e 20 59 22 51 22 88 21 49 00 04` | LibExpunge — inline Remove() fixups, `FreeMem(base-NegSize, NegSize+PosSize)` via `moveal (4),a6; jsr a6@(-210)`; returns seglist@+34 |
| -24 | 0x0664 | `70 00 4e 75` | Reserved — `moveq #0,d0; rts` |
| -30 | 0x00fc | `20 2e 00 26 4e 75` | XpksPackerInfo — `move.l a6@(38),d0; rts` (descriptor stored by LibInit) |
| -36 | 0x0102 | `48 e7 3f 3e 2a 48 20 78 00 04` | XpksPackChunk — a0=xsp; 68020 gate; AllocMem(0x1a0a,MEMF_CLEAR); huffman pack; FreeMem; -17 if OutLen>OutBufLen |
| -42 | 0x03fa | `4e 75` | XpksPackFree — bare `rts` (per-call alloc; nothing to free) |
| -48 | 0x03fc | `4e 75` | XpksPackReset — bare `rts` (MEMF_CLEAR each call; nothing to reset) |
| -54 | 0x03fe | `48 e7 3f 3e 2a 48 20 3c 00 00 19 fa` | XpksUnpackChunk — a0=xsp; AllocMem(0x19fa,MEMF_CLEAR); codegen decoder; CacheClearU gate; decode; FreeMem |
| -60 | 0x060e | `4e 75` | XpksUnpackFree — bare `rts` |

## CPU/exec gates

- Pack entry: `moveal (4).w,a0; move.w a0@(296),d0; btst #1,d0` —
  AFB_68020 required, else `moveq #-21,d7` return.
- Unpack, before running generated code: `btst #2` on AttnFlags
  (AFB_68030); if set, requires `exec lib_Version >= 36` for
  `CacheClearU` (exec LVO -636); on 68020 the gate is skipped and no
  cache flush is needed ('020 has no data-cache coherency issue for
  freshly written code on this path in practice — and the original
  skips the call entirely).

## Notes vs 1.4

- 1.4 used per-library cached workmem in `xsp_Sub[0]` (with size
  header at -4) and real PackFree/PackReset/UnpackFree bodies. 1.36
  went per-call `MEMF_CLEAR` + immediate `FreeMem`, so all three are
  stubs. The codec/format are unchanged — streams cross-decode
  identically in both directions (verified on the host harness).
