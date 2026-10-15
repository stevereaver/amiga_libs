# xpkHUFF 1.0 — vectors

AUTOINIT word-offset functab at hunk+0x92: marker word `0xFFFF`,
10 word offsets relative to the table base, `0xFFFF` terminator.

| LVO | hunk target | function                                   |
|-----|-------------|--------------------------------------------|
| -6  | 0x00B2      | LibOpen — ++OpenCnt, clr DELEXP, ret base  |
| -12 | 0x00C0      | LibClose — --OpenCnt; last+DELEXP->expunge |
| -18 | 0x00D2      | LibExpunge — mark or Remove+FreeMem        |
| -24 | 0x0000      | entry stub (moveq #0,d0; rts) — wraps via 0xFF6E |
| -30 | 0x0128      | XpksPackerInfo — lea desc(pc); ret ptr     |
| -36 | 0x0130      | XpksPackChunk                              |
| -42 | 0x0110      | XpksPackFree                               |
| -48 | 0x0000      | entry stub — PackReset no-op (0xFF6E wrap) |
| -54 | 0x03E2      | XpksUnpackChunk                            |
| -60 | 0x0110      | XpksUnpackFree — same as PackFree          |

Init struct at 0x62: `{datasize 0x26, functab 0x92, datatab 0x72,
initfunc 0xAA}`.  LibInit stores the seglist at `base+34`.

Calling convention (all XPK vectors): `a0` = `XpkSubParams`,
`a6` = library base.  The packer also reads the *saved* a0 slot
at `24(sp)` (the pushed-reg block) for a second xsp pointer —
equivalent to reusing the live a0.

## XpkSubParams fields used

| off | field         | use                                       |
|-----|---------------|-------------------------------------------|
| 0x00| xsp_InBuf     | input (stream on unpack)                  |
| 0x04| xsp_InLen     | input length (low word bounds emit loops) |
| 0x08| xsp_OutBuf    | output buffer                             |
| 0x10| xsp_OutLen    | pack: out-length store; unpack: decode count |
| 0x20| xsp_Password  | optional password string                  |
| 0x34| xsp_Sub[0]    | lazy workmem pointer (alloc+4)            |

Return codes: 0 ok; -7 AllocMem fail; -17 pack output overflow
(no password); -26 bad flag word (unpack); -27 pack overflow
with password set; -32 wrong/missing password (unpack).
