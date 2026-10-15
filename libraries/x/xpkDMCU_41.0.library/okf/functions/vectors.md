# xpkDMCU 41.0 — vectors

Functab: 10 long offsets at h1+0x10, terminated by `0xffffffff`.
InitTable at h1+0: `{ dsize=0x36, functab->h1+0x10, datatab->h1+0x100,
initfn->h0+0x0e }`. `a4` = `_gd` = h1 base throughout.

| LVO | name | h0 off | behavior |
|-----|------|--------|----------|
| -6  | Open | 0x46 | `lib_OpenCnt++`, clear `LIBF_DELEXP`, return a6 |
| -12 | Close | 0x5e | `lib_OpenCnt--`; if 0 && DELEXP -> `_expunge`; returns d0 |
| -18 | Expunge | 0x80 | if opencnt != 0 -> set DELEXP, return 0; else Remove, `_closedeps` (release all ppc objects, `CloseLibrary(ppcbase)`), `FreeMem(lib-neg, neg+pos=148)`, return seglist |
| -24 | ExtFunc | 0xcc | `moveq #0; rts` |
| -30 | info | 0x320 | return `&_gd+0x2f4` (xpi table in DATA hunk; +0 = 0x00010001) |
| -36 | pack | 0x3b6 | dispatcher: reads a5=a0 job/param struct; creates ppc objects at a5+0x34/+0x38 via ppc LVO -0x3c if absent; falls through to PPC submission or native path |
| -42 | free | 0x590 | releases a5+0x38 and a5+0x34 via ppc LVO -0x42, clears both fields |
| -48 | stub | 0x5ca | `moveq #0? ; rts` — returns 0 |
| -54 | unpack | 0x5d8 | validates version byte `a5[0]` (0..9 else -12); if a5+0x34/0x38 both 0 tries to create them (ppc -0x3c); if still absent `bsr _v60` (native); else builds job msg via ppc -0x54/-0x150/-0x132/-0x144 protocol and CopyMem |
| -60 | native unpack | 0x79c | pure-68k unpack backend called by -54 fallback |

## Init path (`_initfn` h0+0x0e -> `_initdeps` h0+0xdc)

1. Store seglist (a0->lib+0x22), lib (d0->_gd+0x3c), exec (a6->lib+0x26
   and _gd+0x78).
2. `OpenLibrary("ppc.library",45)` -> _gd+0x7c; if NULL -> skip all
   ppc setup.
3. `ppc -0x1e("LIBS:ppc/xpkDMCU.elf")` -> _gd+0x80 (ELF object).
4. Two `ppc -0x10e` calls -> _gd+0x88, +0x8c; `ppc -0x126` -> +0x90;
   `ppc -0x3c(4,1)` -> +0x94.
5. Big taglist build on stack -> `ppc -0x54` (0x8002xxxx tags);
   `ppc -0x150`; loop: `ppc -0x138` iterator over objects, each seen
   via `-0x144` + `-0x150` + `-0x306`(setattr 0x80025002/'PORT') until
   iterator returns 0.
6. Copy _gd+0x7c/0x84/0x8c into lib+0x2a/0x2e/0x32; return lib in d0.

## Teardown (`_closedeps` h0+0x24e)

Reverse order: ppc -0x126/-0x14a/-0x150/-0x132/-0x12c/-0x114/-0x42
chain releasing _gd+0x80..0x94 objects, then
`CloseLibrary(_gd+0x7c)`.
