# intuisupport.library structures

## Library base (dataSize 178 = 0xb2)

    +0..33   struct Library (34 bytes, manually initialised by init)
    +34      ULONG seglist
    +38..45  8 pad bytes (unused)
    +46..177 private area (132 bytes)

## Private area (base+46)

First 124 bytes are a verbatim copy of the DATA hunk template;
init appends two library bases:

    +0    ULONG 0
    +4    ULONG 0xb2    dead image of inittab.dataSize
    +8    ULONG 0x67c   dead image of functab code offset
    +12   ULONG 0       dead image of inittab.dataTable
    +16   ULONG 0x20    dead image of inittab.initRoutine
    +20   char[61]      "Nach Betaetigung einer Maustaste wird das
                         Programm beendet !!" + NUL at +80
    +81..83 0 pad
    +84   0x00          alert template byte -> buf[5+len]
    +85   0x50          alert template byte -> buf[6+len]
    +86   0x10          alert template byte -> buf[2]
    +87   0x1c          alert template byte -> buf[7+len]
    +88   "intuition.library" NUL
    +106  "graphics.library" NUL
    +123  0 pad
    +124  APTR IntuitionBase   (overwrites the shipped fixup count)
    +128  APTR GfxBase

## Border pair (Make3DBorder)

    struct ISBorder {                 /* 16 bytes == struct Border */
        WORD  LeftEdge, TopEdge;
        UBYTE FrontPen, DrawMode;
        WORD  Count;                  /* 3 */
        WORD  *XY;
        ISBorder *NextBorder;
    };
    XY block: 6 WORD pairs in one 24-byte alloc
      b1.XY = {(0,h),(0,0),(w,0)}       top/left,  penA
      b2.XY = {(w,1),(w,h),(1,h)}       right/bot, penB

## Buffer list header (36 bytes, AllocBufList)

    +0   UBYTE *BufA
    +4   UBYTE *BufB
    +8   UWORD F8    (state, reset by ResetBufList)
    +10  UWORD Count (size-1)
    +12  UWORD F12
    +14  UWORD F14
    +16..35 zero

## Caller objects

- ResetBufList expects an object whose +34 points at a buffer-list
  header.
- DrawText expects an object whose +50 points at a RastPort.
