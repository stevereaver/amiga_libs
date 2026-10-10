# InitTable / InitStruct

dataSize 0x36.  Extended c/d/e InitStruct encoding:

- `e000 000c 0900` INITBYTE @0x0c = 9 - DEAD WRITE (inside ln_Name's
  4-byte field; overwritten by the following INITLONG - shipped bug)
- `c000 000a` INITLONG @0x0a -> ln_Name
- `e000 000e 0600` lib_Flags = LIBF_SUMUSED|LIBF_CHANGED (6)
- `d000 0014 0004` lib_Version = 4
- `d000 0016 0006` lib_Revision = 6
- `c000 0018` INITLONG @0x18 -> lib_IdString
- terminator

Function table: absolute longwords, {Open, Close(null), Expunge(null),
Reserved(null), Explode, -1}.
