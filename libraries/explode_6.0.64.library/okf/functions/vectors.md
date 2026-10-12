# Vectors (LONG-form functab at hunk+0x82)

| off  | entry        | notes                                        |
|------|--------------|----------------------------------------------|
| -6   | LibOpen      | OpenCnt++, clears flag bit3, returns base    |
| -12  | LibClose     | OpenCnt--; on 0 + flag bit3 -> real expunge  |
| -18  | ret0 stub    | `moveq #0,d0; rts` — expunge refused         |
| -24  | ret0 stub    | same                                          |
| -30  | _ExpExplode  | asm trampoline; pops src ptr from stack,      |
|      |              | decrunches, patches saved-retaddr to hunk0+4  |
| -36  | _ExpMark     | `bset #3,34(a6); rts` — arm self-expunge      |

The -18/-24 vectors never expunge: the only teardown path is
Close() reaching OpenCnt==0 while flag+34 bit3 is set (a wedge
client or the -36 mark call arms it).

## LVOs used

exec: Alert -108, Forbid -132, Permit -138, FreeMem -210,
Remove -252, CloseLibrary -414, SetFunction -420,
OpenLibrary -552 (v33), CacheClearU -636 (exec>=37 only).

dos patched: LoadSeg -150, NewLoadSeg -768 (exec>=37 only).

## LibInit patching logic

- OpenLibrary("dos.library",33) -> base+36; NULL -> Alert 0x80038007
  (deadly, never returns)
- Under Forbid: save 6 slot bytes into base+44/46
- slot `4ef9` (jmp abs): copy operand -> _ExpStub+4, install
  _ExpStub+2 (skips the moveq)
- slot `70xx` (moveq): copy imm -> _ExpStub+1; if next word is
  `6000` (bra.w) follow disp -> operand for _ExpStub+4, install
  _ExpStub+0 (keeps the foreign moveq semantics)
- otherwise: Alert 0x00028007 (recoverable), return unpatched
- exec >= 37: SetFunction(dos,-768,_ExpStubNL), write old ->
  _ExpStubNL+2 and base+50, CacheClearU

## Expunge body (via Close)

- Verify slot is still `4ef9` + operand == _ExpStub or _ExpStub+2,
  else return 0 (someone re-patched — leave it)
- exec >= 37: if NL slot operand == _ExpStubNL, write saved vec back
- Restore the 6 saved LoadSeg slot bytes verbatim
- exec >= 37: CacheClearU
- seg -> d0; Remove; CloseLibrary(dos); FreeMem(base-negsize)
