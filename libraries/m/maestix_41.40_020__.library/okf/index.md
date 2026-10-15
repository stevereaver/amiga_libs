# maestix_41.40_020__.library

"maestix.library 41.40 (15.05.1999) 68020+" — Maestix MPEG
player control library. 6288B, flat CODE hunk 0x5fd,
DREL16 relocs (54 slots ->h0).

- Resident @h0+4 (flags 0x80, ver 41); InitTable@h0+0xfc:
  dsize 0x36, ftab@h0+0x10c (17 abs-long vectors ->h0),
  dtab@h0+0x154, initfn@h0+0x174.
- init calls exec -558 (FindTask/MsgPort alloc) + opens
  utility.library 36.
