# Inconsistencies / defects (shipped, faithfully reconstructed)

1. **StopModule (-48) takes its session arg in A5**, unlike every
   other module function (A0). Odd ABI — callers must set both.
   (GCC can't bind a param to a5 here; the reconstruction reads
   the register out with an explicit `movel %a5`.)
2. **Unaligned session LONGs** (+2, +10): `MOVE.L` at offset%4==2
   is an address error on plain 68000/010 — requires 68020+.
   The reconstruction accesses them byte-wise (packed struct),
   which is a semantic superset.
3. **tag7-missing error path frees through uninitialized a3:**
   InitModule jumps to the common unwind before a3 is assigned —
   the register still holds the caller's value, so a nonzero a3
   means wild `2(a3)` reads + FreeMem(a3,80).
4. **Stale tag7 ti_Data on cleanup:** the error path frees the
   80-byte session but leaves the tag item's ti_Data pointing at
   the freed block — caller sees a dangling session pointer.
5. **PSID header read with no size check:** buf[15], buf[17],
   buf+22, buf+54, buf+86 are dereferenced regardless of modlen —
   a short/corrupt "module" overreads.
6. **songs-1 wraps:** PSID songs=0 -> songsm1 = 0xFFFF; SetSubsong
   then clamps every request to 65535, effectively unclamped.
7. **buf2/len2 (+6/+14) freed but never written** — dead fields
   (harmless since the block is MEMF_CLEAR).
8. **Seek-based size trick assumes Seek(h,0,END) succeeds** —
   the first return value is discarded without checking -1.
9. **StopModule/ContModule call playsid with no NULL check** on
   the base pointer (+48) — crash if the player lib was never
   opened or already closed.
10. **PlayModule checks ExecBase.SoftVer>=36** but performs the
    rest of the call sequence without validating the playsid
    base either.
11. **SetSubsong stores n+1 but returns n** (0-based API vs
    1-based internal/playsid numbering) — off-by-one by design;
    clamp path returns songs-1.
12. **GetInfo uses absolute 4 for execbase** instead of the
    stored base+36 (works, but inconsistent).
13. **RetM1 stubs (-60/-66) pointlessly save/restore all regs**
    before returning -1.
