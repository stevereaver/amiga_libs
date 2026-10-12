# Structures — xpkMASH 1.16

## XpkSubParams (as read by Pack/Unpack; a0 on entry)

| off | size | field | use |
|-----|------|-------|-----|
| 0x00 | 4 | xsp_InBuf | source |
| 0x04 | 4 | xsp_InLen | source length |
| 0x08 | 4 | xsp_OutBuf | dest |
| 0x10 | 4 | xsp_OutLen | written: packed size |
| 0x1c | 4 | xsp_Mode | `tries = 1 << (mode/10)` |
| 0x3c | 4 | xsp_Bound | overwritten: `outbuf + inlen - 50` |
| 0x40 | 4 | xsp_Tries | overwritten: `1 << (mode/10)` |

## Library data (dataSize 0x4a)

Std Library node + `exec@+34`, `seglist@+38`.

## Work allocations (`Sub[]` at libbase+dataSize, per PackChunk)

| slot | size | contents |
|------|------|----------|
| Sub+0 `alloc1` | always 0x10000 | chain ring: base `alloc1+0x8000`, element `sext16(pw)*2` — pointer-low-words <0x8000 use the upper 32KB, >=0x8000 wrap into the lower 32KB |
| Sub+1 `alloc2` | `512<<shift`, shift 8→1 (0x20000→0x800, halved on AllocMem failure) | hash head table of `256<<shift` UWORDs; hash index `((b1<<shift)&0xff00) | b0` |

Init: `filldown(end, blocks, val)` writes `blocks`×256 bytes downward
— alloc1 gets 0x101 blocks of 0xffff (clears all 64KB + underwrites
0x100 bytes), alloc2 gets `(size>>8)+1` blocks seeded with `in.w`
(chain seeds point at the input — "self-referential" start positions).

## Token format (decoder's view)

```
while out < outend:
  bit 0 -> no literals;  bit 1 -> literal-run code:
     0|10|110|1110|11110 -> run 1|2|3|4|5
     11111 + unary class w + (w+1)-bit excess
        -> run = rclass[w].base + excess + 6  (6,8,14,30,...,65534)
     copy `run` raw bytes
  (always) match token:
     len 2: `00` + 9-bit distance direct      <-- see defects
     len 3: `01` + 3-bit dist class + payload
     len>=4: `1` + unary w + lclass[w].bits excess
             -> len = lclass[w].base + excess + 2  (classes base
                2,4,8,16,32,64,128,256,512,1024, bits 1..10)
             + 3-bit dist class + payload
  dist classes (3-bit code c, then payload, then + base):
     c=0 5b base 0      | c=4 11b base 0x6a0
     c=1 7b base 0x20   | c=5 12b base 0xea0
     c=2 9b base 0xa0   | c=6 13b base 0x1ea0
     c=3 10b base 0x2a0 | c=7 14b base 0x3ea0 (max 0x7e9f)
     copy `len` bytes from out-dist
```

Emitter side: `emit_dist` field = `class<< (bits-3) | (dist - base)`,
emitted MSB-first — the 3-bit class heads the field.  `emit_len`
codes: `00`(2) `01`(3) `100/101`(4/5) `11000..11011`(6..9)
`1110xxx`(10..17) then unary-extended.  The len-2 path bypasses
`emit_dist` entirely: it emits `d3<<5` (11 bits = `dist[10:0]`) —
distances >= 0x200 set the top bits and corrupt the `00` prefix.

Bit order MSB-first per byte; the emitter reserves a byte slot for the
in-progress code byte while literal bytes flow through the same output
pointer (the "2 mixed streams").

## Descriptor (XpkInfo, returned by -30)

`{1, 1, 2, 0}` + Name `"Mashiner"`, LongName `"MASH V1.16, another
LZ77-family"`, Desc `"WindowSize: 32KB, 2 mixed streams  Dynamic
Buffer Allocation,  Nice CF"`, ID `'MASH'`, Flags 0x8009,
MaxPkInChunk 0x000f0000-ish, MinPkInChunk 0x50, DefPkInChunk 0x10000,
msgs Mashing/UnMashing/Mashed/UnMashed, DefMode 100, one mode record
`{0,100, 0,0,0, pspeed 18, uspeed 300, ratio 480, " -->    "}`.
