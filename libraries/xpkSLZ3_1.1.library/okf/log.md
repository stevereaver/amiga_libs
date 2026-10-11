# RE log -- xpkSLZ3.library 1.1

## 2025-10-11

1. Single 0x160-longword CODE hunk + HUNK_RELOC32 (18 entries) +
   HUNK_END.  Packed RomTag at hunk+4 with relocated
   matchtag/endskip/name/idstr/init.
2. Word-offset functab (-1 marker) -> 10 vectors:
   Open/Close/Expunge/null(-24)/PackerInfo(-30)/PackChunk(-36)/
   null/null/UnpackChunk(-54)/null.
3. Expunge reads the stack top twice (libbase) before popping --
   Remove + FreeMem(neg+pos), returns seglist.
4. XpksUnpackChunk @0xf6: flag-grouped LZ decoder.  Flag 0 -> copy 8
   literals; else 8 MSB-first bits: 0 literal, 1 -> 2-byte token
   (hi nibble = off[11:8], lo nibble = len-2; byte2 = off[7:0]);
   token byte 0 = end.
5. XpksPackChunk @0x1b2: AllocMem(0x40002), fills 256 KB with -1;
   context = 6 low bits of src[i]<<6 | 6 low bits of src[i+1];
   16-deep position LRU per context (shift-register insert at
   hunk 0x13c).  Match candidates: 16 LRU entries, then a
   sequential backward scan to pos-4095 when no len-17 hit.
   len cap 17 (nibble+2), min match 3.
6. Output staging: flag bit (0x80>>slotcount); buf[1] pre-seeded
   src[0], count starts at 1 (seeded literal = first flag bit).
   Flush at 8 items; final flush sets the next flag bit high and
   appends a 0 token, or emits ff00 for a full group.
7. XpkInfo @0x43a + XpkMode @0x552 decoded via reloc list:
   name "SpeedLZ", id 'SLZ3', flags 0x8009, chunks 15..0x7fffffff
   (def 0x7fff), mode "SpeedLZ" speed 30/600 ratio 100.
8. C reconstruction in source/; two-pass genfunctab functab; all 10
   vectors verified against nm.  Host harness: 2000 round-trips,
   0 failures (random/entropy/runs/sparse).
