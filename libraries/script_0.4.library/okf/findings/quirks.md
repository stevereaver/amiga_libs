# script.library 0.4 — findings & quirks

1. **Private rexxsyslib vectors.**  -30/-36 route through undocumented
   rexxsyslib.library vectors (-288, -108, -114, -270, -102, -120,
   -168 IsRexxMsg, -72, -66, -84).  The probe opens and immediately
   closes rexxsyslib every call, only proceeding when `arg+24` equals
   the rexxsyslib base and `arg+20` is nonzero — otherwise status 10.

2. **a2 is a live input register.**  Vec -30 strlen's a2 (never
   loaded inside the function); callers must pass a C string in a2.
   vbcc register-arg ABI: a0, a1, a2, d0/d1.

3. **Overlapping instructions in init.**  `0c40 1cd9` — the bccs loop
   enters the immediate word `1cd9` = `moveb (a1)+,(a6)+` (20-byte
   DATA-hunk -> lib+48 copy).  Also `0c40 200d` in the init epilogue:
   `beqs` jumps to `200d` = `movel a5,d0` (returns libbase); the
   preceding `cmpiw` is dead when not entered mid-instruction.

4. **Header-as-node strcmp.**  Both list walks (0x472, 0x652) treat
   the MinList header as a node on iteration 1: the "name" compared is
   `header+8` = lh_TailPred, i.e. they strcmp the *last node's raw
   struct bytes* against the search name, then check a "flag" at
   header+16 (out of bounds of the 24B ctx).  All real nodes still get
   checked (last node's succ = &lh_Tail != NULL), so the effect is a
   wasted compare plus a theoretical false-match if node bytes equal
   the name (then the out-of-bounds flag word and garbage data ptr are
   used).

5. **ctx+124 is out of bounds.**  -42 allocates a 24-byte ctx, yet
   -54/-60/-30's fallback read/write ctx+124 — inside pool slack
   (1024B puddle), never a fault, but formally OOB.

6. **msg+252 stash.**  _0x744 stores a continuation pointer and a
   save-area pointer into `msg+252..259`, saving/restoring the old
   pair around the call — a coroutine-style handoff inside the
   caller's message.

7. **Status 40 path.**  _0x7de splits the rxx-288 string at '.' into
   a prefix node, then verifies `strlen(node.str) == node.len` via
   rxx -102; a mismatch returns status 40 and frees both nodes with
   rxx -120.  Vec -30/-36 propagate any non-10 status verbatim
   (callers only special-case 10).

8. **Status values**: 0 ok, 3 = "lookup/alloc failure" fallback, 9 =
   len > 65535 in _0x744, 10 = rexxsyslib probe/IsRexxMsg failure,
   40 = node length-verify mismatch.

9. **Dead helper** at 0x3b8 (free-all-nodes walk) has no caller.

10. **Init fixup table never runs**: DATA+20 = 0, so the
    post-copy pointer-fixup loop over lib+48 is skipped.
