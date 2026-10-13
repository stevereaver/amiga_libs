# ksort.library — shipped defects / inconsistencies

All reproduced verbatim in the reconstruction; recorded here
and on Plane card AMIGALIBS-120.

## 1. LibExpunge reads OpenCnt through the caller's a5

h0+0x176: `tst.w 0x20(a5)` — a5 is never loaded in the
routine (the push mask saves d2/a2/a6 only).  The open-count
test therefore inspects `(caller's a5) + 32` — a wild read.
Whether deferred expunge (`bset #3,14(a6)`) fires or a full
expunge runs depends on whatever register state the caller
happened to leave in a5.  Intended was almost certainly
`tst.w 0x20(a6)` (a6 = libbase).

## 2. LibExpunge closes the library NAME STRINGS

h0+0x1ba/0x1d4/0x1ee: `lea <name>,a1` then `jsr -414(a6)` —
the code executes `CloseLibrary("dos.library")`,
`CloseLibrary("intuition.library")`,
`CloseLibrary("graphics.library")` — passing the name string
pointer where a library BASE belongs.  The opened bases sit
in BSS+4/+8/+0x0c and are never closed.  On real hardware
CloseLibrary decrements the OpenCnt word at (string+32) —
inside the following name strings — and, if that word hits
zero, runs Remove+expunge on a bogus library pointer.
Vestigial and mostly latent because expunge itself is rarely
reached (defect 1), but the writes DO happen on a successful
expunge.

## 3. LibExpunge writes the seglist to absolute address 0

h0+0x208: `move.l d2,0x00000000` — operand carries no hunk
relocation, so the seglist lands at absolute address 0 (the
reset-SSP vector).  Almost certainly intended to be a write
to the BSS SysBase slot (`gdata+0`, i.e. a hunk1-relocated
operand) or a `move.l d2,d0` return-value fix-up.  Effect on
real hardware: corrupts the initial supervisor stack pointer
(benign until reset) AND fails to return the seglist — d0 is
whatever the last CloseLibrary call left.

## 4. The u32 (-60) sort corrupts memory on base-0 self-swaps

The unsigned-long worker uses UNSIGNED compares for its index
tests (`bls/bhi/bcc`) while every other variant uses signed
ones (`ble/bgt/bge`).  When a partition at index 0 ends with
i=1, j=-1 the unsigned `i <= j` stays true and the j cursor
walks below `&a[0]`, swapping wild reads into the array and
array elements into descending unmapped addresses.  Any
`qs(a,0,1)` recursion triggers it — pivot is always `a[0]`,
the scans converge at 0, and the self-swap produces j=-1.
Observed: descending 4- and 10-element inputs produce
`[1,0,0,0,...]` with the displaced elements at `a[-1]`,
`a[-2]`, …; descending 6/8/20 escape because their partition
trees never hit a base-0 self-swap.  This is the RareOldLibs
"actually buggy" warning made concrete.  Reconstruction
reproduces it (ULONG indices in `qs_u32`).

**UB caveat:** once the walk leaves the array it reads/writes
whatever process memory it finds — caller stack frames,
spilled registers, unmapped space.  The defect's trigger,
class, and the in-array corruption are identical between the
original and the rebuild, but the exact bytes landed below
the buffer necessarily diverge (different codegen spills
different values into the walk path).  This is chaotic
environment-dependent UB — even the original run under a
different memory map would produce different garbage.

## 5. LibInit opens three libraries that nothing uses

DOS/Intuition/Graphics bases are stored in BSS+4/+8/+0x0c at
init and only ever touched again by the (broken) expunge
CloseLibrary calls.  No sort routine reads them — shared
SAS/C-family boilerplate common to the ak.* siblings.

## 6. count <= 0 still performs a pivot read

The workers compute `pivot = a[(0+count-1)/2]` before the
`i <= j` guard — `a[0]` for count=0, a negative index for
negative counts.  A wild read for `a = NULL`/empty ranges.
