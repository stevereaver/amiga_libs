# algorithms

## stream (decoder @0xf6)
```
flag = *src++
if flag == 0: copy 8 bytes src->dst; repeat
for n = 7..0:
    bit = flag << 1 (msb out)
    if bit == 0: *dst++ = *src++
    else:
        t = *src++;  if t == 0: DONE
        len = (t & 15) + 2          /* 3..17 */
        off = ((t & 0xf0) << 4) | *src++
        copy len bytes from dst-off
repeat
```

## packer @0x1b2
- workmem: 4096 ctx x 16 longs, init -1
- seed: table[ctx(src0,src1)][0] = 0; buf = [flag,src0]; count=1
- per position: bottom = max(0,pos-4095); ctx(src[pos],src[pos+1])
  LRU scan (16), then exhaustive c-- scan to bottom; len cap 17;
  clamp len to remaining input
- len>2 -> token, flag bit set; else literal
- insert pos..pos+len-1 into ctx LRU
- flush flag block every 8 items; at EOF emit flag | nextbit plus
  payload plus 0x00 token (or 0xff00 for a full group)
