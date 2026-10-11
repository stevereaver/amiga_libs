# RE log -- xpkLZW4.library 4.3 (020)

## 2026-10-11

1. Single CODE hunk + HUNK_RELOC32 + HUNK_END; packed RomTag at
   hunk+4; existing IRA disassembly `work/xpkLZW4_4.3(020).asm`.
2. Word-offset functab (-1 marker) -> 10 vectors:
   Open@0xc2 / Close@0xd0 / Expunge@0xe2 / null(-24) /
   PackerInfo@0x18c / PackChunk@0x194 / PackFree@0x120 /
   PackReset@0x138 / UnpackChunk@0x386 / null(-60).
3. LibInit: stores seglist at base+0x22, then `btst #1,a0@(297)`
   (AttnFlags AFB_68020) -> non-020 returns NULL.
4. Descriptor fully decoded via reloc map: XpkInfo @hunk 0x3fa,
   four chained XpkMode records ("cremation" 25 / "ashes" 50 /
   "grave" 75 / "oblivion" 100), PackMemory 0x80004 each.
5. Packer core decoded: head[65536]+chain[65536] pointer tables,
   key = `move.w (a2),d1 / add.b 2(a2),d1` =
   `b0<<8 | ((b1+b2)&0xff)` -- byte-wide add, no carry into b0
   (an earlier draft keyed on `(b0<<8|b1)+b2` with full carry --
   wrong bucket shape, fixed).
6. Best match carried PACKED as (dist<<16)|len in d5/d4 through
   the lazy loop -- the emit is literally `swap; neg.w` -> the
   negated distance word, then len-3 byte.  Min match len 3.
7. Lazy loop transcribed: probes at cur+1..cur+budget-1;
   `nlen - adv <= best` signed 16-bit rejects; adopt rewinds and
   literalises the gap (emit, insert, remaining--, flag shift,
   outend check per literal); exhausted probes rewind
   `cur -= adv-1`.  d3 = (xsp_Mode-1)/25 via subq.b+divu -- an
   inline `divuw` is used in C (`__udivsi3` is unavailable
   freestanding).
8. Decoder: flag long MSB-first; moveq #-1,d1 seeds the high word
   so `move.w (a0)+,d1` yields 0xffffWWWW = token-0x10000 -- every
   token reaches BACKWARD 1..0xffff.  First C draft used SHORT
   dist, which flips distances >32 KB into FORWARD copies --
   produced valid-length-but-wrong-content streams on >64 KB
   inputs; fixed to `dst - (0x10000 - tok)`.
9. Two independent audits vs the disassembly (line-by-line C/asm
   compare): all codec paths CONFIRMED-MATCH after three edge
   fixes -- loop exit is signed BGT (`remaining <= 0`, reachable
   when oblivion-mode lazy probes wrap remaining), the lazy
   budget compare is signed BLT, and the early literal return
   writes dist=0 (packed d5=1).
10. Host testing: native writes needed big-endian shims (putl/putw);
    3000 + 2000 pack->unpack round-trips at modes 0/25/50/75/100
    over random/low-entropy/run-length/sparse/>64 KB periodic
    inputs -> 0 failures; 466 bound overflows correctly -17.
    The remaining<3-tail lazy probe reads up to ~2+258 bytes past
    the input (shipped overread, see findings/defects.md) -- host
    harness pads the tail with deterministic junk to emulate
    AllocMem slack.
11. Built via two-pass genfunctab (stub sized marker+10+marker);
    all 10 vectors verified against nm symbol addresses.
