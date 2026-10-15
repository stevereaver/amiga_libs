# Rebuild delta

- Rebuild is a valid AUTOINIT library but NOT byte-identical:
  GCC codegen + globals land in a real .bss hunk (original embeds
  a zeroed pool inside .text as `dc.w 0` pairs).
- Funcs 9/13/14 are ported at call-shape level - their internal
  dispatcher (LAB_005D) and supervisor trampoline semantics need a
  deeper pass (documented as pending).
- Function names are reconstructed; the binary ships no fd.
