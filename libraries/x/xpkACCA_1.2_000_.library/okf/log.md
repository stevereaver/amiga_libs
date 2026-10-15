# xpkACCA 1.2 — work log

## Analysis

- Extracted code hunk -> `work/acca.bin`; objdump disasm ->
  `work/acca_full.asm`. IRA was not needed (single flat code hunk
  disassembles cleanly; the `moveml a0@+` tables and hunk relocs
  decode by hand).
- Header: word-offset functab @0x94 (`ffff` marker + 10 entries +
  `ffff`), dataSize 0x26, revision 2, EndSkip=0 quirk (same as
  xpkHFMN 1.4 family).
- Vectors all resolved; -24 and -60 both target the entry stub.
- Decoder walked first (simpler): established flag-groups,
  16-class token map, table16, and the exact emit counts for every
  class (dbf/dbne semantics, long-run 18-fixed+N tail, class-15
  alignment prepend).
- Turbo packer: single-candidate 12-bit hash, bound at
  OutBufLen-48, run cap 4114, match cap 269, dist range 3..4098
  (unchecked below 3).
- Crawling packer: `(b0<<8)|((b1+b2)&0xff)` 16-bit hash over 65536
  heads + 8192-entry ring chain keyed by ADDRESS low bits; best
  match packed as `dist<<16|len` in d5 (the high word doubles as
  the emit-time distance field after `swap;subq#3`).
- Verified the trailing words of the binary = the original hunk's
  RELOC32 contents (pointer fixup offsets).

## Host verification (work/host_acca.c)

- `gcc -O2 host_acca.c` — both packers + decoder round-trip.
- Fixed during bring-up: `ULONG` must be 32-bit on host (`unsigned
  int`) since Amiga ULONG is 4 bytes; off-by-one on the class 3..13
  copy loop (`dbf` counts down to -1 => do{}while(--n!=0));
  `a0p[d5]` needed `d5&0xffff` (packed len word);
  offset-table model uses stored = pos+1 so cleared heads act like
  the original's NULL pointers.
- Results: text/rand/ramp/pairs/zeros/allbytes/mix round-trip in
  both modes; crawling rejects uncompressible input with -17 as
  the original does (bound = out+InLen).
- Faithful-defect cases: `run18` crawling decodes 4114 bytes for
  the 18-run; `abab` turbo desyncs at byte 2 via the class-2/len-2
  defect; `dist4k`/`rand` crawling return -17.

## m68k build

- `make` in `source/` produces `xpkACCA.library` via the two-pass
  word-offset functab; header/datatab/descriptor verified against
  the original's bytes; exec calls use `*(void **)4` for SysBase
  and LVOs AllocMem(-198)/FreeMem(-210)/Remove(-252).
