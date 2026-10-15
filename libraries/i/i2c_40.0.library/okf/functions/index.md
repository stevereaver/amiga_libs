# Functions

- LibInit — stores SysBase(+118)/seglist(+126), reads I2CDELAY env
  into +68 via dos GetVar+StrToLong (12-byte buffer inside the code
  hunk), InitSemaphore(+72), returns base. Skips env read silently
  if dos.library 36+ unavailable.
- LibOpen / LibClose / LibExpunge / LibNull — standard lifecycle;
  Open also claims the board and idles the bus.
- AllocI2C/FreeI2C — claim control (claimed@+134, shutdown@+136,
  laststat@+135).
- I2CDelay — get/set bus timing at +68.
- ResetBus — writes 3 to $de0080 iff claimed.
- SendI2C/ReceiveI2C — see algorithms/Transfer.md.
- I2CStatus — returns +130 (never initialized -> 0).
- I2CErrStr — packed code -> string via 17-entry index table.
- ShutdownI2C — temp-shutdown: claimed=0, shutdown=1, laststat=5.
- RestartI2C — shutdown=0, AllocI2C, ResetBus.
