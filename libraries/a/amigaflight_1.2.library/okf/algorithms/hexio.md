# Hex I/O pipeline

```
AFEnterAddress
  +-- AFPutString  : FPuts + Flush
  +-- AFReadHex    : loop AFGetHexChar
  |     +-- AFGetChar    : FGetC, 0x9b -> 0
  |     +-- AFPutChar    : FPutC + Flush  (echo before validate)
  |     +-- uppercase    : 'a'-'z' -> -32
  |     +-- AFHexValue   : '0'-'9','A'-'F' -> nibble, else C=1
  +-- terminator != 13 -> bell + LF/CR + reprompt
  +-- value & 1       -> "INVALID ADDRESS" + bell + LF/CR + reprompt
  +-- return a0
```

Output formatting:

```
PutLong -> swap -> PutWord x2 -> rorw -> PutByte x2
                                   -> roxr -> PutNibble x2
                                            -> PutChar
                                            -> FPutC + Flush
```

Every character costs two dos calls (FPutC + Flush) plus the
call-chain overhead -- hex dumps of a few hundred bytes are
noticeably slow, which suits a debugger console.
