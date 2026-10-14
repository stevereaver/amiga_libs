# rexxapp vector map

jmp table at code+0x1e (14 entries, copied to lib-84..lib-6):

| LVO | target | role |
|-----|--------|------|
| -84,-78,-72 | code+0 | null stub (`moveq#0,d0;rts`) |
| -66 | 0x3dc | VecRetMsg: store d0/d1 -> msg+32/+36; argstring path via a0 |
| -60 | 0x278 | entry variant: a1=&_RetMsg(0x3b2) -> join main entry |
| -54 | 0x274 | entry variant: a1=NULL -> join main entry |
| -48 | 0x2a4 | main entry: build RexxMsg via rexxsyslib fns, PutMsg to "REXX" port |
| -42 | 0x164 | cleanup: drain+reply port msgs, FreeSignal, RemPort |
| -36 | 0x190 | dispatch: GetMsg pump + command-table scan + handler callout |
| -30 | 0x494 | port setup: a1=name, FindPort-uniquify (';'..':' suffixes), AddPort |
| -24 | code+0 | null |
| -18 | 0xd6 | Expunge |
| -12 | 0xc4 | Close |
| -6  | 0xb6 | Open |

Register convention: a5 = client context block (see
structures/layout.md).  Dispatch helpers reach Exec via the SysBase
stashed at code+0x98 — NOT via a6 (a6 doubles as a scratch callee
pointer inside the msg pump).
