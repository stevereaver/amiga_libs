# lh.library 1.8 -- vectors

All public vectors take `a0` = handle (see structures/layout.md).
Encoder/decoder return the produced output length in `d0` and store it
to handle+12. Zero on validation failure.

## -6 Open (0xf4)
`opencnt++`, `bclr #3,lib_Flags` (clears deferred expunge), returns a6.

## -12 Close (0x102)
`opencnt--`; when it reaches 0 and flag bit 3 set, falls into Expunge.

## -18 Expunge (0x116)
If opencnt != 0: set flag bit 3 (deferred) and return 0. Otherwise
unlinks itself with a hand-inlined `Remove` (pred/succ fixup, no exec
call), frees `NegSize+PosSize` bytes, returns the seglist read from the
data cell at h0+0xe8 via `movel pc@(0xe8),d0`.

## -24 (0x14e)
`moveq #0,d0; rts` -- unused stub.

## -30 AllocHandle (0x152)  d0 = small-model flag
Saves d2/a2/a6, loads a6=AbsExecBase. Model size = 4500 if d0!=0
(decode), 40000 if d0==0 (encode). AllocMem(size, MEMF_PUBLIC|CLEAR);
then AllocMem(28, same) for the handle; on handle failure frees the
model and returns 0. Stores model@+16, size@+20, returns handle.

## -36 FreeHandle (0x1aa)  a0 = handle
NULL-safe. `pea a6@; pea a0@` then FreeMem(model, size) and
FreeMem(handle, 28) via a6=AbsExecBase; restores a6 from the stack.

## -42 Encode (0x1ce)  a0 = handle
Validates: handle != 0, handle+20 >= 40000, handle+0/+4/+8 != 0.
Tail-jumps `jmp 0x628:l` (relocated) into the encode engine.

## -48 Decode (0x1f6)  a0 = handle
Validates: handle != 0, handle+0 != 0, handle+8 != 0 (no size check --
the 4500B decode model is assumed). Tail-jumps `jmp 0x210:l`.

## Codec engine internals

- Decode entry 0x210: `bsr _dinit` builds the adaptive model in the
  4500B work buffer (tree arrays at +634/+1902/+3168/+3802, root at
  +1264), then walks the bitstream: tree descent via `addw d6,d6` bit
  shifts with dbmi refill at 15 bits. Symbols >= -512 are literals
  (emit d7 byte); -634 < d7 < -512 are position codes decoded through
  the packed table at 0x428 plus extra bits; d7 <= -634 is the end
  marker -> rts with a1 = output end.
- Match copies dispatch via `jmp pc@(0x7e,d7:w)` (bytes 4efb 707e)
  with negative d7 landing mid-instruction in the 60x unrolled
  `moveb a2@+,a1@+` copy loop at 0x22c -- entry depth selects the copy
  count (max 60).
- Encode entry 0x628: `bsr _einit` builds the 40000B model (adds
  symbol/freq/pos arrays at +4434/+12506/+12746/+16902/+20940/+25094/
  +29134/+29646, hash tables pre-filled with 0x2000/8192 sentinels),
  reads src[0..+4 length) into a 60-entry lookahead buffer, then emits
  adaptive-Huffman codes via `_eput` (bit or-accumulator writing words
  to dst) and updates the model via `_eupd`/`_ematch` (binary search
  tree keyed on 3-byte hashes, max match 60, longest-match tracking in
  +25094). Stream terminator = symbol 316. d7 tracks free bits in the
  current dst word; on encode exit d7==16 means no partial word, else
  dst end is bumped by 2.
