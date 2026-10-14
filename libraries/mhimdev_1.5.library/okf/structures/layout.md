# mhimdev 1.5 — structures and layout

## File layout

- HUNK_HEADER → 1 hunk → HUNK_CODE (0x25b longs = 2412 B body @ file 0x20)
  → RELOC32 (36 same-hunk offsets) → HUNK_END.

## RomTag (@hunk+0x0a)

| field    | value |
|----------|-------|
| matchtag | hunk+0x0a |
| endskip  | hunk+0x158 (InitTable) |
| flags    | 0x80 (RTF_AUTOINIT) |
| version  | 1 |
| type     | 9 (NT_LIBRARY) |
| pri      | 0 |
| name     | →hunk+0x45 `"mhimdev.library"` |
| idstr    | →hunk+0x24 `"mhimdev.library 1.5 (04.03.2023)"` |
| init     | →hunk+0x158 (InitTable) |

## InitTable (@hunk+0x158)

`[dataSize=0x2a][funcTab→0xfc][dataTab→0x138][initFn→0xe6]`

## datatab (@hunk+0x138) — embedded-offset InitStruct form

nibble map: `8`=long, `9`=word, `a`=byte (high byte of the data word),
`0`=end.

| cmd    | target   | data | field |
|--------|----------|------|-------|
| `a008` | lib+8    | 0x09 | ln_Type = NT_LIBRARY |
| `800a` | lib+10   | →0x45| ln_Name |
| `a00e` | lib+14   | 0x06 | lib_Flags = SUMUSED\|CHANGED |
| `9014` | lib+20   | 1    | lib_Version = 1 |
| `9016` | lib+22   | 5    | lib_Revision = 5 |
| `8018` | lib+24   | →0x24| lib_IdString |
| `0000` | —        | —    | end (+2 B pad) |

## Library node (0x2a = 42 B positive)

| off | field |
|-----|-------|
| 0-33 | struct Library (per datatab + MakeLibrary negsz/possz) |
| 34  | seglist (written by initfn) |
| 38  | ExecBase (written by initfn; all API vectors reload it into a2/a3/a4/a6) |

## Driver handle (348 B, AllocVec CLEAR|PUBLIC) — vec -30 result

| off  | field |
|------|-------|
| 0    | unit byte — parsed as `unitstr[3]` (see quirks) |
| 1    | device-name buffer (255 B copied blindly from DEVICE arg) |
| 257  | state byte: 1 = stopped/idle, 0 = playing, 3 = paused |
| 258  | port1 (MsgPort, PA_SOFTINT) |
| 262  | port2 (MsgPort) — reply port for ioreq1 control cmds |
| 266  | ioreq1 (CreateIORequest(port2,86)) — template + control cmds |
| 270  | freelist (struct List, NewList'd at open) — pool of spare 86 B ioreqs |
| 284  | donelist (struct List) — replied write ioreqs land here via softint |
| 298  | caller task (from AllocDriver a0) — Signalled by softint |
| 302  | caller signal mask (from AllocDriver d0) |
| 306  | embedded Interrupt node (22 B) used as port1.mp_SigTask |
| 320  | intr.is_Data = handle |
| 324  | intr.is_Code = _sofint (hunk+0x860) |
| 328  | pending — in-flight write count (++/softint--) |
| 332  | volume (default 100, clamp ≤100) |
| 336  | balance (default 50, clamp ≤100) |
| 340  | ioreq2 (AllocMem 86) — async cmd-9 request sent by Start(-60) |
| 344  | sysbase |

## IORequest usage (86 B; io fields beyond standard header)

| off | field |
|-----|-------|
| 14  | mn_ReplyPort |
| 28  | io_Command (w): 1=RESET @open, 3=CMD_WRITE queued bufs, 8=FLUSH @stop, 9=ioreq2 async (Start), 10=pause toggle, 20=volume |
| 30  | io_Flags (b) = 0 |
| 36  | io_Length |
| 40  | io_Data |
| 51  | byte = 2 (set by _sendcmd and open path) |
| 52  | long = 0 (QueueBuffer) |
| 56  | long pause flag (Pause toggle writes 1/0 before cmd 10) |

## Strings

| off   | text |
|-------|------|
| 0x24  | `mhimdev.library 1.5 (04.03.2023)` |
| 0x45  | `mhimdev.library` |
| 0x168 | `dos.library` |
| 0x174 | `MHIMDEV` (env var read by AllocDriver) |
| 0x17c | `DEVICE,UNIT/N` (ReadArgs template) |
| 0x696 | `MHI driver for mpeg.device` |
| 0x6b1 | `mhimdev.library 1.5 (04.03.2023)` |
| 0x6d2 | `Michael Henke` |
