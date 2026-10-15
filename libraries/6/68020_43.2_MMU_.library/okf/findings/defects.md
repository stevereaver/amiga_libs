# 68020.library 43.2 (MMU) — quirks & defects

## Dead-string table entries

The data hunk carries `mathieeedoubbas.library` (data+0xe4)
and `mathieeesingbas.library` (data+0xfc) but no code ever
opens them — leftovers from a shared THOR driver template
(the 680x0.library sibling does open math libs for its FPU
emulation dispatch).

## CPU gate rejects everything except a bare 68020

`btst #2` (AFF_68030) fails init outright and `btst #1`
(AFF_68020) must be set — on a 68030/040/060 the init
silently frees its own allocation and returns 0 with no alert.

## expansion.library opened but never used as a patch target

43.2 keeps the `OpenLibrary("expansion.library", 37)` and
stores the base at lib+56, but table B no longer contains the
`liboff 56, -30` AddConfigDev record — the base is only ever
closed on the init-fail path.  Dead dependency kept from 40.1.

## exec -36 patch reads INTREQR for no effect

The new trampoline on the unpublished exec slot -36 pushes
the old vector, executes `tstw $dff01e` (INTREQR), and `rts`s
into the original.  The `tstw` sets CCR flags that neither
the `rts` nor the called function consumes — a vestigial
Paula interrupt-status read (probably leftover debug/
synchronization code from the author's build).

## Unpatch scope on mmu-open failure

If `mmu.library` can't be opened, only **table A**
(ColdReboot) is unpatched before the cleanup tail — correct,
since table B hasn't run yet.  But once resident,
`LibExpunge` (LVO -18) is a pure null stub: the patches are
never removed and the vectors stay patched forever — the
library can only be torn down by reboot.

## Dead vectors raise Alert(0x3f000001)

LVOs -30..-216 (minus -222) all land on a stub that pushes
0x3f000001 and calls the Alert helper — a call into any
unimplemented vector recoverable-alerts instead of returning
cleanly.

## pf_getmsg still drops a single-queued message

43.2 adds the missing early empty check
(`lh_TailPred == &lh_Head` ⇒ return 0 without touching
INTENA — the actual fix vs 40.1), but keeps the deeper quirk:
the unlink proceeds **only when `head->ln_Succ != 0`**.  On a
properly maintained `struct List` the last node's Succ is
NULL, so a port holding exactly one message returns 0 and
leaves the message queued (verified against the original in
the oracle: n=0 → 0, n=1 → 0, n=2 → head node).  Uses
`INTENA` master-disable and `IDNestCnt` (SysBase+294) instead
of Forbid.

## GetMsg may leave INTENA enabled early-exit consistent

On the empty path 43.2 skips INTENA entirely (good); on the
non-empty path it re-enables INTENA when IDNestCnt goes
non-negative — same as 40.1.

## Supervisor frame contract

`InstallExcVecs` relies on exec/Supervisor entering the
function with a valid interrupt frame so `super_excvec` can
`ori #0x700,sr` and `rte` — works on KS 2.x/3.x exec where
Supervisor synthesizes an exception frame.  Both VBR-relative
*and* absolute low-memory vector slots are written, so the
FPU handlers are installed whether or not VBR is 0.

## super_coldreboot bra-chain

The 43.2 reset sequence `bras 2f / reset / jmp a0@ / 2: bras`
is an odd forward-backward branch pair wrapping the
`reset; jmp` — faithfully reproduced in the reconstruction;
semantically a plain fallthrough, but the encoding is as
shipped.

## Reconstruction note: register-asm gotcha (carried from 40.1)

LibInit captures entry-a6 into a plain pointer and lets each
inline LVO stub reload a6 — pinning SysBase to a6 collides
with LibAlert's a6=lib parameter and miscompiles the fail
path (calls `lib-414`, a dead vector, instead of
exec/CloseLibrary).
