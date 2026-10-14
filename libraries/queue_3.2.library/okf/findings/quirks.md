# queue.library 3.2 — quirks & inconsistencies

- **Template = InitTable**: initfn copies h1 bytes 0..27 verbatim into
  lib+48 — i.e. the library's runtime context starts life as a byte copy
  of the InitTable block (dsize field, functab ptr, initfn ptr included).
  `_initctx` then overwrites ctx+20/+24 with SysBase/lib. The h1[0]
  count field is 0, so the accompanying pointer-fixup loop (adds the
  copied base to each of N longs starting at h1+4) is dead code.

- **Overlapped copy loop**: `0c40 1cd9` at h0+0x7a is `cmpiw #0x1cd9,d0`
  whose operand `1cd9` doubles as `moveb (a1)+,(a6)+` — the `bccs`
  targets 0x7c, mid-instruction. Same idiom as cddb 44.999.

- **Overlapped return**: at h0+0xb4 `beqs` lands on the operand bytes of
  `cmpiw #0x200d,d0`, i.e. `movel a5,d0` — success path returns the lib
  base, fall-through returns 0. One instruction encodes both exits.

- **rt_EndSkip = h0+0x1e** — the resident scan covers only the RomTag
  itself, not the trailing pad word; normal but worth noting since the
  pad sits inside the skipped region anyway.

- **Name/id strings stored via `movel #imm`**: `movel #_qname,a5@(10)`
  and `movel #_qidstr,a0@+` look like literals (0x38/0x48) but carry
  real RELOC32 entries into hunk2 — correct at runtime.

- **Version fields via `lea` constants**: ver 3 / rev 2 / count 7 are
  loaded with `lea 0x3:l` / `lea 0x2:l` / `lea 0x7:l` then moved — the
  compiler (SAS/C-style) used LEA for small constants because an
  absolute-long LEA is unrelocatable and position-independent-ish.

- **Trailing "ad" bytes** in hunk2 (`6164` @h2+0x5a): dead 2-byte
  leftover after the id string, preserved verbatim.

- **functab[3] = 0** relocated to the h0+0 stub rather than a real
  reserved-entry — same convention as cddb's DOS stub slot.

- **Deferred-expunge garbage writes**: when the last Close triggers
  Expunge, the teardown path (observed in both original and rebuild)
  performs Remove/AddHead/Signal on near-null node addresses, producing
  invalid writes to `ffffffe*` — the library removes itself before
  detaching a queue node left in a dying state. Faithful quirk, not a
  reconstruction defect.
