# 68020.library 40.1 (MMU) — quirks & defects

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
Correct for a per-CPU driver, but combined with the
NO68881/NOMMU flags the library still installs on an FPU-less
machine — it simply skips the exception vectors.

## Unpatch scope on mmu-open failure

If `mmu.library` can't be opened, only **table A**
(ColdReboot) is unpatched (0x28e path) before the cleanup
tail — correct, since table B hasn't run yet.  But once
resident, `LibExpunge` (LVO -18) is a pure null stub: the
patches are never removed and the TRAP vectors/SetFunction
slots stay patched forever — the library can only be torn
down by reboot (which is why ColdReboot itself is patched, to
shut the PMMU down first).

## Dead vectors raise Alert(0x3f000001)

LVOs -30..-216 (minus -222) all land on a stub at code+0x22
that pushes 0x3f000001 and calls the Alert helper — a call
into any unimplemented vector flashes/recoverable-alerts
instead of returning cleanly.

## pf_getmsg differs subtly from exec/GetMsg

The patched GetMsg unlinks `lh_Head` only when
`head->ln_Succ != NULL`.  On a properly maintained list the
last node's Succ is `&lh_Tail` (non-NULL), so semantics match;
but a list whose tail node's Succ was zeroed (or a corrupted
list) is treated as empty rather than returning the last node.
Uses `INTENA` master-disable and `IDNestCnt` (SysBase+294)
instead of Forbid — safe against interrupts, but differs from
stock GetMsg which uses Forbid.

## Recoverable-alert AddConfigDev

The expansion.library patch alerts `0x3f000015` (recoverable)
on *every* AddConfigDev call before chaining to the original
— presumably a debugging marker left in the shipped driver.

## Supervisor frame contract

`InstallExcVecs` relies on exec/Supervisor entering the
function with a valid interrupt frame so `super_excvec` can
`ori #0x700,sr` (raise to IPL 7) and `rte` — works on KS 2.x/
3.x exec where Supervisor synthesizes an exception frame.
Both VBR-relative *and* absolute low-memory vector slots are
written, so TRAP interception works whether or not VBR is 0.

## InitTable functab vs code layout

All functab entries land in the code hunk; the data hunk also
holds the InitTable **before** the functab (InitTable at
data+0, functab at data+0x10) — standard MakeLibrary AUTOINIT.
`rt_MatchTag` and `rt_EndSkip` RomTag fields are unrelocated
(harmless — AUTOINIT only follows rt_Init).

## Reconstruction note: register-asm gotcha

GCC does not support a `register … __asm("a6")` variable that
must stay SysBase while another asm call needs a6=lib (the
THOR alert helper).  LibInit captures entry-a6 into a plain
pointer and lets each inline LVO stub reload a6 — without that
the generated code called `lib-414` (a dead vector) instead of
exec/CloseLibrary on the fail path.
