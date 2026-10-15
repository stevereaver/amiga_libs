---
file: defects
---
# Findings

- DATA-resident RomTag: whole resident+InitTable+functab
  live in h1 (file values pre-reloc; ftab field 0 in file,
  relocates to h1+0). rt_Init is a literal hunk-relative
  0x3c, not relocated.
- OpenLibrary deps are lazily opened on first Open, not in
  initfn — initfn only inits 2 semaphores.
- No invalid accesses observed.
