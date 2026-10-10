# shutdown.library 2.3

**sha256** `67b5561822f9fbf45da422490077158ccefce69083341a5d1a696bc04462fb7a` — 1,456 bytes, 3 hunks (SAS/C manual-init far-data)

## Purpose
Shutdown-hook registry: each opener gets a context (at base+48, dataSize 0xe0) holding lazily-opened dos/utility bases, two SignalSemaphores and a MinList of named hook nodes. Tasks register named callbacks to run at shutdown; the registry can then fire them all.

## API (FUNCTABLE, LONG-address, 8 vectors)
| off | fn |
|-----|----|
| -6  | LibOpen — init context (open dos+util, init sems+list) |
| -12 | LibClose — cleanup context, DELEXP deferred expunge |
| -18 | LibExpunge — Remove+FreeMem, return seglist |
| -24 | Reserved (entry stub) |
| -30 | `sdStub` — no-op, returns 0 |
| -36 | `RegisterShutdown(callback@a0, name@a1)` → node |
| -42 | `UnregisterShutdown(node@a0)` → 1/0 |
| -48 | `FireShutdown(flags@d0)` → AttemptSemaphore + run hooks |

## Layout
- RomTag: ver 2, NT_LIBRARY, AUTOINIT
- datatab: ver 2, rev 3, idstring `shutdown.library 2.3`
- dataSize 0xe0: base(0x30) + Ctx(0xd8)
- Ctx: +68 dosbase, +72 utilbase, +76 flag, +120 MinList, +132 sem1, +178 sem2

## Source
`source/shutdown.c`, `source/shutdown_lib.s`, `Makefile`. Reconstruction is a functional equivalent — the original is a SAS/C manual-init far-data build; this uses a standard AUTOINIT skeleton.
