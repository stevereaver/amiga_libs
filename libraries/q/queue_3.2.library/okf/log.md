# queue 3.2.library — work log

- Hunk parse: CODE 0x26b L (2476 B) + DATA 8 L + CODE 0x17 L (92 B),
  2836 B total. RomTag@h0+4, AUTOINIT v3, rt_Init -> h1+4.
- InitTable (h1+4): dsize 0x8c, functab -> h2+0 (13 absolute longs +
  ffffffff term), dtab=0, initfn -> h0+0x20.
- Full disasm: semaphore-guarded named-queue manager. 13 vectors;
  helpers _rechain(0x158), _rmvclear(0x1a0), _killnode(0x1c8),
  _bump(0x214), _initctx(0x24e), _restore(0x28e), _newlist(0x998).
- Transcribed verbatim to queue_h0.s/h1.s/h2.s; linker script orders
  hunks CODE/DATA/CODE; fixup.py restores reloc group order.
- Build: byte-identical first pass — MD5 25f7d1dffac56ba283b987358c18b92a.
- Oracle: machine68k, fake exec with real MinList/semaphore/heap
  semantics; exercised init, Open x2, all API vectors (create
  type-1/type-2/dup-attach, enqueue, dequeue both paths, killnode,
  flush, purge, item alloc/free, delete incl. last-ref teardown),
  AllocMem failure, deferred expunge — original vs rebuild traces
  identical, including the shared deferred-expunge invalid writes.
