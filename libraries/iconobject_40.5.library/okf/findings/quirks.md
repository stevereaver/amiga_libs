# Quirks / defects

## Producer (SAS/C 6.58 + SLINK) quirks

1. **Dual-use `cmpi.w #imm,d0` instructions hide branch targets.**
   Four places where code branches INTO the immediate word of
   `cmpi.w #$7xxx,d0` — the immediate is itself an instruction:
   - code+0x0b6 `0c40 7001`: branch targets +0xb8 -> `moveq #1,d0`
   - code+0x720 `0c40 7000`: +0x722 -> `moveq #0,d0`
   - code+0x752 `0c40 200e`: +0x754 -> `move.l a6,d0` (open ret libbase)
   - code+0x776 `0c40 7000`: +0x778 -> `moveq #0,d0`
   Emitted as `.short` splits with labels inside the instruction.
2. **`moveq` with imm8 > 0x7f**: `74fe` (moveq #-2,d2 @0x38e),
   `70ff` (moveq #-1,d0 @0x5ec, 0x6d8). Capstone prints `#$fe/#$ff`;
   gas needs the signed form (same encoding).
3. **`lea.l _libname,a4`** — `49f9 00000000` stores a *relocated*
   ref to data hunk +0 (the SAS/C _LinkerDB slot); a4 is loaded with
   the data-hunk base in every public function and never used.
   13 instances — all carry hunk0->hunk1 relocs.
4. **`pea.l 2.w`** absolute-short pushes (0x4878 0x0002) — a constant
   2 pushed as a method tag arg; raw-emitted.
5. **Word-align pads**: `0000` filler at code+0x7fe, +0x8e2 and a
   trailing `0000` at +0x8fa; `4e71` at +0x6ce.
6. **Unsorted reloc records** — hunk1 groups descend (0x128..0x100)
   with 0x13c (initfn ref) spliced in; hunk0's ->h1 group is in linker
   hash order. fixup.py rewrites exact order.
7. **SAS/C absolute-data model**: all globals/strings are .l absolute
   refs into hunk1 (no a4-relative addressing despite a4 setup).

## Behavioural notes / possible defects

- `_open` return: on the success path d0 gets `move.l a6,d0` via the
  hidden-insn trick; on failure it runs `moveq #0,d0; cmpi.w
  #$200e,d0` — the cmpi is dead code (flags already tested by the
  caller's `tst.l d0` sequence... the cmpi IS executed on the failure
  path and harmlessly sets flags before `movea.l (a7)+,a4`).
- `_loadfail` fallthrough `moveq #0,d0; cmpi.w #$7001,d0` — same
  dual-use: falls to +0xb8 `moveq #1` on the taken branch.
- `_initfn` calls `_expunge` directly on `_openlibs` failure and
  returns 0 (also fine: opencnt 0 so expunge runs fully).
- dos LVOs used: -30 Open, -36 Close, -84 Lock, -90 UnLock,
  -102 Examine, -108 ExNext, -126 CurrentDir, -132 IoErr,
  -228/-234 (private/undoc used by SAS/C or V40 dos),
  -966 ParsePatternNoCase, -972 (MatchPatternNoCase-ish, word result).
- iffparse LVOs: -30 AllocIFF, -36 OpenIFF, -42 ParseIFF,
  -48 CloseIFF, -54 (FreeIFF?), -138 CollectionChunk,
  -150 StopOnExit, -162 FindCollection, -234 InitIFFasDOS.
- exec LVOs used: -0x22e InitSemaphore, -0x228 OpenLibrary,
  -0x19e CloseLibrary, -0x2ac AllocVec, -0x2b2 FreeVec,
  -0x10e Enqueue, -0x102 RemHead, -0xfc Remove, -0xd2 FreeMem.
- utility -0xa2 (Stricmp-ish name compare), intuition -0x27c /
  -0x282 (tag dispatch into datatype objects), datatypes sublib -0x1e.
