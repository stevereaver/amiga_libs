# xpkZENO 1.1 — defects and quirks

All reproduced faithfully in the reconstruction.

## Defects

1. **UnpackFree under-frees by 4 bytes.**  The -60 routine
   recomputes `4*Tsize+4` while the unpacker allocates
   `4*Tsize+8`.  Verified under the oracle: free size 32772
   vs alloc size 32776 at 13 bits.

2. **Header pad bytes are never written.**  `namelen` pad
   bytes between the header and the code stream are skipped
   (`addal d1,a1`), so they carry stale outbuf content into
   the emitted stream.  Harmless because the decoder skips
   them, but makes streams buffer-history-dependent.

3. **data&3==3 first-code path loses a bit.**  The decoder's
   aligned-start path computes `(L<<1)&0x1ff` for the first
   code and reads the next long's top bit into d0 — then
   discards it.  Unreachable for packer-produced streams
   (data is always long-aligned) but a real decode bug for
   hand-crafted headers.

4. **AllocMem-fail retry uses the stale mode.**  On pack
   alloc failure the mode byte is rewritten (>=67->50,
   34..66->0) but the retry re-enters at 0x554 which uses the
   just-read OLD mode — so the first retry allocates the
   same (failing) size again; the downgrade only lands on
   the next failure.  An identical orphan block at 0x5bc is
   unreachable dead code.

5. **`xsp_Password` dereferenced unconditionally** in the
   packer (`tst.l (a1)`) — NULL would bus-error.

6. **Password checked only once per session.**  The unpacker
   only validates the stream hash while `Sub[0]==0`; after a
   successful init, subsequent chunks ignore the password.

7. **Decoder can overshoot the output bound by <=12 bytes.**
   The emit-bound check runs only for codes <=0x101; dict
   strings spill past `outbuf+xsp+16`, and the end check
   tolerates `produced-12 <= bound`.  Writes beyond the
   declared output span are possible on hostile streams.

8. **Unwind stack shares the output buffer.**  The string
   stack descends from `outbuf + xsp+12` — if the caller
   sets OutBufLen <= produced length, stack pushes corrupt
   emitted output at the tail (verified: 3-byte corruption
   at 1021..1023 for rnd1k with field12 = len).  Earlier
   suspected as a codec desync — it is a caller-contract
   artifact, identical in both binaries.

9. **First code emits its low byte blindly.**  `moveb d4,a3@+`
   writes `(UBYTE)code` even if the first 9-bit code is >=256.

10. **Dead "15 bit" mode record** at 0xbc in the old 30-byte
    format — unlinked from the mode chain (ends at the
    "14 bit" record).  Along with the unused 0x87f7 modulus
    slot and the 0x1003.. table's 15-bit entry, evidence of
    a dropped 15-bit mode.

11. **Dead/unreachable code:** the orphan fallback at 0x5bc;
    the `next long >> 31` read at 0x6f4; LibInit's fixup loop
    (count always 0); the Sub[1]=0 store immediately before
    Sub[1]=T_char in the unpacker init; the "Sub[0]!=0 ->
    skip init" check in pack which can never see the unpack
    alloc layout correctly (pack and unpack share Sub slots
    with incompatible meanings — calling pack after unpack
    on the same xsp is unsafe, matching shipped behavior).
