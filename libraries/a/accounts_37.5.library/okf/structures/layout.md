# accounts.library 37.5 — hunk & object layout

## File (2756 bytes)

```
0000 000003f3                 HUNK_HEADER
0004 00000000                 (no names)
0008 00000001                 tablesize=1
000c 00000000 00000000        first=0 last=0
0014 0000029c                 sizes: h0 = 0x29c longs = 2672B
0018 000003e9 0000029c        hunk0 CODE, body 2672B
0020 ...                      h0 body (file 0x20..0xa8f)
0a90 000003ec                 RELOC32
        8 -> hunk0: 0xa 0x6 0x12 0x16 0x1a 0x4c 0x50 0x54
        0  (end)
0ac0 000003f2                 HUNK_END
```

## hunk0 map (hunk-relative)

| off | content |
|-----|---------|
| 0x000 | `moveq #-1,d0;rts` — unreferenced stub |
| 0x004 | RomTag: 4afc; MatchTag→0x04; EndSkip→0xa70 (end of body); flags 0x80 AUTOINIT; ver 37; type 9 NT_LIBRARY; pri 0; name→0x1e; id→0x2f; init→0x48 |
| 0x01e | "accounts.library\0" |
| 0x02f | "accounts 37.5 (1.3.93)\r\n\0" |
| 0x048 | InitTable: dsize=0xf4 / ftab→0x58 / dtab→0x82 / initfn→0x88 |
| 0x058 | functab: `ffff` flag + 19 word offsets (rel. to 0x58) + `ffff` |
| 0x082 | datatab: `90 16 00 05` (INITWORD lib+0x16=5 → lib_Revision) + `00 00` term/pad |
| 0x088 | initfn: ExecBase/seglist stash, sema InitSemaphore, open dos+utility v37 |
| 0x0e6 | "nipc.library\0" |
| 0x0f3 | "utility.library\0" |
| 0x103 | "Accounts Server\0" |
| 0x113 | "dos.library\0" |
| 0x11f | "Envoy/AccountsServer\0" |
| 0x134 | `00 00 00 00` — empty taglist passed to nipc -126 |
| 0x138 | -6 Open |
| 0x1ec | -12 Close |
| 0x244 | -18 Expunge (defer check) |
| 0x254 | shared expunge body |
| 0x298 | -24 ret0 |
| 0x29c | -30 alloc 40B |
| 0x2b6 | -36 alloc 34B |
| 0x2d0 | -42 free 40B |
| 0x2ec | -48 free 34B |
| 0x308 | -66 'n' |
| 0x3a0 | -72 'p' |
| 0x42c | -78 'm' |
| 0x4bc | -84 'o' |
| 0x540 | -90 'j' |
| 0x5e0 | -96 'l' |
| 0x674 | -102 'k' |
| 0x736 | `0000` pad (4-align) |
| 0x738 | _requ_qu shared 'q'/'u' worker |
| 0x7de | -60 't' |
| 0x876 | -54 'q' wrapper |
| 0x89e | -114 'u' wrapper |
| 0x8c6 | -108 password hash |
| 0x992 | `0000` pad |
| 0x994 | _sendreq |
| 0xa26 | `0000` pad |
| 0xa28 | _mkobj (nipc -114 thunk) |
| 0xa3c | _sprintf (dead) |
| 0xa5e | _putch |
| 0xa62 | _strncpy |
| 0xa6e | `rts` (end = 0xa70 = EndSkip) |

## Library data (dsize = 0xf4; lib base offsets)

| off | field |
|-----|-------|
| 0x00..0x21 | exec `struct Library` (node fields filled by InitResident/RomTag machinery, lib_Revision=5 via datatab) |
| 0x22 (34) | NIPCBase |
| 0x26 (38) | ExecBase |
| 0x2a (42) | DOSBase |
| 0x2e (46) | UtilityBase |
| 0x32 (50) | seglist |
| 0x36 (54) | nipc context (nipc -126) |
| 0x3a (58) | nipc service entity (nipc -138) — "already open" flag |
| 0x3e (62) | SignalSemaphore (46B, InitSemaphore'd in initfn) |
| 0x6c (108) | magic `0xc0edbabe` |
| 0x70 (112) | GetVar result code |
| 0x74 (116) | GetVar buffer, 128B (host name for the Accounts Server) |

## Request object (created by nipc -114 with tag 0x800b1101=size)

| off | field |
|-----|-------|
| +0x0e (14)  | reply MsgPort (created per request) |
| +0x1c (28)  | command byte 'j','k','l','m','n','o','p','q','t','u' |
| +0x1e (30)  | result code — cleared pre-send, server fills |
| +0x2a (42)  | data block pointer |
| +0x2e (46)  | second pointer (copied to +0x3a on send) |
| +0x32 (50)  | message length: 40 (0x28), 72 (0x48) or 112 (0x70) |
| +0x36 (54)  | copy of +42 (set in _sendreq) |
| +0x3a (58)  | copy of +46 (set in _sendreq) |
| +0x42 (66)  | word 5 (set in _sendreq — transaction/opcode?) |

## Request data block (the marshalled RPC payload)

- +0  : 32-byte string (1st arg: name / account record name)
- +32 : word field (arg+32, e.g. uid/flags)
- +40 : 32-byte string (2nd arg; only in the 112-byte requests 'k','t')
- +64 : word; +66 word; +68 long  (reply/aux fields, 72/112-byte requests)
- +104: word; +106 word; +108 long (reply fields, 112-byte requests)

Strings copied with a bounded strncpy (≤32, forced NUL). Reply copy-out
runs only when obj+30 == 0; the vector result is always obj+30
(501 on local object-alloc failure).
