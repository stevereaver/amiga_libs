# rexxapp.library "(dissidents Jan 91)"

ARexx application-host interface library ("dissidents Jan 91" release).
1,568-byte old-style **non-AUTOINIT** library; the library node is carved
statically out of the code hunk (base = hunk+0x72) and registered via
`AddLibrary` from the resident-tag init routine.

Shipped twice in this tree under `RexxApp_Jan_91_.library/` and
`rexxapp__Jan_91_.library/` — the two binaries are byte-identical
(md5 `1724406df58c813c7db58aef2ff35320`).

## Vectors (14 x `jmp abs`)
| LVO | Function |
|-----|----------|
| -6/-12/-18 | LibOpen / LibClose / LibExpunge (asm, standard) |
| -24/-72/-78/-84 | `jmp hunk+0` nulls (stub rts) |
| -30 | `RAX_Setup(a1=name)` — claim unique port name (digit-suffix retry), AllocSignal, AddPort; returns waitmask |
| -36 | `RAX_Dispatch` — drain embedded port; replies→result cbs, incoming→verb match/forward |
| -42 | `RAX_Cleanup` — flag shutdown, drain pending, RemPort + FreeSignal |
| -48 | `RAX_SendEx` — full-param send: a0=cmd, a1=cb, a2=orig, d0=action, d1=validator |
| -54 | `RAX_SendCommand` — send with cb=0, action=RXCOMM |
| -60 | `RAX_SendForward` — send with cb=fwd_reply, action=RXCOMM |
| -66 | `RAX_SetResult` — store r1/r2 on a msg; optional CreateArgstring result |

## Context ABI
The application context pointer is carried in **register A5** by the
caller; the library never initialises it.  Context embeds a `MsgPort`
at +0 (SigBit bit7 doubles as the "initialising" mark), cmd table at +62.

## Layout
- `7000 4e75` stub, packed RomTag at hunk+4 (no AUTOINIT flag)
- jmp table hunk+0x1e (14 entries), node/base hunk+0x72, init hunk+0x9c
- resident id string pointer lands mid-string: `(dissidents Jan 91)
  rexxapp.library` at hunk+0x586 with the id field pointing at `dissidents…`
- second hunk is empty (HUNK_CODE size 0 — toolchain artifact)
- 21 abs-32 relocs: RomTag fields, all 14 jmp operands (incl. the null
  vectors → hunk+0), node name/idstr

## Dependencies
- `exec.library` — ports, signals, TDNestCnt manual Forbid
- `rexxsyslib.library` — opened lazily on first send; CreateRexxMsg -144,
  DeleteRexxMsg -150, CreateArgstring -126, DeleteArgstring -132, private -96
- `REXX` public port — looked up under Forbid each send

## Rebuild
`source/` holds `rexxapp.c` + `rexxapp_lib.s` (vector table/lifecycle —
kept local per repo policy); `make` needs m68k-amigaos-gcc.
