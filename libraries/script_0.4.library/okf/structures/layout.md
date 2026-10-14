# script.library 0.4 — structures

## Library (dsize = 0x50 = 80)

Standard `struct Library` (34B) + `seglist@34` + private block @48:

```
+34  seglist pointer (init stores a0)
+48  copy of DATA hunk bytes 0..19 = {0, dsize=0x50, functab*, 0, initfn*}
+72  SysBase        (written by helper 0x158)
+76  libbase
```

`a4 = lib+48` is set as a vbcc data-base register in nearly every
function but never dereferenced except through the copy/fixup in init.

## Context (created by -42; 24 bytes, AllocPooled)

```
+0   unused
+4   unused
+8   MinList header (12B): head@8 tail@12 tailpred@16
+20  exec pool pointer
```

NOTE: -54/-60 and the -30/-36 fallback path access ctx+124 — out of
bounds of this 24-byte ctx (lands in pool slack; never faults because
the puddle is 1024B).  The -30/-36 path treats the SAME ctx argument
differently: it reads +20 (msg), +24 (rexxsyslib base), +124
(callback) — those fields only make sense on a caller-built struct,
not the -42 ctx.  See findings/quirks.md.

## Named-entry node (18 bytes, AllocPooled)

```
+0   ln_Succ
+4   ln_Pred
+8   char* name   (pooled copy)
+12  char* data   (pooled copy)
+16  word flag    (1 = entry valid/active)
```

## Internal rexx node (from _0x848; len+9 bytes)

```
+0..+3 zero
+4   word len (stored length)
+6   byte 2 (flag; bit0 => node kept on error path)
+7   byte = return of rxx -270 copy
+8   char str[len] + NUL at +8+len
```

## -30/-36 caller-supplied struct (observed fields)

```
+20  msg pointer (drives rxx -108 and the +252 stash)
+24  must equal rexxsyslib.library base or probe fails (ret 10)
+124 callback ptr / stored via -54
```
