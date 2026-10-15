# Packer ceiling = OutBuf + InLen; OutBufLen ignored

`XpksPackChunk` loads only three param longs
(`movem.l (a0),a1-a3` = InBuf, InLen, OutBuf) and computes the output
limit as `a4 = OutBuf + InLen`.  `xsp_OutBufLen` at +0x0c is **never
read** — the implicit contract is "RLE output is only worth it if it
fits in the input size".

Consequences:

- Emit checks (`a3 + litlen + 1 >= ceiling`, `a3 >= ceiling`) return
  **-17** whenever the stream would reach InLen bytes — i.e. the
  packer refuses to expand instead of overflowing OutBuf.
- **Incompressible input always fails**: an all-distinct chunk needs
  `1 + len + 1 > len` bytes, so it always trips the check (verified
  in `work/oracle.py` — 64 distinct bytes -> -17).
- **Zero-length input fails too**: the ceiling is OutBuf itself, the
  first emit check fires immediately -> -17 and `xsp_OutLen` is left
  untouched (1.4 emitted a one-byte terminator stream, OutLen=1).
- A caller passing `OutBufLen < InLen` can still be overflowed — the
  real buffer bound is never consulted.

Compare 1.4, which honoured OutBufLen (plus a conservative 4+litlen
reserve) and could produce expanding output.
