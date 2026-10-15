# cachefile.library — structure layouts

## Library base (0x76 = 118 bytes, InitTable dataSize)

| Off | Field |
|----:|-------|
| +0..35 | `struct Library` (node + header) |
| +36 | SysBase |
| +40 | DOSBase |
| +44 | seglist |
| +48 | SignalSemaphore (46 bytes, +48..+93) |
| +94 | `struct List` of cache nodes (12 bytes) |
| +106 | node count (ULONG) |
| +110 | daemon's MsgPort (CreateMsgPort) |
| +114..117 | pad |

Note: `+32` lib_OpenCnt (word) is also bumped by the daemon while it
processes a notification, blocking expunge mid-work; `+34` bit 3 is the
(dead) deferred-expunge flag.

## Cache node (588 bytes fixed + name + file data, one AllocVec)

| Off | Field |
|----:|-------|
| +0 | `struct Node` (succ/pred/type/pri/name) — ln_Name -> name buf |
| +14 | embedded `struct NotifyRequest` |
| +14 | nr_Name -> path buf (+318); cleared if StartNotify fails |
| +18 | nr_FullName = 0 |
| +22 | nr_UserData = the node itself |
| +26 | nr_Flags = 9 |
| +30 | nr_Port = daemon's MsgPort (+110) |
| +58..+317 | unused pad |
| +318 | 256-byte path buffer (NameFromFH output) |
| +576 | filesize (ULONG) |
| +580 | data pointer (even-aligned) |
| +584 | name string |
| +584+namelen+? | file contents, NUL padded at read length |

Alloc size = `filesize + 1 + (strlen(name)+1) + 588`,
`MEMF_PUBLIC|MEMF_CLEAR` (0x10001) via AllocVec.

## NotifyMessage fields the daemon uses

- `nm_NReq` @ +26 — points at the embedded NotifyRequest, so
  `msg->nm_NReq - 14` recovers the node.

## Code-hunk statics

| Hunk | Field |
|-----:|-------|
| +0xf0 | libbase copy for the daemon (absolute + pc-relative refs) |
| +0xf4 | daemon `ThisTask` handoff; cleared when daemon exits |

## CreateNewProc tags (hunk+0x176)

| Tag | Value |
|-----|-------|
| NP_Name (0x800003f4) | `"CacheFile_Notify"` |
| NP_Seglist (0x800003e9) | patched at init: BPTR(hunk+0x238) |
| NP_FreeSeglist (0x800003ea) | 0 |
| NP_StackSize (0x800003f3) | 0x1000 |
| TAG_DONE | 0 |

The seglist at hunk+0x238 is `[link=0][daemon code @ +0x23c]`; the
process runs the library's own code in place.
