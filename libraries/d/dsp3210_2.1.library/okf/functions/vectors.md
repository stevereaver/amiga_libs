# dsp3210.library — vector map

Functab is the absolute-long form (first word != 0xffff), 8 entries +
0xffffffff terminator. All vectors take `a6` = library base.

| LVO | Target | Function | Signature (regs) |
|-----|--------|----------|------------------|
| -6  | 0xca   | LibOpen    | → base; OpenCnt++, clears DELEXP |
| -12 | 0xda   | LibClose   | → 0; OpenCnt--, expunge on last+DELEXP |
| -18 | 0xf4   | LibExpunge | → seglist|0; closes dosbase, Remove+FreeMem |
| -24 | 0x136  | (stub)     | → 0 |
| -30 | 0x15e  | dsp_objsize | a0=COFF img, d0=img len → d0=load bytes or -1/-2 |
| -36 | 0x1fa  | dsp_loadimg | a0=img, a1=dest, d0=len, a2=dead, stack+12=exttab → d0=0/err |
| -42 | 0x46a  | dsp_loadfile | a0=filename, a1=dead, a6=base → d0=loaded img (desc+8) or 0 |
| -48 | 0x5ac  | dsp_unload | a0=desc+8; frees desc if magic ok |

## dsp_objsize (-30)

Validates a DSP3210 COFF image:

- `f_magic` (w@0) must be 0x166
- `f_symptr` + `f_nsyms`*18 must be ≤ len
- `f_nscns` (w@2) must be nonzero
- iterates `f_nscns` 40-byte section headers at
  `img+20+f_opthdr`; every `s_flags` (scn+36) must be
  0x20 (TEXT), 0x40 (DATA) or 0x80 (BSS); accumulates
  `(s_size+3)&~3` per section
- returns total aligned size; -1 bad header, -2 bad section type

## dsp_loadimg (-36)

Copies sections and applies relocations into `dest`.
Stack frame: `subq #8` + 44B reg save. Reads an **external symbol
table from the caller's frame at entry+12** (3rd stack arg):
array of {name ptr, value} pairs, 8B each, NULL-name terminated.
Used to resolve UNDEF symbols (n_scnum==0) — a host-provided
export/bindings table for the DSP program.

Two passes:

1. Alloc `nscns*4` (MEMF_CLEAR) → per-section load-addr table;
   copies each section's `s_size` bytes from `img+s_scnptr` into
   `dest`, advancing the cursor by `(size+3)&~3`.
2. Per section, per reloc entry (10B): resolves `r_symndx` through
   the symtab (`img+f_symptr`, 18B entries). Defined syms:
   `d4 = n_value - scn[n_scnum-1].s_vaddr + desc[n_scnum-1]`
   (host address). UNDEF: name from inline `n_name` or strtab
   (`symptr+nsyms*18+offset`), walked against exttab.
   The reloc write base is **always `desc[0]`** (+4 when
   `f_flags` bit 0x02 / F_EXEC), i.e. the image is assumed
   contiguous-by-vaddr.

Reloc types (r_type @ reloc+8):

| type | op |
|------|-----|
| 44 (0x2c) | `*(base+r_vaddr)   = d4` (32-bit) |
| 46 (0x2e) | `*(base+r_vaddr+2) = d4.w` |
| 47 (0x2f) | `*(base+r_vaddr+2) = d4.hi` (swap) |
| 28/34/35  | `*(base+r_vaddr+2) = d4.w`, error -30 if `d4 & 0xffff0000` |

Errors: -1 bad image, -2 (dead), -3 AllocMem fail, -10 bad r_type,
-20 n_scnum<0, -21 UNDEF with no/failed exttab, -30 16-bit overflow.

## dsp_loadfile (-42)

`a0` = filename, `a1` = passed verbatim into loadimg's dead a2
(vestigial, ignored). Sequence:

1. `dsp_opendos` — lazy `OpenLibrary("dos.library",36)` → base+42
2. AllocMem(260) FIB; `Lock(name,ACCESS_READ)` + `Examine` +
   `UnLock` → `fib_Size` (+124); frees FIB
3. AllocMem(size); `Open(name,MODE_OLDFILE)` + `Read` (must return
   full size) + `Close`
4. `dsp_objsize` → need bytes; AllocMem(need+8); writes
   `0x32102011` + need into the 8-byte header
5. `dsp_loadimg(buf, desc+8, xarg, fsize)`; frees file buffer
6. on error frees descriptor; on success
   `CachePostDMA(img, need, 0x800)` and returns desc+8

## dsp_unload (-48)

`a0-8` must be 4-aligned and hold `0x32102011`; frees
`*(a0-4)+8` bytes. Silent no-op otherwise.
