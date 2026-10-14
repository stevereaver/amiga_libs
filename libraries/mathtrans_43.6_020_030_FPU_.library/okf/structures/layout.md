# Layout — mathtrans_43.6(020_030_FPU).library

## File
```
0x0000  hunk header (1 hunk, table size 0x25f lw)
0x0020  CODE hunk header (0x3e9, 0x25d lw = 0x974 B)
0x0028  code body (0x974 B)
0x099c  DREL16 (0x3f7): 10 word offsets into CODE, reverse order, term 0x0000, pad
0x09b4  END (0x3f2)
```

## Code body map
```
+0x000  moveq #0,d0; rts            (null vector target)
+0x004  RomTag: MatchTag=+4, EndSkip=+0x972, RTF_AUTOINIT, v43, NT_LIBRARY
+0x01e  "mathtrans.library\0"
+0x030  " mathtrans.library_6888x_version 43.6 (8.4.2001) © 1997-2001 Jess Sosnoski \0"
+0x07c  InitTable: dsz=0x30, functab=+0x8c, datatab=+0xbc, initfn=+0xdc
+0x08c  functab (22 word offsets, -1 markers)
+0x0bc  datatab: InitStruct byte-form (type/name/flags=6/ver=43/rev=6/idstr)
+0x0dc  Init   (0x24 B)
+0x100  Open   (0x10 B)
+0x110  Close  (0x14 B)
+0x124  Expunge(0x44 B)
+0x168  SPPow  (0x8c B, two-arg expand + 3-op FPU sequence)
+0x1f4.. stubs every 0x78: atan sin cos tan [SPTieee@0x3d4, 0x10 B] sinh
        cosh tanh exp log sqrt asin acos log10
+0x81c  SPSinCos (0x80 B)
+0x89c  SPTenX   (0x78 B)
+0x914  SPFieee  (0x5e B) — pack routine, also bsr'd by SPSinCos
+0x972  trailing pad nop (rt_EndSkip points here)
+0x974  end
```

## Library data area (dataSize = 0x30, base+0..47)
| Off | Use |
|-----|-----|
| +0x20 | OpenCnt (seeded **1** at init!) |
| +0x22 | seglist (long, stored by initfn) |
| +0x26 | SysBase (long, stored by initfn) |
| +0x2a | lib byte containing LIBF_DELEXP (bit 3) — actually within pos-size region usage |

## Trans numeric format
32-bit packed: `[ mantissa:24 | sign:1 | exponent:7 (bias 64) ]`.
- `0x80000041` = 1.0, `0x800000c1` = -1.0 (high bit of low byte = sign).
- EXPAND maps it to IEEE single: `mant<<8` becomes IEEE mantissa high bits, exponent rebased 64→127.
- PACK reverses it; overflow → `0x7fffffff` + CCR bit set.
