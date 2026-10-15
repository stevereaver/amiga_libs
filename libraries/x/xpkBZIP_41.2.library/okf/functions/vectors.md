# xpkBZIP — vectors and ABI

10 absolute-longword functab entries (DATA+0x10).  a6 = lib
base for all vectors; API functions take a0 = XpkSubParams.

## Lifecycle

- **-6 LibOpen**: `opencnt++` (w@32), `bclr #3,14` DELEXP,
  returns a6.
- **-12 LibClose**: `opencnt--`; zero + DELEXP → tail
  expunge.  Early exits branch to 0x7a — the `70 00` operand
  of a dead `cmpi.w #0x7000,d0` — i.e. `moveq #0,d0`.
- **-18 LibExpunge**: opencnt!=0 → `bset #3,14`, return 0.
  Else Remove(lib), CloseLibrary(ppc), FreeMem(lib-negsize,
  neg+pos), return seglist (lib+34).  SysBase comes from the
  DATA-hunk global at data+120 (set by initppc), not lib+38.
- **-24 / -48**: identical null stubs `moveq #0,d0;rts`.

## -30 XpksPackerInfo

Returns APTR → the XpkInfo descriptor at data+0x2b8 (88 B).

## -36 XpksPackChunk(a0=xsp) → error

    mode = (9 + xsp[28]) / 10          /* divu.l; level 0..100 */
    if (mode == 0) mode = 1;
    xsp[8][0] = mode;                  /* BEFORE range check */
    if (mode < 1 || mode > 10) return -12;   /* <1 dead */
    xsp[64] = LoadObject("LIBS:ppc/xpkBZIP.elf");   /* ppc -30 */
    if (!xsp[64]) return -33;
    if (!xsp[52] && !xsp[56] && !xsp[60]) {   /* all-zero gate */
        xsp[52] = AllocVec(mode*409600, 1);
        xsp[56] = AllocVec(mode*409600, 1);
        xsp[60] = AllocVec(0x40004, 1);
    }
    if (!xsp[52] || !xsp[56] || !xsp[60]) { free_bufs; return -7; }
    frame = {1, mode, xsp[0], xsp[8]+1, xsp[4], xsp[12],
             xsp[52], xsp[56], xsp[60], 0, 0};
    xsp[16] = RunFunction(xsp[64], frame);    /* ppc -42 */
    UnloadObject(xsp[64]); xsp[64] = 0;       /* ppc -36 */
    return 0;

## -54 XpksUnpackChunk(a0=xsp) → error

    mode = xsp[0][0];                     /* byte pack wrote */
    if (mode < 1 || mode > 10) return -12;
    xsp[64] = LoadObject(...);  if (!xsp[64]) return -33;
    if (!xsp[52] && !xsp[56] && !xsp[60]) {
        xsp[52] = AllocVec(mode*409600, 1);
        xsp[56] = AllocVec(mode*102400, 1);
        xsp[60] = AllocVec(mode*102400, 1);
    }
    if (!all) { free_bufs; return -7; }
    frame = {0, mode, xsp[0]+1, xsp[8], xsp[4], xsp[12],
             xsp[52], 0, 0, xsp[56], xsp[60]};
    r = RunFunction(xsp[64], frame);
    UnloadObject(xsp[64]); xsp[64] = 0;
    if (r == -1) return -17;
    if (r == -2) return -5;
    return r == xsp[12] ? 0 : -4;         /* 0 via mid-insn */

## -42 PackFree / -60 UnpackFree (a0=xsp)

Free xsp[60], [56], [52] (reverse order) via ppc -66, zero
the fields.  -42 is byte-identical except it lacks the
trailing `moveq #0,d0` — it returns the last FreeVec
residue (verified 0xdeadbeef propagates).

## XpkSubParams layout (a0, all longs)

| idx | off | field                                  |
|-----|-----|----------------------------------------|
| 0   | 0   | src                                    |
| 1   | 4   | inlen                                  |
| 2   | 8   | dst                                    |
| 3   | 12  | outbufsize                             |
| 4   | 16  | outlen result (pack writes ppc ret)    |
| 7   | 28  | level (pack only, 0..100 xpk scale)    |
| 13  | 52  | work buf 1 (mode*409600)               |
| 14  | 56  | work buf 2                             |
| 15  | 60  | work buf 3                             |
| 16  | 64  | PPC object handle                      |

## ppc.library calls (PowerUP)

| off | args                       | use                        |
|-----|----------------------------|----------------------------|
| -30 | a0=path                    | LoadObject → obj           |
| -36 | a0=obj                     | UnloadObject               |
| -42 | a0=obj a1=frame            | RunFunction → result       |
| -60 | d0=size d1=1               | AllocVec → ptr             |
| -66 | a1=ptr                     | FreeVec                    |
