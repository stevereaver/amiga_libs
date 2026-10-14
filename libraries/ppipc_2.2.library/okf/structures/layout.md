# ppipc.library 2.2 — structures

## Hunk layout

```
h0  CODE 0xb0   stub + RomTag + NewList/strlen/strcpy helpers
h1  DATA 0x38   datatab + SysBase cell (+0x32)
h2  DATA 0xa0   name + idstr + ver/rev + functab + InitTable
h3  CODE 0xe8   init, Open, Close, Expunge, null
h4  DATA 0x04   seglist cell
h5  CODE 0x3c0  port vectors -30..-90 + trampolines
h6  BSS  0x10   port list head (NewList'd by init)
h7  CODE 0x134  -96 broker + jmp stubs
h8  DATA 0x10   "PortBrokerPort"
h9  CODE 0x84   -102 Str2ID, -108 FindID
h10 CODE 0x28   GetMsg/WaitPort SysBase-reload wrappers
```

## RomTag (h0+4)

`4afc`, matchtag→h0+4, endskip→h0+0x1e, flags=0x80 (RTF_AUTOINIT),
ver=1, type=9 (NT_LIBRARY), pri=0, name→h2+0 (`ppipc.library`),
idstr→h2+0xe (`PPIPC version 2.2 89:04:17\n`), init→h2+0x8a.
DOS stub is `moveq #20,d0; rts` (not the usual moveq#0).

## InitTable (h2+0x8a)

```
+0  .long 0x22          dataSize = 34 (posSize 0x22 → lib ends at +0x22)
+4  .long h2+0x2e       functab (absolute longs, 22 entries, -1)
+8  .long h1+0          datatab
+12 .long h3+0          initfn
```

## datatab (h1+0) — extended 24-bit-offset commands only

cmd 0xe0=w8, 0xd0=w16, 0xc0=w32; offset = `offbyte<<16 | offsetword`.
Entries word-aligned (odd-size w8 entries padded). Effect:

```
ln_Type  = 9      (w8  @8)     ln_Pri = 0  (w8  @9)
ln_Name  → "ppipc.library"      (w32 @0xa, reloc→h2+0)
ln_Flags = 6      (w8  @0xe)   lib_Flags pad @0xf
version  = 1      (w16 @0x14)  revision = 0 (w16 @0x16)
idstring → "PPIPC version …"    (w32 @0x18, reloc→h2+0xe)
```

initfn (h3+0) then adds: SysBase→h1+0x32, seglist(a0)→h4+0,
ver/rev words copied h2+0x2a/0x2c→lib+0x14/0x16 (→ lib reports 2.2,
overriding datatab's 1.0), NewList(h6 port list) — via a0=arg helper.

## Port object (h5 _mkport, size = 50+strlen(name))

```
+0x00 ln_Succ/ln_Pred     exec node, linked into h6 list (AddHead)
+0x08 ln_Type = 4 (NT_MSGPORT)
+0x09 ln_Pri = 0
+0x0a ln_Name → +0x30 string copy (0 for anonymous ports)
+0x0e mp_Flags byte: 2 at create & after SetSigMode, 0 after PortSignal
+0x0f mp_SigBit
+0x10 mp_SigTask
+0x14 …0x1f mp_MsgList — NewList'd at create; the library itself
      never enqueues (broker replies go to the *anonymous* reply port)
+0x26 usecount (word)
+0x28 flags (word): 0x8000 = signal allocated/ready (set by -54,
      cleared by -60!), 0x4000 = set by -60, low byte = user flags
      written by -72; bit0 = "signal owner on use" (-42/-48)
+0x2a alloc size (word) — FreeMem size on release
+0x30 name bytes
```

ready mask tested everywhere: `flags & 0x9000`. The 0x1000 bit of the
mask is never assigned by any vector.

## Message object (h5 _allocmsg)

`total = (idx-1)*16 + base + 46` (rejected if total-20 > 0xffff);
fields: msg+18 = total-20, msg+28 = idx, msg+14 = reply port.
Broker fills: +0x14=`'IPPL'`, +0x1e=`'PORT'`, +0x2a=target port ptr.
-90 frees `msg+18 + 20` bytes.

## FindID table (h9 _findid)

word record-count at tbl+0x1c; records are 16 bytes each starting at
tbl+0x1e, first long = 4-char ID. a1 cursor = resume point (search
starts after it).
