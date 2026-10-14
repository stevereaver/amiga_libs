# cyberlayers_40.8.library -- work log

- Parsed hunk file: 2 CODE hunks (h0 0x211 longs / 2116 B, h1 0xa7
  longs / 668 B). Relocations use a nonstandard tag `0x3f7` block:
  u16 count + u16 target-hunk + u16 offsets, count-0 terminated,
  trailing pad word, then `0x3f2`. Groups: h0->h0 ten offsets
  {6,12,16,1a,c6,ca,ce,e4,f6,4ac}, h0->h1 six offsets
  {a,48e,494,49a,4a0,4a6}. Note `0xa` = rt_EndSkip is relocated to
  hunk1, so EndSkip = end of hunk1 -- the resident spans both hunks.
- RomTag @h0+4: AUTOINIT 0x80, v40, NT_LIBRARY, pri 0.
  name->0x1e, idstr->0x32, init->0xc2 (InitTable).
- InitTable @0xc2: dsize 0x76 (118 B), functab->0xd2, datatab->0xde,
  initfn->0xfe. Functab is word-mode (`ffff` sentinel + u16 offsets
  rel. table base): only 4 vectors.
- Disassembled h0 (objdump, /tmp/cl0.txt) and h1. h1 = five `CYBL`
  blocks (18-byte headers: magic, ver=0x27, flag word, three zero
  longs filled at install with {oldfunc, ourlib} at +0xa/+0xe) plus a
  shared compare helper; h0 embeds a sixth CYBL block @0x51e.
- Reconstruction: `cyberlayers_h0.s`/`cyberlayers_h1.s` mnemonic
  assembly; the 16 relocated fields are `.long` symbol refs (incl.
  h0->h1 refs for EndSkip and the five CYBL fn pointers, and h0+0x530
  for the embedded block). The word-mode functab emits
  `_fn-_functab` deltas, matching the original table format.
- Linker detail: input section must be plain `.text` for the amiga
  backend to type the hunk CODE (custom `.h0`/`.h1` section names
  came out DATA/0x3ea).
- `fixup.py` replaces the linker's RELOC32 tail with the exact 0x3f7
  group layout; hunk1 has no relocs (bare HUNK_END).
- Result: byte-identical (cmp + md5 51ee1a5be1b9c2af4cf7740c3b91d591).
- Oracle: machine68k harness with a fabricated word-mode-functab
  layers resident (incl. a `4eba` self-call to its -126 fn so the
  in-clone scan hits), fake layers/graphics/cybergraphics bases and a
  real MakeLibrary-emulating InitResident. Observed: AllocVec(202)+
  CopyMem clone, clone rebase + InitResident -> 0x209768, the 4eba->
  `jsr -126` site patch, CacheClearU, Forbid, 33x SetFunction
  (-30..-216 -> clone fns), Permit, CloseLibrary, then 6x SetFunction
  installing CYBL bodies; lifecycle vectors and all six patched
  vectors called. orig.log == rebuild.log.
