---
file: log
---
# Work log

- 2026-10-15: hunk0 CODE 3584B + BSS hunk1 512B. Verbatim
  transcription (head/itab/functab/strings raw through 0x148;
  `Nu15 ...` inline string span emitted raw; three `bkpt`-decoded
  string words emitted as .short). fixup.py splices the original
  38-slot RELOC32 tail + BSS hunk trailer. BYTE-IDENTICAL.
- machine68k oracle: init opens rexxsyslib/33, expansion/36,
  commodities/36, identify/38; all 5 vectors traced; close-underflow
  deferred-expunge path identical. RUNTIME-IDENTICAL.
  Plane AMIGALIBS-285.
