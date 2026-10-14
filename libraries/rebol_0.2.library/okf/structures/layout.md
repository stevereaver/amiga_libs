# rebol.library 0.2 — structures & hunk map

## Hunk file (2908 B)

```
0x000  HUNK_HEADER 0x3f3, no names, 1 hunk, size 0x2b7 longs
0x020  hunk0 body: 2780 B CODE, offsets below are body-relative
0xadc  HUNK_RELOC32 0x3ec — one group, target hunk 0, 19 offsets,
       deliberately NON-SORTED: 744 740 73c 738 734 730 22 2ba 46
       34 2a 26 1a 16 12 a 6 2b4 2ac   (fixup.py restores this)
0xaf8  pad long 0  +  HUNK_END 0x3f2
```

## RomTag (hunk+0x04)

```
4afc        RTC_MATCHWORD
matchtag -> 0x04 (self)
endskip  -> 0x1fe  (_ctxinit — NOT the hunk end; see quirks)
flags 0x80 AUTOINIT | version 0 | type 9 NT_LIBRARY | pri 0
name -> 0x30c "rebol.library"
id   -> 0x31a "$VER: rebol.library 0.2 (07.07.2001) (22:55:56/\xa9 2000, ...)"
init -> 0x1e (InitTable)
```

## InitTable (hunk+0x1e)

| off | value | field |
|-----|-------|-------|
| +0  | 0x2c  | data size: 34+44=78 bytes (struct Library only) |
| +4  | 0x730 | functab: 6 absolute longs + 0xffffffff |
| +8  | 0x02e | InitStruct datatab |
| +12 | 0x04e | initfn |

## InitStruct datatab (hunk+0x2e)

```
a008 0900          byte: ln_Type(8)   = 9   (NT_LIBRARY)
800a 0000030c      long: ln_Name(10)  -> "rebol.library"
a00e 0600          byte: lib_Flags(14)= 6   (LIBF_SUMUSED|LIBF_CHANGED)
9014 0000          word: lib_Version(20)=0
9016 0002          word: lib_Revision(22)=2
8018 0000030c      long: lib_IdString(24) -> "rebol.library"  (NOT _idstr!)
0000               terminator
000e               stray word (imm-mode cruft, inside hunk)
```

## Library header fields used

| off | field |
|-----|-------|
| +8  | ln_Type = 9 |
| +10 | ln_Name |
| +14 | lib_Flags = 6 |
| +16 | lib_NegSize (36), +18 PosSize (78) — runtime filled |
| +20 | version 0, +22 revision 2 |
| +24 | lib_IdString -> name (quirk) |
| +32 | OpenCnt (word) |
| +34 | seglist cell (init arg) |
| +38 | ctx-node list head |
| +43 | bit0: "survive one Expunge" flag (set by initfn, cleared once) |

## Context nodes (lib+38 list, AllocMem 2564 = 4+8+255*10)

```
+0   node next ptr (in slot-scan: a1@(-4) idiom — slots start +8)
+4   pad
+8.. +2550  slots[255]: { task.l, ctx.l, count.w }  (10 B each)
```

## Ctx buffer (3896 B, AllocMem MEMF_PUBLIC — NOT cleared)

`a4` = frame created by `linkw a4,#-512` with SP at buffer top, so
`a4@(-N)` fields live in the buffer tail; buffer base is the fmt
scratch. Used offsets:

| off    | meaning |
|--------|---------|
| -4     | saved caller SP (restored on teardown/epilogue) |
| -8     | current file handle (script fh during write; con fh reuse) |
| -12    | CON: file handle |
| -20    | FreeMem freelist head — NEVER INITIALIZED |
| -24    | error-return pointer — NEVER INITIALIZED (jmp *(ctx-24)) |
| -28    | error code (20 on CON: open fail) |
| -40    | SysBase |
| -44    | DOSBase |
| -48    | IntuitionBase |
| -52    | GfxBase |
| -64    | buffer base = RawDoFmt scratch (never cleared between fmts) |

## Counted buffers (_reboldo stack, and _fmt dest)

```
buf-4: capacity .w
buf-2: remaining .w   (written by _fmt)
buf+0: NUL-able string data
```
_caps pushed as `movel #cap<<16,sp@-` + `clrl sp@-`: 1000, 1200,
50, 100 bytes._

## functab (0x730)

`[0x6c, 0xaa, 0xe8, 0x14e, 0x790, 0x7a6, 0xffffffff]` — all six
entries are relocated absolute longs.
