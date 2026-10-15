# XpksUnpackChunk (LVO -54)

Adapter: delegates unpacking to lh.library.

## Algorithm

1. If `xsp_Sub[0]` is NULL: clear `xsp_Sub[1]` first, then
   `lhAlloc(mode=1)` (unpack mode) -> `xsp_Sub[0]`; NULL ->
   return -7.
2. Fill the lh block `{InBuf, InLen, OutBuf, OutBufLen}`.
3. `lhUnpack` (lh -48); return value stored to `xsp_OutLen`.
4. Return -14 when the lh call came back with CCR Z set, else 0.

## Quirk

The error test is `seq d0 / extw / extl / andl #-14` -- it reads
the **condition codes left by the lh routine**, not the d0 return
value.  In practice lh 1.x returns with Z reflecting its result
status, so this is equivalent to `ret == 0 -> -14`; the
reconstruction tests `ret` directly (documented delta).

Also uses the same 16-bit `cmpa.w` NULL check on `xsp_Sub[0]` as
the packer.
