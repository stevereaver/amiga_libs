# xpkMASH.library 1.98 (020) — quirks and defects

1. **Tiny-input failure leaves OutLen unwritten.** `XpksPackChunk` with
   InLen < ~4 returns rc=-17 and never stores `xsp.OutLen`, so callers read
   whatever garbage was in the param block (the oracle sees the OutBuf
   pointer leaked through). Original and rebuild behave identically.

2. **Mode parameter ignored.** Modes 0 and 100 produce bit-identical
   output for every tested input; the mode field is carried but unused by
   the match engine.

3. **Matcher reads beyond InLen.** The match loop performs deterministic
   out-of-bounds reads past the input buffer (oracle pads INBUF so results
   are reproducible). Harmless but worth noting for reimplementations.

4. **Functab carries three alias null stubs** (-42/-48/-60 all point to
   the same `moveq #0,d0; rts`) and -24 is a separate identical stub.

5. Code hunk embeds the whole XPK info/mode tables after the code tail;
   no separate DATA hunk.

Verified: rebuild byte-identical (MD5 b92fd3db12b87e806f85949130439ef0);
oracle report + 40 pack/unpack streams identical between original and
rebuild (run in separate processes — machine68k trap IDs are global).
