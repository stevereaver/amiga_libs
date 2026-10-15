# XpksPackChunk (-36)

ByteRun0 encoder (hunk+0x110).  `moveml (a0),a1-a3` loads
pb[0]=InBuf, pb[1]=InLen, pb[2]=OutBuf; a4 = OutBuf+InLen is the hard
output bound — **xsp_OutBufLen is ignored**.  On bound violation it
returns -17 and leaves xsp_OutLen untouched; on success
xsp_OutLen(pb[4]) = produced length, returns 0.

Encoding per run:

- repeat run (>=3 equal bytes, detected via a 3-eq streak + 4th-byte
  check, look-ahead capped at 125 by d2): emits count byte
  -(len-1) then the byte value.
- literal run: emits len-1 then the bytes verbatim.

So `AAABBBCCC!!!!    ` packs to `\xfeA\xfeB\xfeC\xfd!\xfd ` and
200x 0x5a packs to `\x81\x5a\xb9\x5a` (128+72).  Zero-length input
returns -17 (the literal scanner reads ahead unconditionally and the
bound is hit immediately).

Parameters via `struct XpkSubParams` (a0), library base a6.
See `source/xpkCBR0_h0.s` for the verbatim instruction flow.
