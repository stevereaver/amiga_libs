---
type: Log
title: rexxidentify 1.16 work log
---

- 2-hunk build; resident@h0+4; InitTable@h0+0x100; 5-entry
  absolute-longword functab@h0+0x110 all ->h0.
- DREL16 tails (word-sized groups); longword realign pad word
  between DREL16 terminator and HUNK_END; BSS hunk has no body.
- gen_source needed a pos-cursor fix vs the sibling version:
  objdump tokens straddling DATA boundaries dropped bytes.
- Verbatim .text + .bss; fixup splices header+DREL16 verbatim;
  byte-identical first pass after the generator fix.
- Oracle identical: init/5 vectors/RexxMsg dispatch/close-deferred
  expunge/real expunge.
