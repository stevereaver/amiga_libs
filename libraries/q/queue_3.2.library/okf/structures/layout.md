# queue.library 3.2 — layout

## Hunks

| # | type | body | contents |
|---|------|------|----------|
| 0 | CODE | 0x9ac B (0x26b L) | stub+RomTag, initfn, all code, NewList helper, `0000` tail pad |
| 1 | DATA | 0x20 B (8 L)   | `[0]=0`, then InitTable at +4: `{dsize=0x8c, ftab->h2+0, dtab=0, initfn->h0+0x20}`, then 3 zero longs. initfn copies all 8 longs to lib+48. |
| 2 | CODE | 0x5c B (0x17 L)| 13-long absolute functab, `ffffffff` term, `"queue.library\0"` @+0x38, `0000` pad, `"queue.library 3.2\0"` @+0x48, trailing `6164` ("ad") @+0x5a. |

RELOC32 groups:
- h0 -> h0 {0xa,0x6} (matchtag/endskip), -> h1 {0x86,0x74,0x1a}
  (rt_Init + the two `lea _qdata`), -> h2 {0x5a,0x34,0x16,0x12}
  (rt_Name/rt_IdString + initfn's `movel #_qname`/`#_qidstr`).
- h1 -> h0 {0x10} (initfn), -> h2 {0x8} (functab).
- h2 -> h0 {0x30..0x0 descending} (13 functab entries).

## Library (dsize 0x8c = 140)

| off | field |
|-----|-------|
| 34  | seglist (returned by Expunge) |
| 48  | ctx: bytes copied from h1 — `+0`=0, `+4`=0x8c, `+8`=&functab, `+12`=0, `+16`=&initfn, `+20`=SysBase (set by _initctx), `+24`=lib, `+32`=exec list lock semaphore (lib+80), `+78`=queue-name MinList (lib+126) |

## Queue hdr (96 B, a2 in the code) — per unique name

| off | field |
|-----|-------|
| 0..7 | MinNode links (in lib namelist) |
| 10   | name string (strdup'd) |
| 14   | MinList: pending item chain |
| 24   | current/head node ptr (RemHead target for type-2) |
| 28   | open/attach count (dup CreateQueue ++, DeleteQueue --) |
| 32   | waiter count |
| 36   | MinList: client nodes attached to this queue |
| 50   | per-queue semaphore |

## Client node (42 B, a3/a5 in the code)

| off | field |
|-----|-------|
| 0..7 | MinNode links |
| 8    | type word (CreateQueue d0; 1 = signalling, 2 = RemHead-queue) |
| 10   | wait counter |
| 12   | occupy counter + parent hdr ptr @16 context |
| 14   | embedded MinNode used for hdr+14 item chain (sub-list) |
| 16   | signal mask (1 << CreateQueue d1) |
| 20   | owning task (FindTask(0)) |
| 24   | MinList (own sub-queue) when type != 1 |
| 28   | rechain link (MinNode) |
| 36   | set to 10 for type-1 nodes |
| 38   | pending-items counter (client side) |

## Item (24 B, -72)

| off | field |
|-----|-------|
| 0..7 | MinNode links |
| 8    | type (=1 once enqueued) |
| 10   | counter |
| 12   | counter |
| 16   | owning client node |
| 20   | payload block (-72 d0 bytes, -78 frees it) |
