---
file: vectors
---
# Vectors

functab @h0+0x70, absolute longs, 7 slots + ffffffff:
-6 Open 0x198 | -12 Close 0x1b0 | -18 Expunge 0x1e6 |
-24/-30 reserved stubs 0x26a (identical targets) |
-36 WBStart 0x2b8.

WBStart launches a 'WBStart Handler' proc via dos
CreateNewProc, message-port handshake, then runs Workbench
programs (GetDiskObject/NewLoadSeg/CreateNewProc), cli
CommandDir via dospath.library. Handler signals shutdown via
0x1000. Same vector targets as wbstart_2.2.
