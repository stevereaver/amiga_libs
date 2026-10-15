# i2c.library 40.0

- **Binary:** `binary/i2c_40.0.library` (1516 bytes, single CODE hunk 0x156 lw)
- **Identity:** `i2c.library 40.0 (09 Dec 21) for Apollo Core boards` — Apollo/Vampire I2C bus driver
- **RomTag:** packed layout at hunk+4; RTF_AUTOINIT, ver 40, NT_LIBRARY, pri 0; no `$VER:`
- **InitTable:** dataSize 0x89 (137), LONG functab (14 vectors), initRoutine = LibInit
- **Module entry:** `moveq #10,d0; rts` — returns 10 (quirk, reproduced)
- **Reconstruction:** `source/i2c_lib.s` (skeleton+tables), `source/i2c.c` (all logic)

## Vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | OpenCnt++, clears delayed-expunge bit, then AllocI2C + ResetBus |
| -12 | LibClose | FreeI2C, OpenCnt--, delayed expunge if armed |
| -18 | LibExpunge | Remove+FreeMem base; arms bit3@+67 if open |
| -24 | LibNull | returns 0 |
| -30 | AllocI2C | semaphore'd board claim; ret 0 ok / 5 shutdown |
| -36 | FreeI2C | drops claim+shutdown when OpenCnt==1 |
| -42 | I2CDelay | d0<0 query / d0>=0 set base+68; returns old |
| -48 | ResetBus | writes 3 (SDA+SCL hi) to $de0080 if claimed |
| -54 | SendI2C | addr(d0)|W + d1 bytes from a1; packed result |
| -60 | ReceiveI2C | addr(d0)|R + d1 bytes to a1; packed result |
| -66 | I2CStatus | returns base+130 — never written, always 0 |
| -72 | I2CErrStr | packed error code -> static string |
| -78 | ShutdownI2C | set shutdown, drop claim, laststat=5 |
| -84 | RestartI2C | clear shutdown + AllocI2C + ResetBus |

(Function names inferred; no fd/autodocs shipped with the binary.)

## LVO usage

exec: OpenLibrary -552, InitSemaphore -558, ObtainSemaphore -564,
ReleaseSemaphore -570, Remove -252, FreeMem -210, CloseLibrary -414.
dos: GetVar -906 ("I2CDELAY"), StrToLong -816.

## Hardware model

- `$de0080` (word): Apollo I2C control. Write bit0=SDA out, bit1=SCL.
- `$de0081` (byte): bit0 = SDA in.
- `$bfd000` (byte): CIAA PRA, read-and-discard timing reference.

See `algorithms/Transfer.md`, `structures/I2CBase.md`,
`findings/defects.md`.
