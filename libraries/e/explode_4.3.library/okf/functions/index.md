# Functions

| LVO | Symbol | Role |
|-----|--------|------|
| -6  | LibOpen | private open counter at base+0x2a |
| -12 | LibClose | null stub (shared) |
| -18 | LibExpunge | null stub (shared - never expunges) |
| -24 | LibNull | null stub (shared) |
| -30 | Explode | decrunch-and-run entry, inline packed data |

Internal: InitFunc (LoadSeg hook install), LoadSegStub/HookCount/
ByteCount (self-patched stubs), ExplodeFrame (asm->C shim).

- [Explode.md](Explode.md)
- [LoadSegHook.md](LoadSegHook.md)
- [InitFunc.md](InitFunc.md)
- [Standard.md](Standard.md)
