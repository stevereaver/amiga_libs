# epu1.library — vector map

Functab = 6 LONGs + `ffff ffff` terminator.

| LVO | symbol      | behaviour |
|-----|-------------|-----------|
| -6  | LibOpen     | opencnt++, clears flag@46 bit3, returns base |
| -12 | LibClose    | opencnt--; if 0 && flag bit3 -> expunge, else 0 |
| -18 | LibExpunge  | if opencnt: set flag bit3, ret 0. Else Remove(a0 quirk), CloseLibrary(dos,intui,lh), FreeMem(negsize..possize), ret seglist |
| -24 | LibNull     | moveq #0,rts |
| -30 | EpuPack     | ctx=AllocMem(58,MEMF_CLEAR) else -1; blk=LHALLOC(mode 0) w/ OOM retry else -1; blk[0..2]={a0,d0,d1}; r=lh -42(blk); lh -36; ret r if r < a1arg else -2; FreeMem(ctx,58) |
| -36 | EpuUnpack   | identical but LHALLOC(mode 1), blk[0..3]={a0,d0,d1,a1}, lh -48 |

## Register ABI (both publics)

- a0 = source pointer, a1 = output bound, d0 = source length,
  d1 = destination pointer, a2 = call-name string for the OOM dialog.
- Return d0: lh result (>=0) or -1 (alloc/cancel) / -2 (result >= a1).

## 58-byte context (MEMF_CLEAR)

`+0 a0arg  +4 d1arg  +8 d0arg  +12 a1arg  +16 a2arg  +20 lh blk  +24 lh result`
(field order mirrors the original's stack pop order).

## Base layout (dataSize 0x30)

`Library(34) + execbase@34 + dosbase@38 + seglist@42 + flagbyte@46`
(bit3 = deferred expunge).

## Code-space statics (hunk 0x2fc-0x313, 8 slots)

- 0x2fc = lh base, 0x304 = intuition base, 0x30c = dead dosbase mirror;
  0x300/0x308/0x310 are never written (dead zero slots).
