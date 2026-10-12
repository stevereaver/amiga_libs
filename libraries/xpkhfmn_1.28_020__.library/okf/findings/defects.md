# xpkHFMN 1.28 — quirks / defects (all reproduced faithfully)

1. **No emit bounds check (packer).** Unlike 1.4, which aborts when the
   output cursor reaches `out+inlen`, 1.28 writes tree/data bits
   unbounded and only compares `OutLen <= xsp_OutBufLen` at the very
   end — an oversized stream already scribbled past the buffer before
   -17 is returned.

2. **Unconditional Expunge.** The -18 vector never checks `OpenCnt`;
   a direct expunge while open frees the library anyway. Deferred
   expunge still works via Close's DELEXP test.

3. **treeLen mask `& 0x1ff`.** The unpacker skips the tree with
   `adda.w (treelen & 0x1ff), a0` — a tree longer than 511 bytes would
   land the inlen read mid-tree. Unreachable in practice (max tree
   ≈320B).

4. **u16 inlen truncation.** The packer writes `move.w d7` and the
   generated decoder counts with `subq.w/dbf` — inlen > 65535 wraps;
   consistent with MaxPkInChunk=0xffff.

5. **Generated-code/stack overlap.** For pathological trees (near-max
   internal count AND deep stack), emitted code (~6KB worst case) can
   overrun into the fixup stack at wm+0x13fa — no guard.

6. **Depth byte wrap.** Leaf `moveq #depth` and the `sub.b` debit use
   byte math; depth ≥ 256 would wrap (needs a degenerate ~256-deep
   tree; impossible with 256 symbols — max depth 255, and sign-extended
   moveq values still debit correctly via `sub.b`).

7. **inlen=0 underflow.** The histogram `dbf` wraps to a 64KB scan and
   the phantom-tree path dereferences heap[1]=0 — MinPkInChunk=12
   guards real use; XPK never calls with 0.

8. **`addq.b` serial wrap** — same bound, unreachable.

9. **Dead data in the image**: the vestigial `1a0a/19fa` words at
   code+4 and the 20-byte example generated-code sample at 0x578.
