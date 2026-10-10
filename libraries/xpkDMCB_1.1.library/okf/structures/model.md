# structures

## Model (2 MB workmem)
| region | size | contents |
|--------|------|----------|
| +0 | 1 MB | `float freq[state*2+bit]` — counts |
| +0x100000 | 1 MB | `long link[state*2+bit]` — transitions |

- states 0x0000..0xfffe: static graph, 256 rows × 255 nodes
- states 0x10000..0x1fffe: clone slots allocated by `m_free`
- `m_ctx` (a4): current state; `m_free` (a5): clone allocator

## Static graph init
row p = states p*256..p*256+254 (slot 255 of each row never written):
- c < 127: link = {rowbase+2c+1, rowbase+2c+2}
- c >= 127: link = {(c+1)<<8, (c-127)<<8}
- all freq = {1.0, 1.0}

## XpkSubParams (used fields)
+0 xsp_InBuf, +4 xsp_InLen, +8 xsp_OutBuf, +16 xsp_OutLen
