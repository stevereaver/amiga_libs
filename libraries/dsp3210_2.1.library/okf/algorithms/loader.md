# dsp3210.library — COFF loader algorithm (-36)

```
dsp_loadimg(img, dest, len, exttab):
    if img.magic != 0x166: return -1
    if img.symptr + img.nsyms*18 > len: return -1
    if img.nscns == 0: return -1
    desc[] = AllocMem(nscns*4, CLEAR|PUBLIC)
    scn = img + 20 + img.opthdr

    /* pass 1 — copy sections */
    cursor = dest
    for i in 0..nscns-1:
        desc[i] = cursor
        src  = img + scn[i].scnptr
        size = scn[i].size
        if size: copy src -> cursor, size bytes
        cursor += (size+3) & ~3
    /* dest must be sized per dsp_objsize */

    /* pass 2 — relocations */
    wbase = desc[0] + (f_flags & F_EXEC ? 4 : 0)
    for i in 0..nscns-1:
        if scn[i].nreloc == 0 or scn[i].relptr == 0: continue
        rel = img + scn[i].relptr
        for r in 0..nreloc-1:
            sym = symtab + rel[r].symndx*18
            d4  = sym.n_value
            if sym.n_scnum < 0: return -20
            if sym.n_scnum == 0:                    /* UNDEF */
                name = sym.n_name[0] ? sym.n_name
                                     : strtab + word(sym+6)
                if !exttab: return -21
                d4 = walk exttab {name,value} for name
                if not found: return -21
            else:
                d4 -= scn[sym.n_scnum-1].vaddr      /* offset in sect */
                d4 += desc[sym.n_scnum-1]           /* host address   */
            t = rel[r].r_type
            switch t:
              44: *(wbase + r_vaddr)     = d4
              46: *(wbase + r_vaddr + 2) = d4.lo16
              47: *(wbase + r_vaddr + 2) = d4.hi16
              28/34/35:
                  *(wbase + r_vaddr + 2) = d4.lo16
                  if d4 & 0xffff0000: return -30
              else: return -10
    FreeMem(desc)
    return 0
```

Helpers `rdlong`/`rdword` read big-endian fields at a2 (a2
preserved) — COFF fields may land on odd addresses. `_dsp_cmpstr`
compares NUL-terminated a1 vs a2 (Z = equal).

The +2 write offset for 16-bit relocs places the field in the low
half of a 32-bit instruction word (DSP instruction packing).
