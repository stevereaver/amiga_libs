# intuisupport.library vectors

Functab at code+0x67c: 15 absolute-longword entries relocated to
code, -1L terminator.  Private register ABI: a6 = library base,
args in registers (not stack).

| LVO | code off | name          | args / behaviour |
|-----|----------|---------------|------------------|
| -6  | 0x0ce    | Open          | ++OpenCnt, clear DELEXP, ret base |
| -12 | 0x0e8    | Close         | --OpenCnt; if 0 && DELEXP -> Expunge |
| -18 | 0x11e    | Expunge       | open->defer; else CloseLibrary x2, Remove, FreeMem, ret seglist |
| -24 | 0        | reserved      | NULL entry |
| -30 | 0x2b0    | Make3DBorder  | d0=w d1=h d2=x d3=y d4=penA d5=penB (a0 ignored->0) -> b1 |
| -36 | 0x3ae    | FreeBorder    | a3=border; frees XY(24), b2(16), b1(16) |
| -42 | 0x1b8    | AllocBufList  | d0=size -> 36B header {bufA,bufB,0,cnt=size-1,0,...} |
| -48 | 0x254    | FreeBufList   | a3=hdr; frees bufA(cnt+1), bufB(cnt+1), hdr(36) |
| -54 | 0x178    | ResetBufList  | a3=obj; hdr=obj+34; clears cnt bytes of bufs, F8/F12/F14=0 |
| -60 | 0x3f8    | FillBuf       | a5=dst d7=byte d6=len |
| -66 | 0x420    | ClrBuf        | a5=dst d7=len (FillBuf byte=0) |
| -72 | 0x464    | StrLen        | a5=s -> d0 length |
| -78 | 0x440    | ISCopyMem     | a3=src a5=dst d7=len -> exec CopyMem |
| -84 | 0x488    | AbortAlert    | a5=text a3=callback; DisplayAlert + jsr a3 |
| -90 | 0x628    | DrawText      | a3=obj(rp@+50) d5=pen d4=bg d7=x d6=y a5=text |

## Make3DBorder (-30)

Returns Border* chain of two 16-byte Border structs sharing one
24-byte XY block:

    xy[] = {(0,h),(0,0),(w,0),(w,1),(w,h),(1,h)}   six WORD pairs
    b1 = {x, y, penA, mode 0, count 3, xy+0, next=b2}   top/left
    b2 = {x, y, penB, mode 0, count 3, xy+12, next=0}   right/bottom

Alloc order xy(24), b1(16), b2(16), MEMF_PUBLIC|MEMF_CLEAR.
Failure: b1 fail -> free xy, NULL;  b2 fail -> free b1, NULL,
xy leaked.  a0 (next) is zeroed at entry -- dead parameter.

## AllocBufList (-42)

Alloc order bufA(size), bufB(size), header(36), all CLEAR|PUBLIC.
Header: {BufA, BufB, F8=0, Count=size-1, F12=0, F14=0, rest 0}.
On failure frees earlier blocks, returns 0.

## AbortAlert (-84)

Builds a DisplayAlert piece string on the stack and calls
IntuitionBase-90 DisplayAlert(0, buf, 40), then tail-calls a3.

Buffer layout (empirically confirmed byte-for-byte):

    buf+0        UWORD x = 320 - 4*strlen(text)   (80-col centring)
    buf+2        byte 0x10          (template +86)
    buf+3        *callback          (first byte of callback code!)
    buf+4        strlen(text) zero bytes  (text never copied -- hole)
    buf+4+len    0xcc
    buf+5+len    template +84/+85 (00 50)
    buf+7+len    template +87 (0x1c)
    buf+8+len    abort message, strlen(msg) = 60 bytes
    then         NUL

In DisplayAlert {x.w, y.w, text\0} terms this parses as
{x=centered-x, y={0x10,cb[0]}, ""}, a run of empty zero pieces
(alignment depends on strlen(text)) and finally the German text
piece.

## DrawText (-90)

    rp = *(obj+50)
    GfxBase-342 SetAPen(rp, d5)
    GfxBase-348 SetBPen(rp, d4)
    GfxBase-240 Move(rp, d7, d6)
    GfxBase-60  Text(rp, a5, strlen(a5))
    return strlen
