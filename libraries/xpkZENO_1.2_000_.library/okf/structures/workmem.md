# xpkZENO 1.2 — workmem and descriptor

## Pack workmem (`xsp_Sub[0]` = alloc+4)

Allocation: `4 + 5*D3 + 8` bytes where `D3 = (1<<bits)+0x800`.

| offset      | contents                                   |
|-------------|--------------------------------------------|
| alloc+0     | allocation size (for PackFree)             |
| alloc+4     | stream hash long (copied to out[0..4])     |
| alloc+8     | `T_code u16[D3]` — slot -> dict code       |
| +8+2*D3     | `T_pref u16[D3]` — slot -> prevcode+1      |
| +8+4*D3     | `T_char u8[D3]` — slot -> extension byte   |

Mode-declared packmem: 0x7808 (12b), 0xc808 (13b), 0x16808 (14b)
= `5*(2^bits + 0x800) + 8` each.

## Unpack workmem

Allocation: `4 + 5*D3` (no hash store needed; 3*2^bits+4
rounded up as declared: 0x3004/0x6004/0xc004).  Same table
layout indexed by code.  `xsp_Sub` slots are shared with the
packer's positions in the XpkSubParams struct.

## XpkInfo descriptor (orig code+0x56a)

```
xi_XpkInfoVersion 1, xi_LibVersion 1, xi_MasterVersion 2,
xi_ModesVersion 0
xi_ID 'ZENO', xi_Flags 0xa009
xi_MaxPkInChunk 0x7fffffff, xi_MinPkInChunk 0,
xi_DefPkInChunk 0x8000, xi_DefMode 100
strings: "ZENO", "ZENO V1.2", "LZW 12-14 bit",
         "Compressing", "Expanding", "Compressed", "Expanded"
```

## Mode chain (stride 0x2a: 0x20 fields + 10-byte name field)

| xm_Next    | Upto | Flags | PackMem | UnpkMem | PkSp | UnpkSp | Ratio | name    |
|------------|------|-------|---------|---------|------|--------|-------|---------|
| ->mode13   | 33   | 1     | 0x7808  | 0x3004  | 70   | 155    | 301   | 12 bit  |
| ->mode14   | 66   | 1     | 0xc808  | 0x6004  | 74   | 155    | 329   | 13 bit  |
| 0          | 100  | 1     | 0x16808 | 0xc004  | 81   | 155    | 334   | 14 bit  |

Mode -> bits: `bits = (mode-1)/33 + 12`; mode 0 coerced to 1,
mode >99 clamped to 99.
