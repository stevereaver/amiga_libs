# Defects / quirks found

1. **Stale `Sub[0]` after free** — `XpksPackFree` (-42) frees the
   work block but never clears `xsp_Sub[0]`. A subsequent PackChunk
   would reuse the dangling pointer (alloc check `TST.L 52(a3)`
   passes, so no realloc). Same quirk class as xpkSQSH.

2. **Mode-change alloc mismatch** — PackChunk allocates workmem
   sized for the *first* mode used and only reuses it later. Packing
   the same `xsp` with a larger `bits` afterwards writes the chain
   ring past the earlier (smaller) allocation.

3. **Decoder fully trusts the stream** — UnpackChunk has no input
   bounds check; a malformed stream over-reads the input and can
   write past `out+outlen` via match copies. A `count==0` literal
   run (`'1' 0[8] 0[12]`) underflows `d6` to -1 and iterates ~64K
   times (DBF), reading far beyond the input.

4. **Lookahead over-reads (packer)** — the extension check
   `cur[len] == cand[len]` reads `in[cur+bestlen]` where bestlen can
   reach `min(0x101, remaining)` = one past the input end; the hash
   insert also reads `cur[0..2]` for each of `len` positions, up to
   2 bytes past the end on tail matches. Benign with the usual
   xpk chunk slack.

5. **Exact-fit output counts as overflow** — the emit flushes the
   byte *then* checks `out >= outend`; filling the output buffer
   exactly still returns **-17**.

6. **-24/-60 vectors wrap to the entry stub** (`moveq #0,rts`
   at 0x20 via negative offset -0x94) — same quirk as siblings.

7. **PackReset restores d1-d7/a2-a6 but not d0** — returns with
   d0 = -1 (leftover DBF counter); harmless, callers ignore it.

## Stream format notes

- Token values are emitted LSB-first and the decoder collects
  LSB-first, so all fields pass through verbatim. The first byte
  holds the window bits (2..13).
- `len-2` field is 8 bits, so max match = 257 = the `0x101` cap.
- Literal-run escape `('1' 0[8] cnt[12])` pays off at >=21 literals
  (21+8n < 9n when n>21; break-even at 21).
