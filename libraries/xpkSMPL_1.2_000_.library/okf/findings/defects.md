# xpkSMPL 1.2 defects / inconsistencies

1. **inlen==0 pack wraps and crashes.**  The histogram loop uses
   `SUBQ.L #1,count / DBF` on `inlen-1`; inlen 0 wraps to 65536
   iterations, freq[0] wraps to 0, the sorted list stays empty,
   and the merge loop dereferences the null head->link (a5+4 link
   = 0).  Verified on the host model: segfault at head->link.
   (Same wrap applies to the data emit loop.)

2. **Output budget is `inlen/2 - 1` words.**  The packer refuses
   streams that don't halve the input (`-17`).  Incompressible
   data always fails -- intentional-ish for XPK (master tries the
   next sublib), but the bound is a word count of emitted words,
   not a byte bound on the output buffer.

3. **Lens >= 31 truncate into the nibble format.**  The escape
   `nibble 15 + nibble (len-15)` only reaches len 30.  A len-31
   code emits `15, 16` -- the second nibble's low 4 bits are 0,
   so the decoder reads len 15 and the stream desyncs.  (Codes
   >32 bits hit the roxr depth guard -> -17, but 31 and 32 slip
   through and corrupt silently.)

4. **Trie arena can overflow into the fast table.**  Unpack
   workmem is a flat 2048-byte node arena before the 2048-byte
   dectab; >511 interior nodes write past +2048 into the table
   region (both are live simultaneously) -- no bound check.

5. **Decoder reads up to 2 bytes past the compressed end** (the
   final `wr32` pad covers it) and `OutLen==0` wraps the DBF
   count to 65536 output bytes.

6. **PackFree leaves a stale xsp_Sub[0]** pointer after FreeMem;
   a second Pack/Unpack reuses the freed block without realloc.

7. **AllocMem(flags 0) -- uncleared workmem.**  Both routines rely
   on explicit clears; the pack histogram is cleared by the code,
   but the node arena/link fields are not.

8. **-36 arg-block fetched via saved d7** (XPK master convention);
   reconstruct notes the same pointer arrives in a0 and the
   stashed register.
