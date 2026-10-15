# Structures — bfbplayGMOD.library V1.0

## Library base (dataSize 0xb2 = 178)

```
+0    struct Library (OpenCnt +32, NegSize +16, PosSize +18)
+34   flag byte (bit3 = delayed expunge)
+36   ExecBase
+40   dos.library base
+44   seglist
+158  CIA period word (written 0x3781 at cia_start)
+160  ciaa.resource base
+164  ciab.resource base
+168  CIA chip base in use (0xbfe001 ciaa / 0xbfd000 ciab)
+172  resource base in use
+176  timer byte (0 = timer A, 1 = timer B)
```

## Session block (80 bytes, MEMF_CLEAR)

```
+0    type byte = 7 ("GMOD")
+1    running byte (module code active; gates tick dispatch)
+2    modbuf (unaligned +2!)
+6    buf2 (never set by this lib)
+10   modlen (unaligned)
+14   len2 (never set)
+20   songs-1 (word; modbuf+64() - 1)
+24   cursong (word; 0-based -- unlike PSID's 1-based)
+26   fmtname = "GMOD"
+30   name (never set)
+34   namelen (never set)
+38   buf3 (never set)
+42   len3
+56   playing flag
```

## Code-hunk globals (in the code section)

- `cur_sess` (orig code+0x19c): current session ptr.
- `_icr_intr` outer Interrupt (orig code+0x632): type=2, pri=0,
  name="BFBPlay CIA timer.", is_Data=inner, is_Code=cause_tramp.
- `_inner_intr` (orig code+0x650): type=2, name=NULL,
  is_Data=0xbfe001 (CIAA_PRA), is_Code=_tick_dispatch.
