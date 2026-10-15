---
file: layout
---
# cdplayer 1.0 layout

File 3964B. 3 hunks: h0 CODE 0x369 longs (3492B @0x28), h1 DATA
0x1f longs (124B @0xe1c), h2 CODE 0x19 longs (100B @0xec4).

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub |
| 0x04 | PACKED Resident: matchtag@+4, flags 0x80 AUTOINIT, ver 37(!), type 9; name@+0x12->h2+0x44 ('cdplayer.library'), id@+0x16->h2+0x58 ('Version 1.0'), init@+0x1a->h1+4 |

## h1 (DATA)

InitTable@+4: dsize 0x104, functab->h2+0 (stored 0, relocated),
datatab=0, initfn->h0+0x20.

## h2 (CODE)

functab @+0: 16 absolute longs (h0-relative, relocated) + `ffffffff`;
then 'cdplayer.library' and 'Version 1.0' strings.
