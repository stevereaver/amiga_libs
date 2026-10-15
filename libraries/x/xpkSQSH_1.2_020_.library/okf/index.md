# xpkSQSH_1.2_020_.library — OKF index

- Binary: `binary/xpkSQSH_1.2(020).library` (2,028 bytes, single 3E9 hunk;
  md5 ea0420cfd9cee5caf69f451bbfa9e168)
- Identity: `$VER: xpk V1.2 (1 Oct 2013) by John Hendrikx`
- Kind: XPK sublibrary, "LZ based cruncher, special algorithms for
  8 bit sound data, fast decrunching" (ID `SQSH`, flags 9)
- CPU: 68020 required — LibInit tests `ExecBase->AttnFlags` bit 1
  (AFF_68020) and returns NULL otherwise.
- Reconstruction: `source/xpkSQSH.c` (codec + lifecycle),
  `source/xpkSQSH_lib.s` (RomTag/inittab/datatab/descriptor/init),
  `source/genfunctab.py` + `functab_stub.s` (two-pass word-offset
  functab); built `-m68020`.
- Verification: 59/77 sweep cases round-trip byte-exact on the host
  build (the other 18 are faithful -17 bit-budget rejections on
  incompressible/small inputs); zero decode failures. Header bytes,
  idstr/verstr, descriptor scalars and mode block verified vs the
  original. Periodic-sine input compresses ~16:1.

Algorithm: LZ + delta coding specialised for 8-bit sound. Two
innovations vs a plain LZSS: literals are emitted as *signed deltas*
from the previous sample at an adaptively chosen field width
(2..8 bits), and when literal pressure stays high (litpress > 7) the
literal/match marker sense inverts so literal runs cost a '1' bit
while matches get a '00' escape prefix.

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
