# asyncio.library 37.2 — vector map

Functab at h0+4 (12 absolute-long entries + `0xffffffff` terminator) —
it sits *before* the RomTag (h0+0x78), an unusual layout: InitTable is
a 4-long record (dsize=0x22, functab→h0+4, datatab=0, initfn→h0+0xf2).

| LVO | name | behaviour |
|-----|------|-----------|
| -6  | Open    | std open, opencnt++ |
| -12 | Close   | opencnt--, deferred-expunge aware |
| -18 | Expunge | Remove + FreeMem, returns seglist |
| -24 | —       | null stub (h0+0, `moveq #0,rts`) |
| -30 | OpenAsync        | (name,mode?,bufsize) -> async file obj: dos Open + FileHandle + 2 buffers + packet state |
| -36 | OpenAsyncFromFH  | build async obj around an existing dos FileHandle (DupLockFromFH/Info path) |
| -42 | CloseAsync | drain pending packet, free buffers, close fh |
| -48 | SeekAsync  | reposition logical offset, invalidate buffers |
| -54 | ReadAsync  | (file,buf,len) -> bytes; double-buffered prefetch, crosses buffer boundaries + EOF |
| -60 | WriteAsync | (file,buf,len) -> bytes; buffered write-behind |
| -66 | ReadCharAsync  | ReadAsync(file,&ch,1) wrapper |
| -72 | WriteCharAsync | WriteAsync(file,&ch,1) wrapper |

External: exec (OpenLibrary, CloseLibrary, AllocVec/FreeVec,
CreateMsgPort/DeleteMsgPort, PutMsg/GetMsg/WaitPort, DoIO-adjacent),
dos.library (Open, Close, packet ops DoPkt/SendPkt/WaitPkt/ReplyPkt,
DupLockFromFH, Info, Lock/UnLock, Seek, Read, Write), utility.library
(SMult32, SDivMod32 for seek math).
