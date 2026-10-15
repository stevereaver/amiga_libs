# functions/vectors

## LibInit
Checks `AttnFlags` bit1 (68020) + bit4 (68881); returns 0 if either missing → the library cannot even open without an FPU. Stores seglist at base+34.

## LibOpen/-12/-18
openCnt@32, DELEXP byte at base+38 (`andib #-9`/`orib #8`), Remove+FreeMem expunge returning seglist@34.

## XpksPackerInfo @-30
`lea` of the static descriptor at hunk 0x4b2, returned in d0/a0.

## XpksPackChunk @-36 `(xsp@a0)`
AllocMem 2 MB workmem (-7 on fail); model_init; writes 4-byte unpacked-length header; arith-codes `xsp_InLen` bytes bit-by-bit MSB-first; bound = dst+inlen+40, emits byte *then* checks (`-17` on overflow — one byte can be written past the bound). Emits 3-byte `lo` flush; writes `xsp_OutLen@16`; frees workmem; returns 0.

## XpksUnpackChunk @-54 `(xsp@a0)`
Same workmem/model; reads unpacked len + 3-byte code from the stream head; produces `len` bytes, one bit at a time under the model; **no bounds checks on input or output**; returns 0 (-7 on alloc fail).

## Range update (shared)
`split = round((hi-lo-1) * P0) + lo` — `fmovel` semantics = round-to-nearest, **not** truncation; clamped to `lo < split < hi-1`; `if (bit) lo=split else hi=split`; renorm when `hi-lo < 256` (24-bit range, byte at a time; `hi -= bit` quirk during renorm; `if (lo>=hi) hi = 0x1000000`).
