# XpksUnpackChunk (-54)

ByteRun1 decoder (hunk+0x1cc).  `moveml (a0),a0-a2` loads
pb[0]=InBuf, pb[1]=InLen, pb[2]=OutBuf; a1 is folded into an end
pointer.  Loop: count byte n >= 0 copies n+1 literals; n < 0 writes
the next byte -n+1 times.  Stops when the input is exhausted —
**no output bound check at all**.  Returns 0 (zero-length input is a
no-op).  Does not write xsp_OutLen.

Parameters via `struct XpkSubParams` (a0).
