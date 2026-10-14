# queue 3.2.library — OKF index

## Identity

| field    | value                                                             |
|----------|-------------------------------------------------------------------|
| libname  | `queue.library`                                                   |
| version  | 3.2 — `"queue.library 3.2"` (no `$VER:` prefix)                   |
| size     | 2836 bytes                                                        |
| format   | hunk: CODE(2476 B) + DATA(32 B) + CODE(92 B: functab+strings)     |
| resident | AUTOINIT (`rt_Flags = 0x80`), rt_Init -> h1+4 InitTable           |
| purpose  | Shared named-queue manager: semaphore-protected bidirectional node lists keyed by queue name; clients create/attach queues by name, enqueue typed nodes (message/data), dequeue, and register signal-based waiters. |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target (vbcc-style
  compiled C: `subqw`/`subaw` frames, `movel a6,sp@(N)` libbase
  stash/reload around exec calls, exec calls via `moveal 4:w,a6`).
- **Source**: `source/queue_h0.s` (all code), `source/queue_h1.s`
  (DATA: InitTable embedded at +4 plus the 28-byte runtime template),
  `source/queue_h2.s` (absolute-long functab + name/idstr + trailing
  `"ad"` bytes), `source/Makefile` + generated `hunks.x`,
  `source/fixup.py` (restores the original linker's RELOC32
  grouping/order).
- **Result**: `queue.library` byte-identical to the original
  (MD5 `25f7d1dffac56ba283b987358c18b92a`).
- **Runtime**: `work/oracle.py` — identical traces for init, header
  fields, ctx copy + fixup, Open/Close/deferred Expunge, queue
  create/attach (dup-name refcount), enqueue, dequeue (type-1 walk and
  type-2 RemHead paths), waiter kill, list walk, type-10 cleanup,
  item alloc/free, delete (incl. last-ref teardown), AllocMem failure,
  and the deferred-expunge tail writes.

## Docs

- `functions/vectors.md` — all 13 vectors and internal helpers.
- `structures/layout.md` — hunks, library ctx, queue hdr/node, item.
- `findings/quirks.md` — literal-reloc name fields, dead code, overlap.
- `log.md` — work log.
