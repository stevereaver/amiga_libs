# Functions

22 user vectors - see index.md API map.  Highlights:

- ToshFunc0/9/10/11/12 all call INTERNAL vectors of dos.library
  (-60, -84, -30 on DOSBase) - BCPL-era private entries, not exec.
- ToshFunc6/7/8 implement a send/cancel pair on a stored IOStdReq
  (command 0x25 - device-specific).
- ToshFunc4 polls a WORD counter (LAB_00BB) until it changes -
  depends on an interrupt/handler updating it.
- ToshFunc18 emits `$`+8 lowercase hex digits into a scratch field.
