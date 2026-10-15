# Rebuild delta

**Superseded.**  The earlier C reconstruction (`xpkDLTA.c`,
`xpkDLTA_lib.s`, generated `functab.s`) builds a valid hunk library but
is not byte-identical (GCC vs hand-asm codegen); it remains available
as `make cmodel` for reference.  It also lacks the shipped codec's
off-by-one: the C `while (n--)` loop stops after InLen bytes while the
binary processes InLen+1 (see [Quirks.md](Quirks.md)).

As of 2026-10-15 the default `make` builds `source/xpkDLTA_h0.s` —
verbatim asm emitting the entire code hunk — plus `source/fixup.py`,
which rewrites the reloc32 offset table into the shipped DESCENDING
order (GNU ld emits ascending).  Result is **byte-identical** to the
original: md5 `db80a6f55766ec0e670a7a78b441920e`.

Details worth noting:

- The InitStruct table uses flat byte offsets up to 0xa2 (the embedded
  XpkMode fields); no extended-offset commands appear.
- `rt_EndSkip` IS relocated here (points at a trailing `nop` at
  code+0x256) — unlike 0.3/NONE where it is literal 0.
- `cmp.l #0x10000,d1` is emitted raw (`b2bc 0001 0000`) so it cannot
  be canonicalised to `cmpi.l`.
