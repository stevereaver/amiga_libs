# streplay 33.8 — structures

## File layout

```
HUNK_HEADER: tablesize=1, first=0, last=0, hunk0 size=0x241 longs
0x18: HUNK_CODE  0x241 longs = 2308 B body  (file offset 0x20)
      RELOC32    47 offsets, all target hunk 0
      HUNK_END
```

## CODE hunk map

```
0x00  moveq #20,d0; rts                 DOS run stub
0x04  RomTag: 4afc, RTF_AUTOINIT|RTF_COLDSTART, ver 33, NT_LIBRARY(9)
      rt_Name   -> 0x1e "streplay.library"
      rt_IdString -> 0x2f "STReplay.Library V33.8 Kludged 2.10.89 by Olli, dem Größten\r\n"
      rt_Init   -> 0x6e (InitTable)
0x6e  InitTable: dataSize=0x30, functab->0x7e, datatab->0xaa, initfn->0xd6
0x7e  functab: 10 abs longs + -1
0xaa  datatab: InitStruct stream
      e0 0008 -> ln_Type    = 9   (NT_LIBRARY)
      c0 000a -> ln_Name    = _libname
      e0 000e -> ln_Flags   = 6   (LIBF_SUMUSED|LIBF_CHANGED)
      90 0014 -> lib_Version= 33
      d0 0016 -> lib_Revision=8
      c0 0018 -> ln_IdString= _idstr
      (padded/aligned forms; terminates with 0 + pad)
0xd6  initfn: a1=d0(libbase); lib+0x22=seglist(a0); lib+0x26=0; lib+0x2e=0
0xe6  _freebuf helper
0x104 Open / 0x110 shared rts / 0x112 Close / 0x122 Expunge / 0x166 Null
0x16a IsPlaying / 0x172 ModulePtr / 0x178 LoadModule / 0x1fc Unload
0x202 Play / 0x21c Stop
0x232 "dos.library\0"
0x240 _play2 / 0x25c _stop2
0x278 Interrupt struct (is_Data=0, is_Code->_handler @0x36a)
0x28e "STReplay_Lib Interrupt\0"
0x2a6 _setup   0x348 _mute   0x36a _handler   0x376 _tickmain
      0x37e: cmpiw #speed,_tick — immediate low byte @0x37f IS _speed
0x3ec _effect  0x514 _newrow  0x664 _note
0x7a8 _setspeed: writes tick=0 and speed byte into cmpiw immediate
0x7b6 channel state: 4 × 26 B
0x81e globals, 0x82c samtab[32], 0x8b2 period table (36 shorts), 0x900 _modbase
```

## Library node (dataSize 0x30)

```
+0x00 ln_Succ/Pred/Type/Pri/Name   (InitStruct'd: Type=9, Name->libname,
       +0x0e Flags=6, +0x14 Version=33, +0x16 Revision=8, +0x18 IdString)
+0x20 lib_OpenCnt (word)
+0x22 lib_NegSize/PosSize, seglist stored at +0x22 by initfn
+0x26 module buffer ptr (chip RAM, LoadModule)
+0x2a module file size
+0x2e playing flag (0x525a while playing)
```

## Interrupt struct @hunk+0x278

```
+0x00 ln_Succ/ln_Pred (0,0)
+0x08 ln_Type=2 (NT_INTERRUPT), ln_Pri=0
+0x0a ln_Name -> "STReplay_Lib Interrupt"
+0x0e is_Data = 0
+0x12 is_Code -> _handler (hunk+0x36a)
```

## Channel state @hunk+0x7b6 — 4 × 26 bytes

```
+0x00 packed note bytes (4-byte ProTracker cell copy)
+0x04 sample data ptr (AUDxLC)
+0x08 audlen (words, AUDxLEN)
+0x0a loopaddr / looplen
+0x10 current note (period index byte packed) 
+0x12 volume
+0x14 DMACON bit for channel (1/2/4/8)
+0x16 current period
```

## Globals (self-modifying CODE hunk)

```
0x81e _patoff    long   byte offset into current pattern (row*16)
0x822 _patidx    long   position index into 128-byte pos table
0x826 _tick      word   tick counter (incremented per VBLANK)
0x828 _patptr    long   current packed-row pointer
0x82c _samtab    32 longs  sample start addresses (index 1..31; [0] unused)
0x8ac _songlen   word   song length in lo byte (module +0x3b6)
0x8ae _dmamask   word
0x8b0 _patbreak  word
0x8b2 period table: 36 shorts (ProTracker finetune-0 periods
      0x358=856=C-2 down to 0x071=113=B-4)
0x8fa 6 pad bytes
0x900 _modbase   long   module base (also self-mod target)
```

## Module format expected (SoundTracker 31-instrument)

20 B title + 31×30 B sample descriptors (name22/len2w/finetune/vol/
looppt/looplen) + songlen byte @0x3b6 + restart byte + 128 pos bytes
@0x3b8 + N×1024 B pattern data (packed 4-byte note cells).
```
