# Log

- Flat AUTOINIT; extended 26B resident; InitTable@h0+0xd8,
  14-vector abs-long functab@h0+0xe8; initfn@h0+0x144 opens
  dos.library.
- Verbatim .byte emission (source/bfb_h0.s) + original-tail splice
  fixup.py (RELOC32 33 slots ->h0): BYTE-IDENTICAL (5840B).
- Dep-tracing machine68k oracle (dos/misc/ciaa/ciab stubs): all 14
  vectors + open/close/expunge lifecycle — orig.log == rebuild.log,
  RUNTIME-IDENTICAL.
