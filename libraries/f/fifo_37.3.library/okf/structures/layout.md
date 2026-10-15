---
file: layout
---
# fifo 37.3 layout

File 3980B. 2 hunks: h0 CODE 0x257 longs (2652B @0x24),
h1 DATA 0xe longs (56B @0xea4).
Tail: RELOC32 — 7 ->h0, 10 ->h1, END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub |
| 0x04 | PACKED Resident: flags 0x00, ver 0(!), type 9; name->+0x1e id->+0x2b init->+0x50 |
| 0x50 | rt_Init: `movel a0,sp@-; bsr 0xe0` |
| 0x5a-0xc2 | vector thunks (moveml + bsr to handlers @0xe0/0x156/0x176/0x1b6/0x208/0x348/0x424/0x506/0x636/0x75e) |
| 0xe0 | real init (MakeLibrary via helper) |

## h1 (DATA)

Lib node area (+0..0xc) then functab@+0xc: 10 absolute longs
->h0 thunks (one literal-0 slot), `ffffffff` term.
