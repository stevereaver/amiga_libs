# log

- Disassembled `xpkLZW5_5.3(020).library` (IRA dump + fresh
  objdump cross-check); single-hunk AUTOINIT Froehling XPK sublib.
- Resolved all 10 vectors; decoded encoder/decoder at register
  level.  Format: 2-bit tiered flags (00 lit / 01 short /
  10 medium / 11 long), negated distances, 16 items per flag long.
- Reconstructed in C (`source/xpkLZW5.c`) + minimal .s skeleton
  (RomTag, datatab, LibInit, static descriptor).  Build via the
  two-pass genfunctab scheme (same as xpkLZW4).
- Verification: byte-exact encoder vs an independently derived
  Python model on all tested inputs/modes; 3000-trial host suite
  -- 0 real failures (corrupt decodes trace to the shipped
  tier-boundary defect, reproduced identically).
- Defects recorded: 90 KB PackReset underflow (worst of the
  family), self-corrupting tier tokens (dist 8192-16383 len<=5,
  dist 4096 len 6..17), tail overreads, unchecked decoder,
  68020 gate.
