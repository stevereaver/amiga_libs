---
bundle: mixer_1.11.library
status: complete
updated: 2026-10-15
---
# mixer.library 1.11 (22 JUL 10)

ELBOX PCI sound-card mixer library (Pawel Stypula / ELBOX COMPUTER).
Protected build: single CODE hunk, COLDSTART resident, body of the
library XOR-encrypted in place with a rolling cipher keyed on the
decryptor itself plus a zero-sum integrity check.  At run time the
init routine decrypts the payload, finds an ELBOX bridge board via
expansion.library FindConfigDev, passes a hardware-ID dongle check
through pci.library, PCI-scans for a supported audio codec chip,
then MakeLibrary()+AddLibrary() itself with a per-chip vector set.

- `structures/layout.md` — hunk map, resident, InitStruct, lib base
- `functions/vectors.md` — LVO table (two variants) + init protocol
- `findings/defects.md` — protection notes, dead code, real bug
