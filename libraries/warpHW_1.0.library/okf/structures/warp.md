# warpHW.library — structures

## Library base (dataSize 0x22)

Plain `struct Library` — no extra fields.  execbase and
seglist live in far-data globals (`wh_sys`,`wh_seg`).

## Driver descriptor (-30)

Opaque jump/desc table (LAB_0025): tag 0x25, size 0x3ef,
several longs and two `0xffffffff` sentinels.  Its exact
field meaning is PPC-kernel-internal.

## BlizzardPPC CSPPC registers ($00f6xxxx)

| addr      | written bytes (-48)      |
|-----------|--------------------------|
| 0xf60000  | 0x10, later 0x90         |
| 0xf60028  | 0x82, later 0x02         |
| 0xf60038  | 0xff, (and 0x01 by -54)  |
| 0xf60030  | 0x87, later 0x40         |
| 0xf60008  | 0xa8, later 0x10         |

Interleaved with `NOP;RTS` settle delays.
