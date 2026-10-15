# Rebuild delta

**Superseded.**  The earlier C reconstruction (`xpkDLTA.c`,
`xpkDLTA_lib.s`, generated `functab.s`) builds a valid hunk library but
is not byte-identical (GCC vs hand-asm codegen); it remains available
as `make cmodel` for reference.

As of 2026-10-15 the default `make` builds `source/xpkDLTA_h0.s` —
verbatim asm emitting the entire code hunk — which is **byte-identical**
to the shipped binary (md5 `7c59a56bf765719b0e755acc854bfa4c`).

Details worth noting:

- `movea.l 0(a0),a1` appears in both codec entries in the 4-byte
  disp16 form (`2268 0000`); gas folds `0(a0)` to `(a0)`, so it is
  emitted as `.short`.
- The reloc32 tail (17 entries) is ascending and matches GNU ld output
  directly — no fixup needed (unlike 0.2, whose tail is descending).
- `rt_EndSkip` is a literal 0 with no relocation entry, matching the
  "EndSkip never patched" quirk also seen in xpkNONE 1.5.
