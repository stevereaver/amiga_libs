# LibClose (LVO -12)

```
moveq  #0,d0
subqw  #1, lib_OpenCnt
bne    ret
btst   #3, lib_Flags      ; LIBF_DELEXP
bne    ret                ; always returns anyway
ret: rts                  ; d0 = 0
```

**Quirk:** the DELEXP test is dead code -- the function returns
0 whether or not the bit is set, and never chains into Expunge.
Once a client opens and closes, the library can only be removed
by an explicit Expunge call.  See findings/Quirks.md.
