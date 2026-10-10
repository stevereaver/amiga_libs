---
type: Structure
title: xpkILZR params & workmem
---

# XpkSubParams

Standard XPK sublibrary argument block; the fields the
codec touches:

| off | field | use |
|-----|-------|-----|
| 0x00 | xsp_InBuf | input data |
| 0x04 | xsp_InLen | input length |
| 0x08 | xsp_OutBuf | output buffer |
| 0x0c | xsp_OutBufLen | (unused — bound is out+inlen) |
| 0x10 | xsp_OutLen | pack: written; unpack: PRESET bound for -14 |
| 0x1c | xsp_Mode | ignored (single-mode sublib) |
| 0x34 | xsp_Sub[0] | workmem pointer (lazy) |

# Workmem layout (0x18004 alloc, size-prefixed)

```
block+0   size long      0x18004   (written by AllocMem caller)
block+4 = xsp_Sub[0]
  +0x00000  head[0x8000]   u16  hash heads (positions, 0=empty)
  +0x10000  chain[0x4000]  u16  next-links  <- only 16K entries!
  +0x18000  end
```

head[] is 0x8000 words (64KB); chain[] only 0x4000 words
(16KB) — positions are capped at 0x3fff, which is exactly
why MaxPkInChunk=0x4000.  For InLen>0x4000 the insert loop
writes chain[pos] past the block (latent overflow).
