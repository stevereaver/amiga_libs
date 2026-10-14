# asyncio.library 37.2 — structures

## Hunk layout

```
hunk0 CODE 0x990 — functab+InitTable+strings+RomTag+all code
hunk1 BSS  0x014 — 5 global longs (a4-relative, via abs-long lea _bss)
```

## RomTag (h0+0x78)

`4afc`, matchtag→h0+0x78, **endskip→h0+0x190 (the Expunge entry,
not past the struct)**, flags=0x80 (AUTOINIT), ver=37, type=9
(NT_LIBRARY), pri=0, name→h0+0x68 `"asyncio.library"`,
idstr→h0+0x48 `"asyncio.library 37.2 (5.1.96)\r\n"`, init→h0+0x38.

## InitTable (h0+0x38, pointed to by rt_Init)

```
+0  .long 0x22     dataSize = sizeof(struct Library)
+4  .long ftab     → h0+4 absolute-long table, 12 vecs
+8  .long 0        no data table
+12 .long initfn   → h0+0xf2
```

## hunk1 globals (a4 base)

```
+0  libbase        +4  ExecBase       +8  UtilityBase
+12 DOSBase        +16 seglist
```

## AsyncFile (returned by OpenAsync/OpenAsyncFromFH)

AllocVec(2·bufsize + 161); buffers live at file+161 aligned to 16.

```
+0    af_File          BPTR file handle
+4    af_BlockSize     from InfoData.id_BytesPerBlock (default 512)
+8    af_Handler       MsgPort* = FileHandle.fh_Type
+12   af_Offset        byte* cursor into current buffer
+16   af_BytesLeft     read: bytes unread; write: space left
+20   af_BufferSize    per-buffer size (total bufsize/2)
+24   af_Buffers[2]    two buffer pointers
+32   sp_Msg           struct Message (embedded)
      +32..45 mn_Node   ln_Type=5 NT_MESSAGE; ln_Name→&sp_Pkt(+52)
      +46    mn_ReplyPort   NEVER INITIALISED (AllocVec garbage)
      +50    mn_Length  = 68
+52   sp_Pkt           struct DosPacket (embedded)
      +52  dp_Link      → &sp_Msg (+32)
      +56  dp_Port      → &af_PacketPort (+100), set per SendPacket
      +60  dp_Type      'R' (82) read / 'W' (87) write — stored as LONG
      +64  dp_Res1      bytes transferred / -1 error
      +68  dp_Res2      dos error code
      +72  dp_Arg1      = FileHandle.fh_Arg1
      +76  dp_Arg2      buffer pointer (SendPacket arg)
      +80  dp_Arg3      = af_BufferSize
+100  af_PacketPort    struct MsgPort (embedded)
      +100..113 mp_Node  ln_Type=4 NT_MSGPORT, ln_Name=0
      +114 mp_Flags     PA_IGNORE(2) ↔ PA_SIGNAL(0) around WaitPort
      +115 mp_SigBit    = 4
      +116 mp_SigTask   = FindTask(NULL)
      +120 mp_MsgList   lh_Head→&lh_Tail, lh_Tail=0, lh_TailPred→&lh_Head
+134  af_CurrentBuf    0/1 index into af_Buffers
+138  af_SeekOffset    pending-read offset after SeekAsync
+142  af_PacketPending byte flag
+143  af_ReadMode      byte: =1 iff OpenAsync mode==0 (via seq on
                     Z-flag left by `movel d1,sp@(40)`)
+144  af_OwnsFH        byte: CloseAsync calls dos Close when set
+161  buffers[2*af_BufferSize] (16-aligned)
```

## Fake FileHandle fields used

```
fh_Type  +8   → af_Handler (packet destination)
fh_Arg1  +36  → dp_Arg1
fib_Size +124 → SeekAsync EOF-mode target computation
id_BytesPerBlock (InfoData+20) → af_BlockSize, bufsize rounding
```
