# lh.library 1.8 -- quirks and defects

1. **Seglist cell inside the datatab tail.** The initfn
   `movel a0,0xe8:l` writes the seglist into a long parked between the
   InitStruct terminator and the initfn itself (h0+0xe8). The
   `movel a0,abs.l` operand is relocated so the target is hunk-relative.
   Expunge reads it back pc-relative (`movel pc@(0xe8),d0`).

2. **rt_EndSkip is relocated and points at a pad word (0x20e) inside
   the code.** Not a defect (resident scanning already matched), but
   unusual -- the value is a hunk offset, not an absolute address.

3. **RELOC32 order is not sorted.** The single group lists the two
   `jmp abs.l` operands in the validate vectors (0x206, 0x1ee) first --
   i.e. *descending* program order -- followed by the header/table
   relocs ascending. Suggests the original object was linked from a
   tool that emitted relocs in a non-source order (asm68k/hand-roll?).
   fixup.py reproduces the exact order.

4. **Mid-instruction jump dispatch.** Decode match handling does
   `jmp pc@(0x7e,d7:w)` with negative d7, landing in the middle of the
   60x unrolled `moveb` copy loop (entry depth = copy count) -- and
   nominally could reach the `rts` at 0x22a/loop head for the extreme
   d7 values.

5. **Inlined Remove in Expunge.** The library does not call exec
   `Remove`; it hand-writes the 4-instruction pred/succ unlink, saving
   an exec jsr.

6. **Encode over-validation, decode under-validation.** -42 checks
   bufsize >= 40000 and three handle fields; -48 only checks handle and
   two fields -- a decode handle built with the wrong buffer size would
   pass validation and corrupt memory.

7. **No NULL/short-buffer guards inside the codec.** Handles with
   garbage-but-nonzero fields sail through validation; the engines
   trust +0/+8 as real pointers.

8. **Byte-level output granularity.** Both engines return the produced
   byte count via handle+12 and d0; encoder flushes the pending 16-bit
   word when d7 < 16 (addql #2,a1 covers the final partial word).
