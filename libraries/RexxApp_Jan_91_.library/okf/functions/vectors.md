# rexxapp.library vector map

All 14 slots are 6-byte `jmp abs` (`4ef9`) in a table at hunk+0x1e.
Base = hunk+0x72, so offsets = LVOs measured from the node.

| LVO | Target | Role |
|-----|--------|------|
| -84,-78,-72 | hunk+0 | null jmp → `moveq#0/rts` stub |
| -66 | 0x3dc | `RAX_SetResult` — `m->r2=d1; m->r1=d0`; if r1==0 & RXFF_RESULT & a0: ensure_rxs, CreateArgstring(a0)→r2; falls into maybe_close tail |
| -60 | 0x278 | `RAX_SendForward` — a1=fwd_reply(0x3b2), d0=RXCOMM, d1=0 → send body |
| -54 | 0x274 | `RAX_SendCommand` — a1=0, d0=RXCOMM, d1=0 → send body |
| -48 | 0x2a4 | `RAX_SendEx` — enters send body directly (full reg args) |
| -42 | 0x164 | `RAX_Cleanup` — flags|=0x80; loop{dispatch; WaitPort} till pending==0; FreeSignal+RemPort via 0x144 helper; flags&=~0x80; maybe_close |
| -36 | 0x190 | `RAX_Dispatch` — sigbit<0→ret; GetMsg loop (below) |
| -30 | 0x494 | `RAX_Setup` — name claim + port init (below) |
| -24 | hunk+0 | null |
| -18,-12,-6 | 0xd6/0xc4/0xb6 | Expunge / Close / Open |

## send body (0x2a4)

Args: a0=cmd, a1=cb→args15, a2=orig→args14, d0=action, d1=validator.
1. sigbit<0 → "Rexx port not setup"; pending+1==0 → "Too many Rexx msgs";
   ensure_rxs → "Can't find rexxsyslib.library" (helper sets a4 itself).
2. `CreateRexxMsg(a0=ctx, d0=mp_Name, a1=ext)` → "No mem for Rexx msg".
3. `action=d0`; pending++ unless RXFF_NONRET.
4. args0 = cmd (RXFF_STRING) else CreateArgstring(cmd).
5. `n_name=mp_Name`, args15=cb, args14=orig; validator(a5,a2) → error.
6. Forbid; FindPort("REXX"); PutMsg or "Can't find Rexx server";
   Permit; returns msg (a0 = last error string, garbage on success).

## dispatch body (0x190)

- reply (ReplyPort==ctx): resultproc(0xf8) via jmp-a6 trampoline, then
  args15 cb (register args), then freemsg(0x370).
- incoming: skip ' '/'\t'; r1=r2=0; flags bit7 → r1=100, ReplyMsg.
  Verb match = case-fold prefix compare with quirk: fold requires the
  *command* char |0x20 in (97,122) exclusive — 'a'/'z' never fold-match.
  match → handler; nonzero rc → ReplyMsg.  No match → fileext=ctx->ext;
  ext ? send_body(cmd, fwd_reply, msg, RXCOMM, 0) : r1=30 + ReplyMsg.

## helpers

- 0xf8 resultproc: r1&&r2 → cb_res(msg, priv96(r2)+8, r2); r1&&!r2 →
  r1>20u ? cb_res(msg,"Severe RETURN or EXIT",r1) : cb_err(msg,0,r1);
  r1==0 → cb_err(msg, RXFF_RESULT? (r2,0) : (0,r2)).
- 0x144: sigbit<0→ret; sigbit|=0x80; FreeSignal(sigbit); RemPort(ctx).
- 0x28a ensure_rxs: lazy OpenLibrary("rexxsyslib.library")→ctx+42.
- 0x3b2 fwd_reply: setresult(msg->args14, r1, r2, 0); ReplyMsg(orig).
- 0x370 freemsg(arg0,msg,flags): rxs&&!STRING → DeleteArgstring(arg0);
  !NONRET → pending--; RESULT&&!r1&&r2 → DeleteArgstring(r2);
  DeleteRexxMsg; → maybe_close tail.
- 0x40e maybe_close: pending==0 && rxs → rxs=0, CloseLibrary(rxs).

## setup (0x494)

mp_Name=a1; sigbit|=0x80; TDNestCnt++ (+0x127 manual Forbid).
Loop ≤9: FindPort(name) free → init; else append/rewrite one suffix
char '2'..'9',':' (58-d2, d2 dbf 8→0), bit31 of d2 tracks "digit
present" to overwrite vs append.  Init: port fields + NewList; flags/
pending word=0; rxs=0; AllocSignal(-1)→sigbit; SigTask=ThisTask;
sigbit≥0 → AddPort.  Permit; return waitmask 1<<sigbit (0 + a0=errstr
on failure).
