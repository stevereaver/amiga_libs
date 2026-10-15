---
file: vectors
---
# Vectors (31 abs-long @h0+0x8c, LVO -6..-186)

-6 Open +0x148 (opencnt@lib+0x20++, clears DELEXP, exec@lib+0x22,
InitSemaphore lib+0x2e) | -12 Close +0x174 | -18 Expunge +0x188
(seglist from hunk+0x13c, Remove+FreeMem) | -24 +0x1ca ret 0 |
-30 +0x1ce open array of libraries (a0 name-ptr list, a1 vers,
AllocVec, exec OpenLibrary each) | -36 +0x242 close array
(CloseLibrary+FreeVec) | -42 +0x26c create commodity object
(AllocVec 68, CreateMsgPort, openlib commodities, CxObj init) —
DEFECT: builds its 26B init block at lib-26 over the jump table |
-48 +0x32e wait/dispatch cx msgs (Wait/GetMsg/ReplyMsg + handlers
at h+48..64) | -54 +0x422 delete cx object | -60 +0x460 create
screen context (AllocVec 160, openlib intuition+graphics, gfx
-30/-342/-606/-636/-918/-924, int -606, user cb a0) |
-66 +0xa60 claim misc.resource units 2+3 ('htc\x97' magic, mask
lib+0x2a) | -72 +0xbb0 release claim | -78 +0xc28 set bits —
writes CIA regs @0xbfd000 | -84 +0xca0 query bits (ret -1 bad
magic) | -90 +0xce0 set/reset bits w/ CIAB dance |
-96 +0xd56 ring buf create (AllocMem n+28) | -102 +0xd96 free |
-108 +0xdb2 put byte | -114 +0xdde get byte | -120 +0xe06 write
block | -126 +0xe42 read block | -132 +0xe74 text extents via
graphics v36 | -138 +0xfa4 timer ctx create ('mfTH' magic,
MsgPort+IORequest+OpenDevice timer.device) | -144 +0x1020 free |
-150 +0x1064 WaitIO wrapper | -156 +0x1084 device -66 call |
-162/-168/-174/-180 +0x10f8/+0x1124/+0x1150/+0x117c semaphore-
guarded wrappers calling own -108/-114/-120/-126 |
-186 +0x10b4 SendIO timer req (cmd 9 TR_ADDREQUEST).

Debug helper +0x11a8: opens dos v37, GetVar "MFLIB_DEBUG",
"ser"/"req" modes, prints "multifunction.library %ld.%ld: " via
RawDoFmt + exec -516 raw putchar; +0x1280 intuition EasyRequest.
