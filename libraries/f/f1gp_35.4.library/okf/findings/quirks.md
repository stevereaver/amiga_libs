# f1gp 35.4 — quirks and inconsistencies

## Protection checks

`rt_Init` runs two predicate routines (`Patch1`@0x878, `Patch2`@0x880)
before building the library. In the shipped binary both are `rts`
stubs — the protection scheme was either disabled for this release or
self-patched at build time. The reconstruction preserves the stubs and
the surrounding call sites byte-for-byte.

## DATA hunk declared vs physical size

Hunk 1 is declared as 49 longs (196 B) in the size table but the DATA
hunk body carries only 26 longs (104 B). The loader allocates 196 B;
`rt_Init` explicitly zeroes the trailing 96 B via an unusual
`movel #26,d0` / `movel #23,d0` pair (two `movel #imm` instructions
with 6-byte encodings rather than `moveq`). `fixup.py` restores the
declared size after link since the linker can only emit the physical
body size.

## Assembler-encoding quirks reproduced literally

The original assembler emitted non-canonical encodings that GNU as
relaxes; the source uses raw opcode words to match:

- `movel #26,d0` / `movel #23,d0` (6B) — gas would emit `moveq`
- `subl #65536,d0` (`0x90bc`, 6B) — gas emits `subil` (8B)
- `cmpl #-1`-style compares as `b0bc` CMP.L rather than CMPI `0c80`
- `moveal 0x4:l,a6` (long-absolute `0x2c79`) in `rt_Init`, but
  short-absolute `0x2c78` for the same load in `ExitTail`
- absolute `lea` for the two init descriptor pointers (gas prefers
  PC-relative)
- asymmetric `moveml` pop masks in `_SegFree` (`a3-a4/a6`) and
  `_UnsigAll` (`a3-a4/a6`) — restores do not mirror pushes elsewhere
- `jmp` tail in init is PC-relative (`4efa`) while JSRs to internal
  targets are absolute (`4eb9`)

## RELOC32 offset order

The original linker emitted relocation offsets in a non-sorted order
(GNU ld emits sorted). `fixup.py` rewrites both lists to the original
sequence to reach byte-identity; semantic content is identical.

## InitTable / name oddity

The library name string is `f1gp.library` at code+0x1e; the byte
before it is `0x6a` — the low byte of the `rt_Init` pointer, rendering
as `j` — so a naive string dump shows `jf1gp.library`. The registered
name is `f1gp.library`.

## Quirk: checksum with length 0

`Checksum` performs `d0-1` before its first byte fetch, so `len=0`
underflows — behaviour identical in original and rebuild (do not
"fix").
