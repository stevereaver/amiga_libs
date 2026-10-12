# xpkHFMN 1.36 (68020+) — OKF index

XPK sublibrary: dynamic Huffman compression, 68020+ build by Martin
Hauner ("$VER: xpkHFMN V1.36 (Tue Jun 13 17:55:56 1995)", id string
carries "dyn. Huffman.020+ Version 1.36" / "fast dynamic Huffman
compression/decompression.").

Successor to `xpkHFMN_1.4_000_` — the *codec* is identical (same
histogram/heap/tree/codes, same serialized stream, byte-for-byte same
output size on every test corpus); the *implementation* is 68020+:

- scaled index addressing replaces `add.w rx,rx` doubling;
- `BFINS` for the pack-side bitfield insert;
- `BFEXTU` for the unpack-side 10-bit fast-table index and the deep
  32-bit window;
- pack gates on `ExecBase->AttnFlags & AFB_68020` (else -21);
- unpack synthesizes threaded machine code into the work buffer
  (interior nodes `add.l d0,d0; bcc`; leaves `moveq #sym,d1;
  move.b d1,(a2)+; dbf`) and calls `CacheClearU` (exec -636) on
  68030+/exec V36+ (else -21 on old exec);
- work buffers are per-call `AllocMem(..., MEMF_CLEAR)` — no
  xsp_Sub[] cache, so PackFree/PackReset/UnpackFree are bare `rts`
  stubs;
- pack bound check is `OutLen > OutBufLen -> -17`, post-hoc after
  FreeMem (1.4 checked `out+inlen` *during* emit).

## Contents

- `functions/vectors.md` — LVO map, verified byte-by-byte.
- `structures/layout.md` — library init tables, descriptor, workmem.
- `findings/defects.md` — quirks/bugs preserved in the reconstruction.
- `log.md` — session log.

## Files

- `binary/` — original (ignored).
- `source/xpkHFMN.c` — C reconstruction (codec + lifecycle + host shim).
- `source/xpkHFMN_lib.s` — RomTag/InitTable/functab/descriptor/mode.
- `source/Makefile`, `source/endmodule.s`.
- `work/` — IRA dump + host harnesses (ignored).

Status: complete. Committed, pushed. Plane: AMIGALIBS-94.
