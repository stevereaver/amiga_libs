# Findings & defects

- flags byte 0x80 (COLDSTART) yet rt_Init->InitTable — old
  flag semantics; the generic AUTOINIT path works.
- initfn opens deps via OldOpenLibrary(-408), the WB1.x
  convention.
- Close underflows open count: cnt=65534 after double close;
  expunge returns 0xff after forced close.
- ~9 deterministic invalid reads (functab edge probes).
