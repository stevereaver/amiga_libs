# XpksUnpackChunk (-54, @0x2f8)

    a1 = xsp_OutBuf, a0 = xsp_InBuf
    d1 = moveq #-1      (upper word 0xffff -- sign extension)
    d4 = 7              (unrolled-copy mask)

Loop:
- `movel a0@+,d2` -- next flag long.
- flag == 0 -> copy 32 literals as 8 `movel` (always reads
  the full 32 bytes).
- else d0 = 31; per item `lsrl d2` -> carry:
  - 0 -> `moveb a0@+,a1@+` literal
  - 1 -> `movew a0@+,d1`: word 0 -> done (return 0).
    `lea a1@(0,d1:l)` -- d1 keeps its 0xffff upper word, so
    the 16-bit token sign-extends: a2 = a1 + (tok-0x10000)
    = a1 - dist.  `moveb a0@+,d1; addqw #4` -> len 4..259;
    byte 0 -> len 4 via the computed-goto unrolled copy.
- dbf d0 continues the group.

No output bound check -- the decoder trusts the stream and
never writes xsp_OutLen.
