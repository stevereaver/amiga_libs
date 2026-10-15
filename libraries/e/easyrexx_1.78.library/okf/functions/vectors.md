# easyrexx.library 1.78 — vector map

Functab at h0+0x9d4 (17 absolute longs + 0xffffffff).  Standard
a6=lib base convention unless noted.

| LVO | Name (recovered) | Entry | Behaviour |
|-----|------------------|-------|-----------|
| -6  | Open             | 0xc4  | opencnt@0x20++, clear bit3 of flags@0xe, return a6 |
| -12 | Close            | 0xd6  | opencnt--; if 0 and bit3 set -> Expunge |
| -18 | Expunge          | 0x100 | set bit3; if cnt==0: _closelibs + Remove + FreeMem(lib-negsize, dsize+negsize); return seglist |
| -24 | reserved         | 0x0   | h0+0 stub `moveq #0; rts` |
| -30 | strlen (exp)     | 0x158 | d0 = strlen(a0), NULL->0 |
| -36 | strcpy (exp)     | 0x1da | copies a1->a0, returns end ptr; NULL src -> 0 |
| -42 | strdup (exp)     | 0x1f2 | strlen+1 AllocVec + CopyMem -> copy|0 |
| -48 | strchr (exp)     | 0x23c | find byte d0 in a0 -> ptr|0 |
| -54 | _v54 key lookup  | 0x6e8 | scan 16B-entry table {key@0, name@4}: stricmp (utility -0xa2) vs a1 -> key@0, else -30.  **Needs a4 = lib+0x30** (reads a4@0x1c utility base uninitialised) |
| -60 | _v60 word copy   | 0x726 | copies a1->a0 until space/NUL (dual-entry via mid-insn label) |
| -66 | _v66 arg init    | 0x772 | key@0x1e -> _v72 lookup in list@4; memset argbuf@0x12 (32B), store buf@8+arg to arg0 slot, dos -0x31e; set bit0 @0x1d.  **Needs a4 = lib+0x30** (dos base at a4@0x20) |
| -72 | _v72 entry lookup| 0x74e | scan {key@0, link@4, val@8}: a0@==d0 -> val@8, else 0 |
| -78 | _v78 DestroyHost | 0x380 | if bit1@0x1d: Forbid, drain port GetMsg -> ReplyMsg loop, RemPort, Permit, DeleteMsgPort, FreeVec(name@0xc); dos -0xea(obj@0x12) if present; FreeVec(host) |
| -84 | _v84 CreateHost  | 0x416 | taglist a0: 0x80000001=name, 0x80000002=argstruct (name str @+8, commas counted), 0x80000004=port override (clears create flag); alloc (d7*4+0x22) struct; unique 'EASYREXX'/name `.%ld` FindPort retry; strdup name @0xc; CreateMsgPort @0, port->ln_Pri=1, AddPort, bit1@0x1d; path @4, nargs @0x10, dos -0xe4(d1=5,d2=0) -> obj @0x12.  Returns host, or 0 only if BOTH port and dos-obj failed |
| -90 | _v90 inbound     | 0x8a0 | a0=host: GetMsg(host->port) -> @0x16; require (msg@0x1c & 0xff000000)==0x01000000; AllocVec(strlen(arg@0x28)+3) -> @8; _tagtmpl copy; strcpy arg into buf; _v60 trim; sprintf('%s%s', buf, "\n") appends newline (the `0x0a00` word); _v54(table@4,buf) -> @0x1e key; _v66 arg init; errors -> _v102; returns 1 ok |
| -96 | _v96 SendCmd     | 0x5ce | a0=taglist(0x80000001=host name, default 'AREXX'), a1=cmd str; CreateMsgPort -> reply; CreateRexxMsg (rexx -0x90 via thunk) -> msg; CreateArgstring (rexx -0x7e) -> msg@0x28; msg@0x1c=0x1010000; Forbid, FindPort(host), PutMsg, Permit; WaitPort+GetMsg reply; result msg@0x20 -> d7; ClearRexxMsg (-0x9c), DeleteRexxMsg (-0x96), DeleteMsgPort; returns d7 (0x14 default) |
| -102| _v102 cleanup    | 0x806 | a0=taglist: 0x80000003->msg@0x16 field +0x20, 0x80000004->+0x24; ReplyMsg(host@0x16); FreeVec(buf@8); if bit0@0x1d: dos -0x35a(obj@0x12); clear bit0 of long @0x1a |

## Internal helpers (not in functab)

- `_initfn` @0x20 — AUTOINIT init: stores seglist @0x22, ln_Pri=1,
  copies the 24-byte DATA hunk into lib+0x30 (the dead rebase table
  at gd+0x14 has count 0), opens rexxsyslib(any ver)/utility v37/
  dos v37 into lib+0x48/0x4c/0x50 via `_openlibs`; failure -> return
  0 after `_closelibs` of whatever opened.
- `_openlibs` @0x2b2 / `_closelibs` @0x34e — dep open/close with
  reverse-order unwind on failure.
- `_split` @0x262 — split string at '_' copying to a5, stash ptr.
- `_th4c`/`_th64`/`_th7c`/`_th98` @0xa4c..0xa98 — rexxsyslib call
  thunks: `movel a6,-(sp); movea.l (gd+0x18).l, a6; jsr -LVO(a6)`.
  LVOs: -0x9c (ClearRexxMsg-like), -0x7e (CreateArgstring),
  -0x90 (CreateRexxMsg), -0x96 (DeleteRexxMsg).  **gd+0x18 is one
  longword past the 24-byte DATA hunk — see findings/quirks.md.**
- `_sprintf` @0xaac — RawDoFmt wrapper (exec -0x20a) with `_putch`
  @0xad0 writing bytes to the a3 buffer.
