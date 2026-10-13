# xpkZENO 1.1 — workmem, descriptor, stream

## Pack workmem

`Sub[0]` = alloc base (NOT alloc+4 like 1.2 — there is no size
prefix; free size is recomputed from bits).

Allocation: `7*D3+8` bytes, `D3 = (1<<bits)+0x800`,
MEMF_CLEAR|MEMF_PUBLIC.

| offset       | contents                                   |
|--------------|--------------------------------------------|
| alloc+0      | u32 stream hash (copied to out[0..4])      |
| alloc+4      | `T_code u16[D3]`  — slot -> dict code      |
| alloc+4+2*D3 | `T_pref u16[D3]`  — slot -> prevcode+1     |
| alloc+4+4*D3 | DEAD GAP (2*D3+4 bytes, never touched)     |
| alloc+8+6*D3 | `T_char u8[D3]`   — slot -> extension byte |

Mode-declared packmem: 30/50/90 "units" for 12/13/14-bit.

## Unpack workmem

`Sub[0]` = alloc base.  Allocation: `4*Tsize+8`, MEMF_CLEAR.

| offset         | contents                                 |
|----------------|------------------------------------------|
| alloc+0        | u32 stored pwhash result (dead)          |
| alloc+4        | `T_prev u16[Tsize]`                      |
| alloc+4+2*Tsize| `T_char u8[Tsize]` (identity-init 0..255)|

`Sub[1]` = T_char base; `Sub[2]` = Tsize; `Sub[3].b` = bits.

Mode-declared unpackmem: 12/24/48 "units".

## XpkInfo descriptor (orig code+0x162, 88 bytes)

```
xi_Version 1, xi_LibVersion 0, xi_MasterVersion 0,
xi_ModesVersion 0
xi_Name "ZENO", xi_LongName "Zeno 1.1",
xi_Description "LZ78 12-14bit"
xi_ID 'ZENO', xi_Flags 0xa009
xi_MaxPkInChunk 0x7fffffff, xi_MinPkInChunk 0x80,
xi_DefPkInChunk 0x8000
msgs "compressing"/"expanding"/"compressed"/"expanded"
xi_DefMode 50, xi_ModeDesc -> "12 bit" record
```

Note: the packer's short-input gate reads `pc@(0x182)` —
i.e. xi_MinPkInChunk — as its 128 constant.

## Mode records

Linked list `[next, upto, flags, packmem, unpackmem,
packspeed, unpackspeed, ratio(u16)+pad(u16), name(10)]` —
42 bytes, 32-byte fixed part:

| name    | next     | upto | fl | pm | um | spd | ratio |
|---------|----------|------|----|----|----|-----|-------|
| "12 bit"| ->"13 b" | 33   | 6  | 30 | 12 |140/240|0x140|
| "13 bit"| ->"14 b" | 66   | 6  | 50 | 24 |140/240|0x140|
| "14 bit"| NULL     | 100  | 6  | 90 | 48 |140/240|0x140|

DEAD record at 0xbc: "15 bit", upto 100, flags 6, pm 170,
um 96 — the OLD 30-byte format (no chunk pad word), 40 bytes
total.  NOTHING links to it — leftover from a dropped 15-bit
mode (the modulus table also keeps a 15-bit slot, 0x87f7).

## Stream header

```
u32 hash     pwhash(password) or 0
u8  bits     12/13/14
u8  namelen  3-((out+5)&3) -- pad count so data is long-aligned
u8  pad[namelen]   SKIPPED, stale outbuf content
...          MSB-first LZW codes in u32 longs
```

Codes: literals = raw bytes; 0x100 = EOI; 0x101 = dict reset;
dict codes emitted as `entry-1`, stored entries start at
nextcode 0x104 (pack) / 0x103 (decoder initial) / 0x102
(after reset — one dead slot).

## xsp_Sub usage

| slot | pack                       | unpack                 |
|------|----------------------------|------------------------|
| Sub[0] | alloc base               | alloc base             |
| Sub[1] | T_pref = alloc+4+2*D3    | T_char = alloc+4+2*T   |
| Sub[2] | T_char = alloc+8+6*D3    | Tsize                  |
| Sub[3].b | bits                   | bits                   |
