# I2CBase (dataSize 0x89 = 137)

| off | field |
|-----|-------|
| +0  | struct Library (34B; +32 OpenCnt, +16 NegSize, +18 PosSize) |
| +34 | ULONG send-op count |
| +38 | ULONG bytes sent |
| +42 | ULONG recv-op count |
| +46 | ULONG bytes received |
| +50 | ULONG not-claimed errors |
| +54 | ULONG NACK-on-address errors |
| +58 | ULONG partial-send (mid NACK) errors |
| +62 | ULONG echo-mismatch errors |
| +66 | UBYTE cfg = 3 (datatab; never read by code) |
| +67 | UBYTE flags, bit3 = delayed-expunge |
| +68 | ULONG delay (I2CDELAY env; GetVar+StrToLong) |
| +72 | SignalSemaphore (46B) — transfer lock |
| +118| ExecBase * |
| +122| ULONG reserved |
| +126| seglist (saved for Expunge) |
| +130| ULONG — never written; I2CStatus() returns it (always 0) |
| +134| UBYTE claimed |
| +135| UBYTE laststat (last AllocI2C result) |
| +136| UBYTE temp-shutdown flag |
