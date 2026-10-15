# Permanent LoadSeg hook, no expunge

- Expunge vector is a null stub; `lib_OpenCnt` stays 1.
- The hook is installed at init and never removed; expunging would
  crash the next LoadSeg.  Consistent and deliberate.
- `LibOpen` bumps a PRIVATE counter at +0x2a, so repeated OpenLibrary
  calls never reflect in lib_OpenCnt either.
- On init failure it Alerts rather than returning NULL - the library
  still registers (deadly-requester on missing dos.library).
- The hook is a transparent file-interception vector - worth noting
  from a modern security view, though standard for packers.
