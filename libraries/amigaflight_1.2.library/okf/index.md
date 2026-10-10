# amigaflight.library 1.2 (BETA) -- OKF Index

- **Binary:** `binary/amigaflight_1.2.library` (1256 bytes, single code hunk, 1068-byte hunk image)
- **sha256:** `75a29d744eef82b0...`
- **ID string:** `AmigaFlight BETA 1.2 (12.06.94)\r\n`
- **RomTag:** `RTF_AUTOINIT`, version 1, `NT_LIBRARY`, pri 0
- **Library base (dataSize 0x30):** Library header + SysBase@+0x24, dos.library base@+0x28, seglist@+0x2c
- **Dependencies:** `dos.library` (opened at init, closed at expunge), `exec.library`
- **Reconstruction:** `source/` builds with `m68k-amigaos-gcc -m68000`

## Purpose

Console hex-I/O support library for the AmigaFlight debugger
frontend. Every public vector takes a dos filehandle in `a1`
(the caller's console handle) and routes through `dos.library`:
`FGetC`, `WaitForChar`, `FPutC`, `FPuts`, `Flush`. Every output
primitive `Flush`es after every single write -- slow but
interactive-safe for a debugger monitor.

## Public vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | refuses open when version arg < 1, returns the arg itself |
| -12 | LibClose | decrements OpenCnt; expunges if DELEXP pending |
| -18 | LibExpunge | Remove + CloseLibrary(dos) + FreeMem |
| -24 | LibNull | returns 0 |
| -30 | AFHexValue | hex char -> nibble, carry set on bad input |
| -36 | AFNewLine | emits LF then CR (reversed order) |
| -42 | AFEnterAddress | `Enter Address :` prompt; odd values rejected; result in a0 |
| -48 | AFGetChar | FGetC; maps 0x9b (CSI) to 0 |
| -54 | AFGetHexChar | read + echo + uppercase + hexvalue |
| -60 | AFCharAvail | WaitForChar(handle, 1) |
| -66 | AFReadHex | digits -> d1 value / d2 count / d0 terminator; always exits carry-set |
| -72 | AFPutChar | FPutC + Flush |
| -78 | AFPutNibble | one hex digit |
| -84 | AFPutByte | two hex digits |
| -90 | AFPutWord | four hex digits |
| -96 | AFPutLong | eight hex digits |
| -102 | AFPutString | FPuts + Flush; **string arg in d2** |
| -108 | AFPutSpace | one space |
| -114 | AFPutSpaces | n spaces |
