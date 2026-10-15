# mhimpegit.library 1.1 — function vectors

14 vectors, absolute `.long` function table @ h0+0x2e0, terminated by
`0xffffffff`. Nonstandard register convention: the decoder context is
passed in **a3** (and named buffer/args in a0/d0/d1), not the usual
a0-only ABI. InitTable @ h0+0x344 (dsize 0x2c).

| LVO  | offset | name (inferred)    | semantics |
|------|--------|--------------------|-----------|
| -6   | 0x16c  | Open               | `opencnt++`, clears LIBF_DELEXP (flags & ~8), returns lib |
| -12  | 0x184  | Close              | `opencnt--` (guarded); at 0 with DELEXP set -> tail-calls Expunge |
| -18  | 0x1ac  | Expunge            | opencnt!=0 -> set DELEXP, ret 0; else stores sysbase to `_gd+0`, closes all dep libs (0x9c helper), `Remove`, `FreeMem` (0xfc helper), returns seglist (lib+0x24) |
| -24  | 0x1f4  | reserved           | returns 0 |
| -30  | 0x354  | AllocDecoder       | `(a0=name, d0=mode) -> a2 ctx|0`. Opens prelude.library v5, requires ver>5 or (5,rev>=6); checks `prelude->0x38->byte+0x15` bit0 (MPEGit module present). AllocVec 0x10 ctx {+0 name, +4 mode, +8 ?, +0xc list}; AllocVec 0x0c MinList buffer; `prelude -0x5a` with TagItems `{0x80000032:name, 0x80000033:mode, 0x8000003f:0x63}`; clears `prelude->0x8e->0x10` |
| -36  | 0x4b0  | FreeDecoder        | `(a3=ctx)`. NULL-safe. CloseLibrary(prelude), clears `_gd+0xc`; drains ctx+0xc MinList (RemHead+FreeVec each node); FreeVec(ctx) |
| -42  | 0x518  | QueueBuffer        | `(a0=buf, d0=len, a3=ctx) -> bool`. AllocVec 0x12 node {succ,pred,?, +8 buf, +0xc len, +0x10 played-flag w}; AddTail to ctx list, ctx+8 count++. If `prelude->0x8e->0x10` (hw busy) nonzero: sets node flag, calls `prelude -0x3c (a0=buf, d0=len, d1=0x1008, d2=0x5622)` notify. Returns 1, 0 on OOM/null |
| -48  | 0x5ac  | GetBufferHandle    | `(a3=ctx) -> handle|0`. Returns 0 while `prelude->0x8e->0x10` >= ctx+8 count (all outstanding). Else RemHead -> returns node+8 (buffer), FreeVec node, count-- |
| -54  | 0x608  | Status             | `(a3=ctx)` -> 0 if prelude open AND ctx AND `prelude->0x8e->0x10` nonzero (hardware active), else 1 |
| -60  | 0x634  | Play               | `(a3=ctx)`. Walks ctx list; for each node with flag==0 calls `prelude -0x3c (a0=node+8, d0=node+0xc, d1=0x1008, d2=0x5622)` then sets flag=1 |
| -66  | 0x688  | Stop/ClearBuffer   | `(a3=ctx)`. `prelude -0x54 (d0=0x80)`, `prelude -0x24`, dos `Delay(0x23)`; drains ctx list; clears `prelude->0x8e->0x10` and ctx+8 |
| -72  | 0x708  | Pause stub         | `rts` — not implemented (returns stale d0) |
| -78  | 0x70c  | Query              | `(d1=selector)`. Returns 1 for sel in {1..3,10..12,20..22,30..32,40..42} and 1010; pointers for 1000="MPEGit", 1001=idstr, 1002=author string; else 0 |
| -84  | 0x7c4  | SetParam           | `(a3=ctx, d0.w=cmd, d1=val)`. cmd 0: tag `0x8000003f`=min(val,100) raw. cmds 3/5/6: val capped at 100, scaled `floor(val*0xF0000/50)>>16` (=val*0.3 fixed point) via 64-bit div helper @0xa0c; sent as tags `0x8000003c`/`0x8000003d`/`0x8000003b` respectively. cmds 1,2,4 and others: no-op |

## Internal helpers

- `0x04` dep-open: OpenLibrary("dos.library",37) -> `_gd+8`;
  OpenLibrary("intuition.library",37) -> `_gd+4`; Alert
  `0x35038004`/`0x35038007` + cleanup on failure. Returns 0 ok / 1 fail.
- `0x9c` closelibs: CloseLibrary on `_gd+0xc`, `_gd+4`, `_gd+8` if set.
- `0xfc` freelib: FreeMem(lib - NegSize, NegSize+PosSize).
- `0x134` initfn: stores seglist (lib+0x24), sysbase (lib+0x28, `_gd+0`),
  calls dep-open; failure -> freelib + return 0.
- `0x1f8` errf: RawDoFmt (exec -0x24c) with array `{0x14,0,_name,arg,
  _abortmsg("Abort :/")}` — SAS/C error reporter; fmt a0=0.
- `0xa0c` 64-bit unsigned divide (SAS/C runtime helper).
- `0xa98` NewList (MinList init on a 12-byte block).
