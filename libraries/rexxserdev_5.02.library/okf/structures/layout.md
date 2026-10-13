# rexxserdev.library 5.02 — structures

## Private library data (posSize = 0x42 = 66)

Built on a standard `struct Library` (34 bytes).  InitTable
`dataSize=0x42` ⇒ posSize 66 (LibBase offsets 34..99):

| off | field | contents |
|-----|-------|----------|
| +34 | SysBase | exec.library base (from a6 in initfn) |
| +38 | RexxSysBase | `OpenLibrary("rexxsyslib.library",0)` |
| +42 | UtilityBase | `OpenLibrary("utility.library",37)` |
| +46 | SegList | from a0 in initfn |
| +50 | ObjCount | long — open SerObj count |
| +54 | MinList(12) | head/tailpred list of SerObj |

initfn (code+0x68): stores SysBase/seg, opens the two imports
(either fail → returns 0), `NewList` on +54, returns lib base.
LibBase itself is passed in `d0` (hunk-loader convention).

## SerObj — per-handle device object (60 bytes)

| off | field | contents |
|-----|-------|----------|
| +0  | Succ | MinNode succ (manual linkage) |
| +4  | Pred | MinNode pred |
| +8  | SigTask | `io1`'s reply port mp_SigTask |
| +12 | Msg | current request block (set per call) |
| +16 | IO1 | read IOExtSer (82B, OpenDevice target) |
| +20 | Port1 | read MsgPort |
| +24 | IO2 | write IOExtSer (shares io1's dev/unit) |
| +28 | Port2 | write MsgPort |
| +32 | IO3 | ctrl IOExtSer (shares io1's dev/unit) |
| +36 | Port3 | ctrl MsgPort |
| +40 | Buf[20] | reply scratch (`"##ERROR="`, `"1 …"`) |

## IOExtSer block (82 bytes, AllocMem 0x10001)

Fields written by the library (offsets into the block):

| off | field | notes |
|-----|-------|-------|
| +8  | mn_Node.ln_Type | 5 |
| +14 | mn_ReplyPort | the channel's MsgPort |
| +18 | mn_Length | 82 (also the FreeMem size — see defects) |
| +20 | io_Device | set by OpenDevice / copied to io2,io3 |
| +24 | io_Unit | unit number / copied |
| +28 | io_Command | serial cmd code |
| +30 | io_Flags | 0 |
| +31 | io_Error | result |
| +32 | io_Actual | count / query field |
| +36 | io_Length | read/write count |
| +40 | io_Data | read/write buffer |
| +48 | io_CtlChar | 0x11130000 (xon/xoff/inq/ack) |
| +52 | io_RBufLen | arg7 or 1024 |
| +56 | io_ExtFlags | parity mark/space bits |
| +60 | io_Baud | baud rate |
| +64 | io_BrkTime | 250000 |
| +76 | io_ReadLen | data bits |
| +77 | io_WriteLen | data bits |
| +78 | io_StopBits | stop bits |
| +79 | io_SerFlags | 32 base + parity/xdisable bits |
| +80 | io_Status | query result (word) |

## Request block (ARexx message as seen by the dispatcher)

| off | field |
|-----|-------|
| +40 | function-name argstring (Stricmp'd) |
| +44 | arg0 — handle for idx<11 calls, devname for SerOpen |
| +48 | arg1 |
| +52 | arg2 |
| +56 | arg3 (SerSetParms parity char ptr) |
| +60 | arg4 (SerSetParms stop bits) |
| +64 | arg5 (SerSetParms xdisable char ptr) |
| +68 | arg6 (unused) |
| +72 | arg7 (SerSetParms rbuflen) |

## Reply conventions

- reply argstring in `a1`, error code in `d0`.
- `"1"` = success for void ops; `"0"` = failure.
- SerRead success → argstring wrapping `(io_Data, io_Actual)`;
  error → `"##ERROR=<io_Error>"` formatted by rxs-306.
- SerQuery → `"1 <io_Actual> <io_Status>"` (rxs-306 decimal).
- SerOpen → rxs-312(obj) handle token; SerLibBase → rxs-312(lib).
- dispatcher errors: unknown name → `d0=1`, missing handle →
  `d0=12`; SerOpen alloc → 3, OpenDevice fail → 12.
