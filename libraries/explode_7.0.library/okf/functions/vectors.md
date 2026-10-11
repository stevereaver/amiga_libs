# explode.library 7.0 vector map

LONG function table at hunk+0xb6, 6 entries + -1 terminator.

| LVO | Target | Name | Notes |
|----:|--------|------|-------|
| -6  | 0x166 | `LibOpen` | OpenCnt++, `bclr #3,base+34`, returns base |
| -12 | 0x174 | `LibClose` | OpenCnt--; at 0 with flag bit3 set -> shared expunge body, else 0 |
| -18 | 0x182 | (expunge slot) | `moveq #0,d0;rts` — real expunge is **never reachable via the vector** |
| -24 | 0x182 | reserved | same stub as -18 (shared target) |
| -30 | 0x288 | Explode | asm trampoline — see below |
| -36 | 0x1ea | ExpMark | `bset #3,base+34` — arms expunge at last close |

## Base layout (datasize 0x36 / 54 bytes)

| Off | Field |
|----:|-------|
| 34 | `eb_Flags` — bit3 = expunge-when-count-hits-0 |
| 36 | `eb_DosBase` |
| 40 | `eb_SegList` |
| 44 | pad (unused) |
| 46 | `eb_SavedLoad`    — LoadSeg vector value before patching |
| 50 | `eb_SavedNewLoad` — NewLoadSeg vector value before patching |

The old vector values are stored both in the base *and* inside the
stubs (`jsr` operand at stub+2), so the stubs chain to the previous
implementation.

## LibInit (AUTOINIT initfunc, hunk+0xfe)

1. `d0` = new base, `a0` = seglist -> base+40.
2. `OldOpenLibrary("dos.library", 37)` -> base+36.  **On failure it
   `beq`s straight to the exit and returns the (non-NULL) base** —
   the init "succeeds" with no wedge installed.
3. `Forbid()`.
4. `SetFunction(dosbase, -150, ExpStub)`; return value -> `ExpStub+2`
   (jsr operand) *and* base+46.
5. `SetFunction(dosbase, -768, ExpStubNL)`; return -> `ExpStubNL+2`
   and base+50.
6. `CacheClearU()` — **unconditional** (the 040/060 fix; safe only
   because requiring dos V37 implies exec V37).
7. `Permit()`, return base.

No slot-content inspection at all: unlike 5.6.29 there is no
`jmp abs`/`moveq;bra` form detection and no Alert — whatever was in
the slot is blindly called by the stub.

## -30 Explode calling convention (hunk+0x288)

Not a normal vector call.  Entered via `jsr` with the caller's
d0-d7/a0-a6 (60 bytes) already pushed beneath the return address and
the **packed control block immediately after the jsr** — the return
address becomes the source pointer (a5).  It:

1. `subq.w #1,lib_OpenCnt` — consumes one open per call.
2. pops a5 (retaddr = &control block), builds the a4 frame, decodes.
3. loads `a4+48` (seg base) +4 = hunk0 data start into a1 and writes
   it at `60(sp)` — the slot the final `rts` pops, so the routine
   **enters the freshly inflated segment** rather than returning to
   the jsr site.
4. Unconditional `CacheClearU`, `movem.l (sp)+,d0-d7/a0-a6`, `rts`.

## Expunge body (hunk+0x186, reached only via Close)

`Forbid`; `SetFunction(dos,-150,base+46)`;
`SetFunction(dos,-768,base+50)`; `CacheClearU`; `Permit`;
seglist->d2; `Remove(lib)`; `CloseLibrary(dos)`;
`FreeMem(base-negsize, neg+pos)`; return d2 with a6=base.

**No wedge-identity check** — 5.6.29 verified the slot still held
`4EF9`+our stub before restoring; 7.0 restores unconditionally, so it
can clobber a later-installed hook.
