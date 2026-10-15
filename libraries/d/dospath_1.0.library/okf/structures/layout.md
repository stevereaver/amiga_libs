# dospath.library 1.0 — hunk & object layout

## File

```
0000 000003f3                 HUNK_HEADER
0004 00000000                 (no names)
0008 00000002                 tablesize=2
000c 00000000 00000001        first=0 last=1
0014 00000268 00000003        sizes: h0=2464B, h1=12B (alloc)
001c 000003e9 00000268        hunk0 CODE, 2464B body
0024 ...                      h0 body (file 0x24..0x9c3)
09c4 000003ec                 RELOC32
        18 -> hunk0: 40 3c 48 4c 50 54 58 5c 64 60 68 6c 70 74 78 7c 80 84
        12 -> hunk1: 26a 1f4 154 112 5a0 630 724 770 85e 836 89e 91e
        0  (end)
0a54 000003f2                 HUNK_END
0a58 000003ea 00000001        hunk1 DATA, record size=1 long
0a60 00000000                 body (4B)
0a64 000003f2                 HUNK_END
```

Note the hunk1 size quirk: header table allocates 3 longs (12B) but the
record only carries 1 long (4B). fixup.py patches the table entry.

## hunk0 map (hunk-relative)

| off | content |
|-----|---------|
| 0x000 | `moveq #0,d0;rts` dead stub |
| 0x004 | "dospath.library\0" |
| 0x014 | "$VER: dospath.library 1.0 (25.8.96)\r\n\0" |
| 0x03a | RomTag (4afc; MatchTag->0x3a; EndSkip->0x54; flags=0 COLDSTART; ver=1 type=9 pri=0; name->4; id->0x14; init->0x10a) |
| 0x054 | functab: 13 .long entries (-6..-78) |
| 0x088 | 0xffffffff terminator + word pad |
| 0x08e | _makelib: MakeLibrary(functab,0,0,44,0) + header fill |
| 0x0dc | _freemem helper |
| 0x10a | _init (rt_Init) |
| 0x14e | Open (clone) |
| 0x1ee | Close |
| 0x264 | Expunge |
| 0x2a2 | ret0 |
| 0x2a6 | "utility.library\0" |
| 0x2b6 | "dos.library\0" |
| 0x2c2 | nop |
| 0x2c4 | _f2c4 name-array builder |
| 0x41c | _f41c BPTR-array builder |
| 0x59a | -48 taglist walker |
| 0x628 | -42 DupLock chain |
| 0x71a | nop |
| 0x71c | -36 freelist |
| 0x766 | nop |
| 0x768 | -54 CurrentDir/Lock walker |
| 0x812 | nop |
| 0x814 | _h814 DevNode type-13 helper |
| 0x82e | -66 next-vol |
| 0x856 | -72 set next-vol |
| 0x892 | nop |
| 0x894 | -60 SameLock prune |
| 0x918 | -78 Workbench path |
| 0x97a | "Workbench\0" |
| 0x984 | tail stubs: ret0/ret1/ret0/ret1/rts/nop/rts/nop/rts/nop ->0x9a0 |

## Runtime objects

- globals hunk h1: `+0 libbase (master), +4 seglist, +8 sysbase`
  addressed as `a4 = h1 + 0x7ffe`; `a4@(-32766)=+0`,
  `a4@(-32762)=+4`, `a4@(-32758)=+8`.
- master/clone lib: 44-byte data (`MakeLibrary d0=44`), lib+36=dosbase,
  lib+40=utilitybase; opencnt at lib+32.
- path node (8B, AllocVec MEMF_PUBLIC): `+0 next` written as BPTR
  (ptr>>2), `+4 lock`.
- DevNode-ish input for -66/-72: `+8 == 13` selects; `+172` holds
  BPTR to a vol node whose `+8` is the next-volume BPTR.
