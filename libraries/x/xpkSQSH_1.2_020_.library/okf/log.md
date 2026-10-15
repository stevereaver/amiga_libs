# xpkSQSH 1.2 (020) — log

- Disassembled with IRA + manual 020-instruction decode (`bfffo`,
  `bfins` patterns IRA misread as DC.W).
- Mapped descriptor @0x660, tables (lentab 48w, lenextra 48b,
  widtab 7x8b, deltok 7x7 pairs), workmem 0x22080.
- Identified token format: delta-coded literals, adaptive width
  (deltok/widtab slot codes), litpress-driven marker inversion,
  3-class match distance (8/12/14-bit fields).
- First host round-trips failed/crashed above ~30 bytes; root causes
  found by instrumenting putbits/getbits and comparing pack/decode
  bit positions token-by-token:
  1. length word written LE on host -> explicit BE bytes;
  2. match distance prefix decoded as `0`/`10`/`11` — actual is
     `00`/`01`/`1` (one bit desync per 8-bit match);
  3. literal width tree wrong — actual is slot codes
     `010`/`0110`/`0111`+2b -> widtab lookup;
  4. literal delta computed in int — original wraps via `sub.b`;
  5. width = `2+lz8(acc)` — actual `bitwidth(acc)+1` via
     `bfffo d1{24:7}`;
  6. delta-scan count 6 — actual 5 (`dbf` cnt=4);
  7. floor/rem carried on hash-skip only — my draft also carried them
     across store positions, emitting stale matches at wrong
     distances (the "b5 bd for c9 a6" bug).
- After fixes: 59/77 sweep round-trips byte-exact, 0 decode failures;
  remaining failures are faithful -17 bit-budget rejections.
- Periodic sines compress ~16:1 (8000 -> ~500 bytes).
- m68k build verified: header/idstr/descriptor byte-exact; LVO table
  resolves; built `-m68020`.
- Reconstruction fixes found while building the 68000 twin
  (xpkSQSH_1.2(000)) and running the 020 under machine68k for the
  first time (earlier verification was host-only):
  1. entry points now take `xsp` in `a0` (`__asm("a0")`) per the XPK
     ABI — the previous build read it from the stack, which only
     worked in host tests;
  2. `putbits` writes zero-bits explicitly (`bfins` semantics) — the
     `|=` form left stale buffer bytes in streams under the emulator;
  3. match-chain node slot is `ca[-1] < cb[-1]` (signed final-byte
     relation from `cmpm.b`/`dbne`/`bles`), not `r > 0` — this was the
     last stream-divergence cause.
  After the fixes the rebuilt 020 library produces all 16 corpus
  streams byte-identical to the original under machine68k and every
  packable input round-trips.
- Confirmed the litpress gates are strict `> 7` (opcode 0x62 is BHI;
  earlier "off-by-one"/"emulator flag bug" notes were wrong —
  machine68k compares behave correctly).
