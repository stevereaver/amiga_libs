# Structures

## SvcBase (dataSize 0x9a = 154)

| off | field |
|-----|-------|
| +0x00 | struct Library (34 bytes) |
| +0x22 | APTR nipc -- nipc.library base (lazy-opened) |
| +0x26 | APTR utility -- utility.library base |
| +0x2a | struct ExecBase *SysBase |
| +0x2e | BPTR seglist |
| +0x32 | struct SignalSemaphore (34 bytes) |
| +0x60 | struct List -- 342-byte nodes, freed at expunge |
| +0x6c | struct SignalSemaphore -- serialises nipc open |
| +0x8e | pad to 0x9a |

## Request object (nipc -114 result, 256 bytes)

Fields touched by SvcControl:

| off | contents |
|-----|----------|
| +0x1c | u8 = 100 |
| +0x1e | ULONG result code (read back) |
| +0x2a | char[] -- request string (str arg) |
| +0x36 | entity ref reused by the second nipc -138 |
| +0x42 | u16 = 10 |
| +0x6a | char[] -- caller tag 0x80000803 string |
| +0x8a | char[] -- caller tag 0x80000804 string |

## Tag constants

nipc-126: 0x800b1004 -> &out; 0x800b1001 -> {0x7800,"Services"}.
nipc-114: 0x800b1101 -> 0x80; 0x800b1102 -> 0x40.
caller list: 0x80000802 <- result; 0x80000803/804 -> strings.
