# xpkBZIP — pack/unpack flow

## Level → mode mapping

    mode = (9 + level) / 10   (divu.l — unsigned 32-bit)
    if (mode == 0) mode = 1;

level 0..10 → 1, 11..20 → 2, …, 91..100 → 10.  Levels >100
produce mode >10 → error -12.  `level` is read from
xsp[28] — the xpk 0-100 quality scale; each unit of mode
selects a block size of `mode * 102400` bytes (mode 10 =
1024000 = xi_MaxPkInChunk).

## Output framing

Pack writes `out[0] = mode` and hands `out+1` to the PPC
side, so one header byte per chunk.  Unpack reads the byte
back from `src[0]` and feeds `src+1` to the decompressor.

## PPC frames (11 longs, stack-built)

Pack  `{1, mode, src, dst+1, inlen, outsize, b52, b56, b60, 0, 0}`
Unpack`{0, mode, src+1, dst, inlen, outsize, b52, 0, 0, b56, b60}`

frame[0] is the PPC function index (1 = compress, 0 =
decompress).  Note the asymmetric buffer placement —
unpack inserts two zero slots before b56/b60.

## Work buffers (lazy)

Allocated via ppc -60 only when ALL THREE slots are zero —
a partially-initialised set is used as-is (quirk).  Pack:
b52 = 4·block, b56 = 4·block, b60 = 0x40004.  Unpack:
b52 = 4·block, b56 = block, b60 = block.
Alloc arg2 is always `d1=1` (PowerUP memory flag).

## Error map

| code | cause                                    |
|------|------------------------------------------|
| 0    | success (pack also stores outlen→xsp[16]) |
| -4   | unpack: ppc result != outbufsize          |
| -5   | unpack: ppc returned -2                    |
| -7   | work-buffer alloc failure                  |
| -12  | mode/level out of range                    |
| -17  | unpack: ppc returned -1                    |
| -33  | LoadObject(elf) failed                     |

## Dead code / tricks

- `cmpi.w #0x7000,d0` at LibClose tail and Unpack tail is
  dead — its operand `0x7000` doubles as `moveq #0,d0` for
  the success/zero branch targets (mid-instruction jump).
- `tstw opencnt` in expunge, `bset` DELEXP — standard.
- Lib data +34=seglist +38=SysBase +42=ppcbase; data-hunk
  mirrors: +60=lib +120=SysBase +124=ppcbase.
