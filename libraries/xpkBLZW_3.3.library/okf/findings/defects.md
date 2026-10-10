# xpkBLZW 3.3 -- defects & quirks (all shipped behavior)

1. **Hash-table OOB.**  key = ((byte<<7)^prev)&0xffff can reach
   0xffff, i.e. record index up to 0x5fffa -- but the table is
   only 0x3c006 bytes (0xa001 records).  Keys >= 0xa001 read,
   probe and INSERT into memory past the AllocMem'd workmem
   (up to ~128 KB beyond).  Whether the original corrupts data
   depends on what the heap holds after the block.  The
   reconstruction reproduces the identical address arithmetic;
   on-target it shares the defect.

2. **PackFree frees unconditionally.**  XpksPackFree/
   XpksUnpackFree call FreeMem(xsp_Sub[0], xsp_Sub[1]) with no
   NULL check -- FreeMem(0, stale-size) if called before any
   pack, or twice (ptr is cleared but size is not).

3. **divu.w on 16-bit produced-delta.**  The ratio check's
   divisor is the low word of the produced byte count; a delta
   of 0x10000 makes the divisor 0 -> divide-by-zero trap.

4. **Word-0 ambiguity.**  At table-freeze the packer writes
   header word0 = 15; at tail it only writes word0 if the word
   is still zero -- so a mid-stream write could theoretically
   also satisfy "nonzero".  In practice only the freeze writes
   it.

5. **Decoder stack bound.**  Stack region = maxstrlen & ~3
   (rounded down); safe only because maxstrlen is stored
   biased +4 (d1 starts at 4), so realmax+4 & ~3 >= realmax.

6. **No input bounds checks in the decoder.**  rd_code reads
   4 bytes at the cursor unconditionally; a truncated/corrupt
   stream reads past the input buffer.

7. **Open/Close asymmetry.**  LibClose only expunges when the
   open count reaches zero; the original Expunge fall-through
   is used.  Standard SAS/C-style pattern, kept.

8. **PackReset is a null stub** (-48 -> moveq #0,d0/rts) even
   though pack state lives in xsp_Sub[] and would persist.
