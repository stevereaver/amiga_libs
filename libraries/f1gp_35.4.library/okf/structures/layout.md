# f1gp 35.4 — binary layout

## Hunk file

```
header    HUNK_HEADER (0x3f3), 2 hunks
sizes     hunk0=0x22a (554 longs, CODE|PUBLIC), hunk1=49 longs (DATA|PUBLIC)
hunk0     CODE hunk: 0x3e8 tag + 2216 B body
          RELOC32 (0x3ec): 20 offsets->hunk0, 10 offsets->hunk1
hunk1     DATA hunk: 0x3e9 tag + 104 B body (26 longs written,
          declared alloc 196 B -> 92 B zero/uninitialised tail)
          RELOC32: (empty-ish per original order) + END (0x3f2)
```

**Quirk**: DATA hunk declares 196 B but the file carries only 104 B.
`rt_Init` clears the trailing 96 B (`movel #26,d0`/`movel #23,d0` loop)
before use — the unwritten tail is the live globals workspace.

## RomTag (code+0)

```
+00 4afc          RTC_MATCHWORD
+02 ->+00         rt_MatchTag
+04 ->0x55a       rt_EndSkip (past vector table)
+06 84            rt_Flags = RTF_COLDSTART|RTF_AFTERDOS? (0x84, non-AUTOINIT)
+07 23            rt_Version 35
+08 09            rt_Type NT_LIBRARY
+09 00            rt_Pri
+0a ->0x1e        "f1gp.library"   (byte at +0x1d is 'j' = low byte of the
                                  preceding init-jump long — 'jf1gp.library'
                                  is an artifact of overlapping views)
+0e ->0x2b        "f1gp 35.4 (22.8.97)\r\n"
+12 ->0x6a        rt_Init
```

## Init path

`rt_Init` (code+0x6a) is called directly by the loader:
1. `a4 = DATA+0x7ffe`-style global pointer (hunk1 base + fixed bias);
   clears 96 B workspace at a4-96.
2. `AllocMem(62, PUBLIC)` -> library node; MakeLibrary with the
   long-absolute vector table at code+0x1b4, dsize 62.
3. Protection predicates `Patch1`/`Patch2` (stubbed `rts`).
4. `InitSemaphore(glob+0x78)`, stores libbase/seglist/sysbase in globals,
   `AddLibrary`, then post-init (`SetTaskPri` etc.).

## DATA hunk globals (hunk1 base + off)

| off | field |
|-----|-------|
| +0x00 | libbase |
| +0x04 | seglist |
| +0x08 | sysbase |
| +0x0c..| patch descriptors / relocation constants (hunk-size signatures 844/908/1312/1392, magic 0x2a948, target JSR sites) |
| +0x6c | patch-node list head (MinList) |
| +0x78 | signal semaphore (InitSemaphore'd) |
| +0x98 | node workspace |
| +0x68/+0x6a | flag words (flA/flB) |

## Patch node (16 B, AllocNode)

```
+0x00  ln_Succ (4)
+0x04  ln_Pred (4)
+0x08  task ptr     (from a0)
+0x0c  signal mask  (from d0)
```

## Library node (62 B, MakeLibrary dsize)

```
+0x00 Node ln (succ,pred,type,pri,name)
+0x14 lib_Flags, lib_pad, lib_NegSize=48, lib_PosSize=62
+0x20 lib_Version=35, lib_Revision=4
+0x24 lib_IdString ptr, lib_Sum, lib_OpenCnt
```
