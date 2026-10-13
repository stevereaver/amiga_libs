# rexxserdev.library 5.02 — vectors & ARexx API

## Library vectors

| LVO | Addr   | Entry | Behavior |
|-----|--------|-------|----------|
| -6  | +0xa8  | LibOpen | `opencnt@32++`, `bclr #3,flags@14`, return a6 |
| -12 | +0xb6  | LibClose | `opencnt--`; on 0 + DELEXP → fall into Expunge |
| -18 | +0xca  | LibExpunge | opencnt>0 → set DELEXP, ret 0; else Remove node, CloseLibrary ×2, FreeMem(lib-NegSize, Neg+Pos), ret seglist |
| -24 | +0x11a | null | `moveq #0,d0;rts` |
| -30 | +0x120 | dispatch | name-table scan + object resolve + call |

## Dispatcher (-30)

- `a0` = request block: `+40` name argstring, `+44` arg0
  (handle for object calls / devname for SerOpen), `+48..` args.
- Scan: `Stricmp(name, nametab[i])` for i=0..13; miss → `d0=1`.
- i<11: `a2 = rxs-300(msg+44)`; NULL arg → `d0=12`;
  `obj->msg = msg` (`a2+12`).
- Call `apitab[i]` with a2=obj, a5=lib, d4=msg.
- Return: callee leaves reply argstring in `a1`, error in `d0`.

## API table (index order — differs from string memory order)

| idx | Name       | Addr   | serial.device op | Reply |
|-----|------------|--------|------------------|-------|
| 0   | SerQuery   | +0x4b8 | io3, SDCMD_QUERY(9) | `1 <actual> <status>` / `0` |
| 1   | SerRead    | +0x3ba | io1, CMD_READ(2) | data argstring(io_Data,io_Actual) / `##ERROR=<err>` |
| 2   | SerWrite   | +0x45a | io2, CMD_WRITE(3) | `1`/`0` |
| 3   | SerSetParms| +0x534 | io3, SDCMD_SETPARAMS(11) | `1`/`0` |
| 4   | SerClear   | +0x350 | io3, CMD_CLEAR(5) | `1`/`0` |
| 5   | SerFlush   | +0x372 | io1|io2, CMD_FLUSH(8) | always `0` (defect) |
| 6   | SerReset   | +0x434 | io3, CMD_RESET(1) | `1`/`0` |
| 7   | SerBreak   | +0x49a | io3, SDCMD_BREAK(10) | `1`/`0` |
| 8   | SerStart   | +0x456 | none — stub | `0` |
| 9   | SerStop    | +0x456 | none — stub (same code) | `0` |
| 10  | SerClose   | +0x6c0 | teardown | `1` |
| 11  | SerOpen    | +0x636 | build obj+3 chans | handle argstring |
| 12  | SerLibBase | +0x626 | none | argstring(lib base) via rxs-312 |
| 13  | SerID      | +0x610 | none | argstring(idstr) |

### Argument slots (request block offsets)

- SerOpen: `+44` device name ptr, `+48` unit (via rxs-300)
- SerRead: `+48` buffer (rxs-300), `+52` length (rxs-300)
- SerWrite: `+48` data ptr (RAW, no resolve), `+52` len (rxs-300)
- SerSetParms: `+48` baud, `+52` rd+wr bits, `+56` parity char
  ('N'/'E'/'O'/'S'/other), `+60` stop bits, `+64` xdisable
  ('0' → SERF_XDISABLED), `+72` rbuflen (0/null → 1024)
- SerFlush: `+48` mode-arg ptr — reads byte at `arg+48`
- all handle calls: `+44` handle (rxs-300 → obj)

### SerOpen internals

Allocates 60-byte SerObj (AddHead to lib MinList@54), then three
channels — each `CreateMsgPort` + `AllocMem(82)` IOExtSer
(ln_Type=5, mn_Length=82, mn_ReplyPort=port):

1. io1/port1 (read): `io_SigTask = port->mp_SigTask`,
   `io_Command=0`, `io_SerFlags=32` (SERF_SHARED),
   `OpenDevice(devname, unit, io, 0)` — unit via rxs-300.
2. io2/port2 (write) and io3/port3 (ctrl): copy io_Device/io_Unit
   from io1 — all three share the opened serial unit.

Errors: alloc fail → 3, OpenDevice fail → 12 (free partials).
On success: `cnt@50++`, reply = rxs-312(obj) argstring.

### SerSetParms io fields

`io_Baud@60=arg1`, `io_ReadLen@76=io_WriteLen@77=arg2`,
`io_StopBits@78=arg4`, `io_ExtFlags@56=0` then parity bits,
`io_SerFlags@79=32|(E/O→1|2)`, `io_RBufLen@52=arg7||1024`,
`io_Command=11`, `io_Flags=0`, `io_CtlChar@48=0x11130000`,
`io_BrkTime@64=250000`.

Parity mapping: N→32, E→33, O→35, S→33+ExtFlags|2,
other→33+ExtFlags|3.  `+64` arg `'0'` → |=0x80 (XDISABLED).

## rexxsyslib internals used (undocumented)

| LVO  | Role |
|------|------|
| -126 | CreateArgstring(str:a0, len:d0) → argstring:a0 |
| -288 | string → length:d0 |
| -300 | argstring → long:d0 (arg/handle resolver) |
| -306 | long → decimal into a0, count:d0 (advances a0) |
| -312 | long → argstring:a0 (handle/ptr encoding) |

utility: -162 Stricmp.  exec: -198 AllocMem, -210 FreeMem,
-252 Remove, -414 CloseLibrary, -444 OpenDevice, -450 CloseDevice,
-456 DoIO, -552 OpenLibrary, -666 CreateMsgPort, -672 DeleteMsgPort.
