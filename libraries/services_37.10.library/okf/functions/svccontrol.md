# SvcControl (-30, @0x220)

Signature (4 register args): name a0, str a1, out a2,
taglist a3.  `linkw a5,#-56`; 56 bytes of locals.

## Call sequence (as shipped)

1. Stack taglist: {0x800b1004 -> &t1out,
   0x800b1001 -> {0x7800,"Services"} blob, TAG_END}
   -> nipc -126 -> r1 anchor entity; NULL -> bail.
2. Stack taglist: {0x800b1101 -> 0x80,
   0x800b1102 -> 0x40, TAG_END}
   -> nipc -114 -> r2, a 256-byte request object;
   NULL -> destroy r1, cleanup.
3. If `out` non-NULL:
   a. buf = AllocMem(256, MEMF_PUBLIC|MEMF_CLEAR);
      if `name`: strcpy(buf, name).
   b. r3 = nipc -138(buf, "Services", r1, &code)
      (find/bind under the anchor).
   c. If r3: fill r2 --
      strcpy(str -> r2+0x2a); r2+0x6a = 0; r2+0x8a = 0;
      FindTagItem(0x80000803, tags) -> ti_Data string ->
      r2+0x6a; same for 0x80000804 -> r2+0x8a;
      r2+0x1c = 100 (u8); r2+0x42 = 10 (u16);
      nipc -150(r2, r1) submit; nipc -144(buf) release;
      code = r2+0x1e; if !code:
      r12 = nipc -138(buf, r2+0x36, out, &res2).
   d. FreeMem(r2, 256) -- the request object is an
      AllocMem block the caller frees.
4. nipc -120(r1) destroy anchor; nipc -132(tags) cleanup.
5. d7 = code ? code : res2;
   FindTagItem(0x80000802, tags) -> ti_Data = d7
   (error reported back through the caller's tag list).
6. return r12.

## Semantics

A service request: build an anchor entity (r1), allocate a
256-byte request object (r2), bind the named service under
"Services", copy the caller's tag-provided strings and the
request string into fixed fields, submit the transaction,
and propagate the result both via the caller's
0x80000802 tag and the return value of the second bind.
