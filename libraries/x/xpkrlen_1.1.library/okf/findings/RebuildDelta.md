# Rebuild delta

- Rebuilt .text 0x338 vs shipped 0x3a8 (GCC codegen vs Aztec).
- .data hunk is byte-identical (emitted verbatim; the two inittab
  code refs are .long symbols which land identical reloc slots).
- Codec semantics ported faithfully; PackFree/UnpackFree preserve the
  shipped "return d0 unchanged" stubs.
