# Library base — dataSize 0x36 (54)

| off | field          | notes                                    |
|-----|----------------|------------------------------------------|
| 0   | struct Library | through lib_OpenCnt @32                  |
| 34  | eb_Flags       | bit3 = expunge-on-last-close             |
| 35  | pad            |                                          |
| 36  | eb_DosBase     | dos.library v33                          |
| 40  | eb_SegList     |                                          |
| 44  | eb_SavedW      | saved LoadSeg slot word (opcode)         |
| 46  | eb_SavedL      | saved LoadSeg slot operand               |
| 50  | eb_SavedNL     | saved NewLoadSeg vector (exec>=37 only)  |

# Decoder work frame (54 bytes on stack, a4)

| off | field    | notes                                       |
|-----|----------|---------------------------------------------|
| 0   | litrun   | pending literal count (w)                   |
| 2   | bitbuf   | current bit byte (b)                        |
| 3   | resume   | resume match length (b)                     |
| 4   | blocks   | block counter (l; bit31 = len-1 flag then   |
|     |          | bclr'd after table build)                   |
| 8   | tab1     | 12B: 4 dist-class bases + 7 bitcounts +     |
|     |          | hdr hi-nibble overwrites last byte          |
| 20  | lensum   | 8w: 1<<len bases, last 4 += first 4 (cumul) |
| 36  | tab2rec  | 12B record selected by hdr lo-nibble*10     |
| 48  | seg      | seglist base pointer                        |
| 52  | lim      | output-hunk limit index (count-2, w)        |

# Loaded-hunk layout used by the walker

Each hunk: [alloc+0]=allocsize, [alloc+4]=next-BPTR, [alloc+8]=data.
Walker: start at seglist, follow `*(a1)` BPTR<<2 links d6-1 times,
`+4` -> link ptr; data at link+4; allocsize at link-4.
