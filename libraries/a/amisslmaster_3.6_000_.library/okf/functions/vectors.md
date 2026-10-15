---
file: vectors
---
# Vectors

9 LVOs (-6 .. -54), absolute functab @h0+0xa04 ->h0:

| LVO | target | role |
|-----|--------|------|
| -6  | +0xec  | Open — returns per-open context (lib+0x22 offset ptr) |
| -12 | +0x232 | Close |
| -18 | +0x29e | Expunge |
| -24 | +0x0   | Reserved ->h0+0 stub |
| -30 | +0x474 | child-lib open/dispatch |
| -36 | +0x496 | |
| -42 | +0x688 | exec -564/-570 pairs observed (ObtainSemaphore/ReleaseSemaphore on the open path) |
| -48 | +0x734 | |
| -54 | +0x8fc | |

initfn@h0+0x20: AllocMem(16) private state. User vectors hit exec
-564/-570 (Obtain/ReleaseSemaphore) on a lib+0x90 semaphore —
serialized access to the AmiSSL child handle table.
