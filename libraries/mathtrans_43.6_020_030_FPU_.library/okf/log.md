# Work log — mathtrans_43.6(020_030_FPU)

- Parsed hunk structure: single CODE hunk, RomTag@+4, AUTOINIT word-offset functab@+0x8c (22 entries incl. extra -132 `ftentox`), InitStruct datatab@+0xbc.
- Decoded lifecycle (init requires AFF_68881, seeds OpenCnt=1; deferred-expunge semantics).
- Decoded the trans format: `[mant24|s+e7(bias64)]` ↔ IEEE single via EXPAND/PACK stubs.
- Mapped all 18 math vectors to their FPU ops (`fatan/sin/cos/tan/sinh/cosh/tanh/etox/logn/sqrt/asin/acos/log10/tentox/sincos`, pow via `logn+sglmul+etox`).
- Reconstructed in pure asm (`source/mathtrans.s`) — per-stub nop padding reproduced from fixed vector offsets.
- GNU ld emits RELOC32; original uses DREL16 (reverse order, word term) → added `source/drel16.py` post-link fixup.
- **Result: whole file byte-identical** — MD5 `95f979ff0a7ba13754c70c92ffc5da0e`.
- `work/oracle.py` (machine68k): init/open/close/expunge + SPTieee/SPFieee integer vectors — identical logs on both binaries. FPU ops not emulable; byte-identical code covers them.
