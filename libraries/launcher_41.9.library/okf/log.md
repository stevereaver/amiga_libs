---
type: Log
title: launcher 41.9 work log
---

- HUNK_HEADER: tablesize 2, hunk0 CODE 0x313 longs, hunk1 DATA
  0x12 longs.  Resident at h0+4; rt_Init->h1+0x38 (cross-hunk).
- functab h1+0x1e, 5 absolute longs: 0xa5e/0xbda/0xb6e/0xc26/0x4b6;
  initfn h0+0x9f2; datasize 0x64; datatab NULL.
- Verbatim transcription: raw head 0x4..0x50 and mid-code data
  0x2f0..0x31e.  One gap fix: objdump's linear sweep swallowed
  `9efc` at 0x50 inside a data-region token -> emit gap bytes when
  a token overshoots a data boundary.  `pea %pc@(x)` forced to
  .short (gas picks brief-ext form otherwise).  H0/H1 bodies
  byte-identical; fixup splices header + reloc tails; make cmp
  passes BYTE-IDENTICAL.
- Oracle (machine68k): initfn -> taggedopen dos.library;
  open x2 -> semaphore + spawn (findtask/dos-498/setsignal/putmsg/
  wait); close/deferred-expunge -> real expunge
  (closelib/remove/freemem); extfunc 0; launch fn -> icon
  GetDiskObjectNew/FindToolType + dos lock/newproc/str helpers +
  allocmem + putmsg to server port; taskentry -> findname/
  waitport/getmsg/exec-666; final expunge -> deferred
  signal(proc,0x1000)+DELEXP.  orig.log == rebuilt.log.
