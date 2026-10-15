# xpkBLZW 3.3 vectors

Word-offset functab (marker -1, offsets from table base,
terminator -1):

| LVO | target | symbol        | notes |
|-----|--------|---------------|-------|
| -6  | LibOpen   | openCnt++, clear DELEXP@14, return a6 | |
| -12 | LibClose  | openCnt--; last close + DELEXP -> Expunge | |
| -18 | LibExpunge| Remove + FreeMem(base-negsize,total); returns seglist@36; DELEXP set if openCnt>0 | |
| -24 | LibNull   | moveq #0,d0 / rts | |
| -30 | XpksPackerInfo | lea descriptor @0xf8 | |
| -36 | XpksPackChunk | wm_grab(0x3c006) then encoder; -7 no mem, -17 expansion | |
| -42 | XpksPackFree | free xsp_Sub[0] (unconditional!) | |
| -48 | LibNull   | PackReset is a stub | |
| -54 | XpksUnpackChunk | wm_grab(4<<w0 + stacksz) then decoder; -7 no mem, -14 len mismatch | |
| -60 | XpksUnpackFree | same routine as -42 | |

## Encoder notes (LAB_0028)

- input <= 127 -> return 0 (wrapper maps to -17, expansion).
- bit window pre-zeroed over [out, out + inlen&~31); writing
  starts at out+4 (after the 2-word header written at tail).
- bound = out + (inlen&~31) - 8; hitting it -> pack returns 0
  -> -17 XPKERR_EXPANSION.
- hash: key = ((byte<<shift) ^ prev) & 0xffff, shift = mode-8
  = 7; record at tab + key*6 = {u16 byte, u16 prev, u16 code},
  empty iff byte-field bit15 (init 0xffff).
- probe step (computed once per lookup): step = d6-0x3c006+6;
  d6 += step, wrap += 0x3c006 iff sign-bit set.
- d3 = next code from 0x103; limit doubles 0x200..0x8000 as
  width grows 9..15.  When a pending code doesn't fit the
  field, emit 0x102 then width++/limit<<=1.
- At width==15 && next >= 0x8000 the table FREEZES: header
  word0=15, inserts degrade to a per-byte countdown; every
  256th insert runs a ratio check (consumed<<8 / produced vs
  checkpoint); a worse ratio with >127 bytes left emits
  prev,literal,0x101 and re-inits the whole table.
- Tail: emit trailing 0x102 if last code >= limit; emit last
  code; emit 0x100; header word1 = maxstrlen & ~3; word0 =
  final width if still 0; return outp+4-out.

## Decoder notes (LIBFUNC_5)

- workmem = (4<<w0) table + stacksz string stack.
- table rec = {u16 tag_or_char, u16 2*prev}; tag 0xff00+i =
  literal leaf i; 0x8000/1/2 = END/RESET/WIDTH-UP via the
  subq#3/addq#1 signed-overflow decode.
- free index starts at 259 (a5+0x40c); inserts {char,2*prev}
  stop when the (1<<w0)-0x103 budget runs out.
- code == free -> deferred case: push first-char, decode prev.
- special codes are checked in the CHAIN WALK terminator
  (w0 >= 0x8000), not the input code itself.
- produced length must equal xsp_OutLen (field 16) else -14.
