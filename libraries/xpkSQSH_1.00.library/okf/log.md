# xpkSQSH 1.00 — reconstruction log

- Extracted code hunk (single HUNK_CODE, 2100 bytes of code + 132 bytes
  of InitTable/romtag/idstring; single-reloc hunk). LibInit@0xa4 builds
  the XpkInfo + XpkMode descriptors into lib private data (dataSize
  0xa8); lib+34 = seglist. Functab@0x54 = 10 absolute LONGs + -1.
- Vectors (real offsets, code.bin = hunk body): Open@0x254, Close@0x262,
  Expunge@0x276, null0@0x2bc, PackerInfo@0x2cc (returns lib+0x26),
  Pack@0x2d6 (wrapper@0x300 -> core@0x36e), stubs@0x2e2/0x2e4,
  Unpack@0x2e6 (wrapper -> decoder@0x696), stub@0x2f4.
  **Caution**: an early pass disassembled `work/code.bin` WITH its
  8-byte HUNK_CODE header, desyncing all offsets by -8 (that parse
  showed a phantom 11th vector and a "bare rts" at the Unpack slot).
  The real layout is the conventional 10-slot xpk sublib table.
- Pack wrapper@0x300: saves a6->xsp+56, AllocMem(0x22080), xsp+52=ws,
  a4=out, out[0..1]=inlen(low word), bsr core, outlen=(bitpos+7)>>3,
  rc -7 AllocMem / -17 budget. Frees ws, leaves xsp+52 stale.
- Core@0x36e: clears 0x22080 via 4 movemls x dbf(726) (FULL clear, not
  partial — earlier note revised). node base = ws+0x2080, scratch longs
  at ws+0x2070..0x207f (head-table tail). Insert-ahead pipeline: each
  token inserts the next `a2cnt` positions; hash `(in[p]<<4)^in[p+1]`
  & 0xfff; two u16 chain slots chosen by sign of first byte diff
  (`dbne` walk, longest match, nearer on `r<=best && cand>floor`);
  `cmpm.b` max 46 -> reads past in+inlen. Emitted token describes the
  LAST inserted position's match.
- Litcost@0x4b0: 5-delta lookahead, `dl<0 -> ~dl`, wid = bitwidth+1,
  run 5 (2 when wid==8), forced wid8/run1 when `wid>=7 && mom<20`.
  `mom += 8` on run>=2, `mom -= mom>>3` every token.
- Bit gates: BOTH `cmpaw #7,a5` (litcost `bhi`, marker rewrite `bls`)
  => engage at litpress > 7 — consistent with decoder `cmpw #8,d1;bcc`.
  CORRECTION: an early read logged this as `>=7` because BSD objdump
  prints `bhis` for opcode 0x62 = BHI (strict) — and a subsequent
  "emulator equality-flag bug" theory was disproved by direct
  `scc`/`scs`/`bcc`/`bcs` micro-tests (all correct).
- Emit tables (real offsets): lenextra@0x666 (`00..1c`, +forced-'0'
  tag read as u16@0x666 = 0x0100), tag grid@0x570 flat
  `tag[prevw*8+w]` (entries for flat 18..24 = prevw2; w==8 wraps to
  next row col0, w==9 hits `0000` pad — unreachable), lentab@0x604,
  widtab@0x7fe (7 rows).
- Decoder@0x696: prev=in[0]; wid8 literal '0'; inverted ladder '010'->
  2, '0110'->3, '0111'->3-bit field **at the tested bit** (top bit is
  the '1' already consumed -> slots 4..7); litpress cap 31, match
  len3 -> -1, len4+ -> -2, lit -> +1 (clamped >=0).
- Match emit: marker '1' inverted -> token<<2 with a '00' prefix
  (the rewrite does `asl#2` on the token field — implemented as a
  2-bit left shift of the whole token word).
- C port verified: host sweep (64-bit long) byte-identical on all
  streams except input-tail bytes that read stale past-end memory;
  cross-compiled -O2 -m68020 needed `-fno-strict-aliasing` (GCC GCSE
  otherwise reorders u16 workspace stores vs u8 input reads and
  fabricates wrong matches — produced a len-4/dist-256 phantom).
- ABI: pack/unpack xsp arg in a0 (`__asm("a0")`), lifecycle libbase
  in a6 (`__asm("a6")`) — stack-arg reading initially broke all
  lifecycle vectors (LibOpen returned 0, count never bumped).
- machine68k oracle (M68020): lib loads at 0x100000, InitTable ok,
  PackerInfo == lib+0x26. Pack+unpack + pack-vs-original for:
  empty, one, two, lit16, lit40, z64, z300, ab_rep, abc, abab, txt,
  allb, rep4k, snd, ramp, rnd1k — ALL byte-identical; every packed
  stream round-trips through the rebuilt unpacker; the 5 failing
  inputs return -17 exactly like the original.
- Lifecycle sweep: open x2 (count 1->2), close (2->1),
  PackerInfo == lib+0x26 — all pass.
