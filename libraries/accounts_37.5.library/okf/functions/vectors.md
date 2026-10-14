# accounts.library 37.5 — vector map

Functab at hunk+0x58: leading `0xffff` flag → entries are **word
offsets relative to the functab base** (not absolute longs), `0xffff`
terminated. 19 vectors (NegSize = 114 bytes).

| LVO  | code off | name (inferred)     | behaviour |
|------|----------|---------------------|-----------|
| -6   | 0x138 | Open    | opencnt++; if lib+58 (entity) already set → clear DELEXP, return lib. Else ObtainSemaphore(lib+62): OpenLibrary("nipc.library",0)→+34; nipc -126(empty tags)→ctx +54; dos GetVar("Envoy/AccountsServer",+116,128)→+112 (a0=value or NULL if <0); nipc -138(host,+1="Accounts Server",ctx)→+58; failure unwinds via delctx -132 / CloseLibrary. ReleaseSemaphore. If +58==0 → opencnt--, return 0; else return lib. |
| -12  | 0x1ec | Close   | opencnt--; if !=0 → 0. Last close: ObtainSemaphore, nipc -144(entity +58), nipc -132(ctx +54), CloseLibrary(nipc), ReleaseSemaphore, clear +34/+54/+58; if DELEXP → fall into shared expunge (returns seglist). |
| -18  | 0x244 | Expunge | opencnt!=0 → bset DELEXP, ret 0 (deferred). Zero → shared body at 0x254. |
| -24  | 0x298 | —       | `moveq #0,d0;rts` reserved |
| -30  | 0x29c | AllocAcct?  | AllocMem(40, MEMF_PUBLIC\|MEMF_CLEAR) via lib+38 ExecBase |
| -36  | 0x2b6 | AllocGroup? | AllocMem(34, MEMF_PUBLIC\|MEMF_CLEAR) |
| -42  | 0x2d0 | FreeAcct?   | FreeMem(a0, 40) |
| -48  | 0x2ec | FreeGroup?  | FreeMem(a0, 34) |
| -54  | 0x876 | 'q' request | wrapper: passes caller's a2 as stacked arg2; → _requ_qu(cmd=113) |
| -60  | 0x7de | 't' request | obj 112: arg0→data+0, arg1→data+40, arg0+32→data+32, arg1+32→data+104; send; result = obj+30 (no copy-out) |
| -66  | 0x308 | 'n' request | obj 72: arg0 str→data+0; on reply arg1←data+0(32), data+64/66/68 (w,w,l)→arg1+32/34/36 |
| -72  | 0x3a0 | 'p' request | obj 40: arg0→data+0; reply arg1←data+0(32), data+32(w)→arg1+32 |
| -78  | 0x42c | 'm' request | obj 72: d0 word→data+64; reply arg0←data+0(32), data+64/66/68→arg0+32/34/36 |
| -84  | 0x4bc | 'o' request | obj 40: d0 word→data+32; reply arg0←data+0(32), data+32→arg0+32 |
| -90  | 0x540 | 'j' request | obj 72: arg0→data+0, arg0+32→data+64; reply arg0←data+0(32), data+64/66/68→arg0+32/34/36 |
| -96  | 0x5e0 | 'l' request | obj 40: arg0→data+0, arg0+32→data+32; reply arg0←data+0(32), data+32→arg0+32 |
| -102 | 0x674 | 'k' request | obj 112: arg0→data+0, arg1→data+40, arg0+32→data+32, arg1+32→data+104; reply arg1←data+40(32), data+104/106/108→arg1+32/34/36 |
| -108 | 0x8c6 | hash password | a0=out(12B), a1=str (password?), a2=name(32B field). Lowercases a2 into a 32B local via utility ToLower; builds 12-long mix[i]=lowername_i+str_i+65 (each walks its own buffer, index i substituted when NUL); then for each slot a rolling `v=(v+mix[11-i])%53` over all 12 longs → byte = v+65 ('A'); writes 11 chars + NUL. Returns a0. |
| -114 | 0x89e | 'u' request | wrapper like -54, cmd=117 |

All request vectors share the shape: `mkobj({0x800b1101,size})` → fill
data block & cmd byte → `_sendreq` → `d0 = obj+30` (server status;
501 = local alloc failure) → free obj via nipc -120. The reply copy-out
runs only when obj+30 == 0.

## Internal helpers (not in functab)

| off | role |
|-----|------|
| 0x254 | shared expunge body: inline Remove (pred/succ splice), CloseLibrary(util,dos), FreeMem(lib−NegSize, Neg+Pos), returns seglist |
| 0x738 | `_requ_qu`: shared 'q'/'u' worker, d0=cmd char, a0→data+0, a1→data+32, stacked arg (caller's a2) is the out-struct |
| 0x994 | `_sendreq`: CreateMsgPort → obj+14=port, obj+54=obj+42, obj+58=obj+46, obj+30=0, obj+66=5 → nipc -156(entity,ctx,obj) → WaitPort/GetMsg/DeleteMsgPort → returns 1/0 |
| 0xa28 | `_mkobj`: nipc -114(a0=taglist ptr = caller's stacked {0x800b1101, size, 0}) |
| 0xa3c | `_sprintf`: RawDoFmt(fmt=a0, stream=&stack args, putch=_putch, data=a0-arg0) — **dead code**, no callers |
| 0xa5e | `_putch`: `moveb d0,(a3)+;rts` — RawDoFmt char sink for _sprintf |
| 0xa62 | `_strncpy`: copies up to d0 bytes a1→a0, stops early on NUL (DBEQ), then forces `dst[last]=0` via `clrb -(a0)` |
| 0x000 | `moveq #-1,d0;rts` — unreferenced pre-RomTag stub |

## External LVOs

- exec.library (via lib+38): -198 AllocMem, -210 FreeMem, -372 GetMsg,
  -384 WaitPort, -414 CloseLibrary, -522 RawDoFmt (dead path),
  -552 OpenLibrary, -558 InitSemaphore, -564 ObtainSemaphore,
  -570 ReleaseSemaphore, -666 CreateMsgPort, -672 DeleteMsgPort
- dos.library (via lib+42): -906 GetVar ("Envoy/AccountsServer")
- utility.library (via lib+46): -156 UDivMod32, -180 ToLower
- nipc.library (via lib+34): -114 alloc-request(tagged), -120 free-obj,
  -126 create-context, -132 delete-context, -138 find-service,
  -144 release-entity, -156 transaction/round-trip
  (nipc.library is the Commodore Envoy IPC library; LVO names inferred)
