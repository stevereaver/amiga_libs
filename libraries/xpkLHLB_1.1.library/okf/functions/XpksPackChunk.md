# XpksPackChunk (LVO -36)

Adapter: delegates packing to lh.library.

## State (xsp_Sub)

- `xsp_Sub[0]` (offset 0x34): lh control block, allocated lazily
  via `jsr -30(lhbase)` with d0=0 (pack mode).
- `xsp_Sub[1]` (offset 0x38): 0x9000-byte scratch buffer via
  `AllocMem(0x9000,0)`.

## Algorithm

1. If no control block yet: `lhAlloc(mode=0)` -> `xsp_Sub[0]`
   (NULL -> return -7), then `AllocMem(0x9000)` -> `xsp_Sub[1]`
   (NULL -> return -7).
2. Fill the lh block: `{InBuf, InLen, scratch, 0x8000}`.
3. `lhPack` (lh -42) -> return value `n`.
4. If `n == 0` or `n >= xsp_OutBufLen` -> return -17
   (XPKERR_EXPANSION).
5. `xsp_OutLen = n`; `CopyMem(scratch -> xsp_OutBuf, n)`;
   return 0.

## Quirks

- The `xsp_Sub[0]` NULL test is `cmpa.w #0,a2` -- a **16-bit**
  compare: a block pointer whose low word is 0 would be treated
  as missing and reallocated (harmless in practice on the Amiga's
  memory map, but a real quirk).
- The lh block's own buffer-length field is hardwired to 0x8000
  while the accept bound uses `xsp_OutBufLen` -- the scratch is
  0x9000 bytes, so an lh result in 0x8000..0x8fff would already
  have overflown the lh-visible bound only if lh honours it.
