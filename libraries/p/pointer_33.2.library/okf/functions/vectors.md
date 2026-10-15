# pointer 33.2 — vector map

Long-offset functab (32-bit code-hunk offsets), -1 terminator:

| LVO | target (orig) | function |
|-----|---------------|----------|
| -6  | 0x158 | Open — OpenCnt++, clear DELEXP, return base |
| -12 | 0x170 | Close — OpenCnt--; last close + DELEXP -> expunge |
| -18 | 0x0f6 | Expunge — DELEXP if open; else cleanup + inline node unlink + FreeMem(negsize..possize), return seglist@raw+0x22 |
| -24 | 0x024 | RESERVED — lands on the `\r\n\0\0` tail of the ID string (executed, it runs `addq.b #0,..` garbage; never called) |
| -30 | 0x258 | SetPointer — current spec -> intuition SetPointer (-270) |
| -36 | 0x2ae | LoadSpec — load pointer spec from an ILBM file |
| -42 | 0x5e6 | FreeSpec — FreeMem(spec[0], spec[5]) + FreeMem(spec, 24) |

Entry stub @0: `moveq #20,d0; rts` (70 14 4e 75) — returns 20 if the
file is exec'd as a program.

## LVO calls made

Exec:   OpenLibrary -552, CloseLibrary -414, AllocMem -198,
        FreeMem -210, RemNode -252.
DOS:    Open -30, Close -36.
Intuition: SetPointer -270.
IFFParse: AllocIFF -30, OpenIFF -36, ParseIFF -42, CloseIFF -48,
        FreeIFF -54, ReadChunkRecords -72, PropChunks -120,
        StopChunk -126, CollectionChunk -138, StopOnExit -150,
        FindProp -156, CurrentChunk -174, InitIFFasDOS -234.
