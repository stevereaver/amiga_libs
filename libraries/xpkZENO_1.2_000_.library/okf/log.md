# xpkZENO 1.2 — RE log

## Disassembly

- IRA dump of the 1800-byte binary: single 0x688 code hunk +
  19-entry HUNK_RELOC32.  AutoInit resident, word-offset functab.
- Identified as Gerhard Tuenkler's ZENO codec (Zeno Ries LZW
  family) — hash-probed LZW with 12/13/14-bit modes, distinct
  from the ZENO 1.1 variant.

## Decode

- Mapped all 10 vectors; -24/-48 wrap to the hunk+0
  `moveq #0,rts` stub (ExtFunc/PackReset are no-ops), -42/-60
  share one free routine.
- Packer: `h=(byte<<(bits-8))^(prev+1)` primary probe, open
  addressing with per-width modulus (0x1003/0x2011/0x47fb),
  emit-before-grow width rule, 1024-byte adaptive reset
  (`delta >= prev+128` -> emit 0x101, wipe, restart at 9 bits).
- Stream: `u32 hash, u8 bits, u8 0` then MSB-first codes;
  0x100 EOI, 0x101 reset.
- Unpacker: same tables indexed by code, stack-based string
  expansion, KwKwK via `firstchar` seeded from the first
  literal.

## Reconstruction

- C core `xpkZENO.c` (local `zclr` replaces memset for the
  nostdlib build; NRD16/NRD32 keep host-endian correctness under
  HOST_TEST).
- `xpkZENO_lib.s`: RomTag (EndSkip->_start), datatab, word-offset
  functab via `genfunctab.py`, XpkInfo + 3-mode chain (mode name
  fields are fixed 10-byte slots), LibInit stores seglist @+34.
- `xi_MaxPkInChunk` = 0x7fffffff, xi_Flags = 0xa009, basedesc
  "LZW 12-14 bit" — all confirmed by byte compare.

## Verification

- Header/RomTag/datatab: byte-identical through code+0x62.
- Descriptor + mode chain + strings: byte-identical modulo
  relocated pointers (after fixing EndSkip target, MaxPkInChunk,
  basedesc text and 10-byte mode-name fields).
- Functab: all 10 vectors resolve to correct symbols.
- Encoder byte-identical vs independent Python model on
  host.c/README/120 KB reset-path inputs, modes 0/34/100,
  password and plaintext streams.
- Round-trips: text, source files, 100 KB zeros, repeated text,
  mixed compressible/incompressible, reset-triggering stream —
  all clean, reset marker observed and handled.
- Error paths: -17 output budget, -32 missing/wrong password,
  -7 alloc fail.
