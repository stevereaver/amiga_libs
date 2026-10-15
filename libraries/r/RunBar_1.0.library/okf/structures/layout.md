# RunBar 1.0 — structures

## Hunk map

| hunk | type  | size  | contents                                      |
|------|-------|-------|-----------------------------------------------|
| 0    | 3e9   | 0x704 | code: entry stub, RomTag@+4, init, functions  |
| 1    | 3ea   | 0x024 | DATA: pad + InitTable@+4 + globals + count@+0x20 |
| 2    | 3ea   | 0x058 | DATA: functab (12 longs + -1) + name/idstr    |

Relocs (code hunk): self {6,a} = MatchTag/EndSkip; ->hunk1
{1a,74,86} = rt_Init + two template-base refs in LibInit;
->hunk2 {12,16,34,5a} = rt_Name, rt_IdString, and the two
initfunc stores of name/idstr.  Hunk1 relocs: ->hunk0
{10,1c} = initfunc, verstr ptr; ->hunk2 {8} = functab.
Hunk2 relocs: ->hunk0 {0..0x2c} = all 12 functab entries.

## Library base (dataSize = 0x194)

```
+0   struct Node (14)          filled by LibInit by hand
+14  ln_Flags=6  +15 pad
+16  NegSize     +18 PosSize   used by expunge
+20  Version=1   +22 Revision=0
+24  IdString -> "RunBar.library 1.0"
+28  Sum         +32 OpenCnt   +34 SegList
+48  RBPriv (356 bytes):
     +20  magic 0xa3b5f9d1  (written by first RB_Add/RB_Reset)
     +24  lock flag        (RB_LockTable/-72)
     +36  ent[16]          (only [0..14] reachable)
```

The priv block's first 128 bytes get the DATA-hunk template
copy: {0, 0x194, functab, 0, initfunc, 0, 0, verstr, 0,
<23 longs of OOB/zero>}.  Only +20/+24 are live fields.

## Slot (RBEntry, 20 bytes)

```
+0x00 key    registration handle (lookup value)
+0x04 port   anonymous MsgPort (NewList'd, no AddPort)
+0x08 f8     user field (patched by -66)
+0x0c fc     user field (patched by -66)
+0x10 obj    handler object
```

## Handler object (caller-supplied)

```
+2  char *name    dedup string (unaligned packed field!)
+6  long flag     1 -> -36 also dedups on name match
```

## Request message (28 bytes, AllocMem CLEAR|PUBLIC)

```
struct Message mn_ReplyPort=replyport, mn_Length=28, ln_Type=5
+0x14 cmd    0x80800000 (request) / 0x80800001 (teardown)
+0x18 arg    caller arg / 0
```

## Template + fixup mechanism (dead)

LibInit copies 32 longs from DATA+0 into priv — the shipped
DATA hunk is only 36 bytes so the tail reads past it — then
applies `count = templ[8]` (0) base-relative fixups:
`*(priv + fix[i]) += priv`.  Dead code (count always 0).
