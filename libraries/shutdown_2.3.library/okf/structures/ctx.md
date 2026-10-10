# structures

## SdBase (0xe0 bytes)
| off | field |
|-----|-------|
| 0x00 | `struct Library` |
| 0x24 | ExecBase |
| 0x2c | seglist |
| 0x30 | `struct Ctx` (embedded, 0xd8) |

## Ctx (at base+0x30)
| rel | field |
|-----|-------|
| +68 | dos.library base |
| +72 | utility.library base |
| +76 | flag byte |
| +120 | `struct MinList` hook list |
| +132 | `struct SignalSemaphore` sem1 (list) |
| +178 | `struct SignalSemaphore` sem2 (fire) |

## Hook node (AllocVec)
| off | field |
|-----|-------|
| +0 | `struct MinNode` linkage |
| +8 | `UBYTE *name` → inline buf |
| +12 | `APTR callback` |
| +16 | `UBYTE namebuf[]` name copy |
