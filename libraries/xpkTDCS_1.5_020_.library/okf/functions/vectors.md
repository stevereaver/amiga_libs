# xpkTDCS — vector detail

## Lifecycle (-6/-12/-18/-24)

Byte-identical to every other Froehling xpksub lib:
Open (opencnt++, clear DELEXP), Close (opencnt--, DELEXP path
into expunge), Expunge (Remove + FreeMem(base-negsize,
neg+pos), return seglist), -24 null → shared `moveq #0/rts`.

LibInit stores the seglist at base+0x22 and gates on
`AttnFlags & AFB_68020` — on a 68000 it branches into the
shared null stub returning d0=0, so the AUTOINIT fails and the
(020) tag is enforced without a text string.

## -30 XpksPackerInfo → hunk+0x1ac

`lea (desc,pc),a0; move.l a0,d0; rts` — returns the static
XpkInfo block (see structures). xi_ID 'TDCS', DefMode 50
("ashes"), modes cremation/33, ashes/67, oblivion/100 with
PackSpeed 18/8/6, UnpackSpeed 560, Ratio 397/411/415.

## -36 XpksPackChunk → hunk+0x194

`a0 = XpkSubParams`. Lazily-allocates workmem (0x80004,
MEMF_PUBLIC, size stored at buf[0]), runs PackReset, then the
tiered encoder — see algorithms/codec.md. Returns 0, -7
(no mem), -17 (output ≥ inlen bound).

## -42 XpksPackFree → hunk+0x120

`d0 = xsp_Sub[0]; if set: a1 = d0-4; d0 = *a1; FreeMem`.
Frees the whole workmem via its self-describing size word.

## -48 XpksPackReset → hunk+0x138

`d0 = xsp_Sub[0]; if set: a6 = d0+0x40000` then the movem
fill — 70,577 zero longs downward (see defects).

## -54 XpksUnpackChunk → hunk+0x3b8

`a0 = XpkSubParams` (in at +0, out at +8). Register-param
decoder: a0=src, a1=dst, flag longs in d2, item counter d3.
Returns 0 always; terminates on flag-11 + zero token word.
No length checks, no outlen writeback.

## -60 null → hunk+0

Shared `moveq #0,d0; rts` stub.
