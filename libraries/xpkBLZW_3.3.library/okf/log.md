# xpkBLZW_3.3 work log

- Single-hunk AUTOINIT lib; trampoline + packed RomTag,
  InitTable dataSize 0x28, word-offset functab (10 entries).
- IRA disasm in work/: decoded encoder LAB_0028 (hash-chain
  LZW, 6-byte records, open addressing) and decoder LIBFUNC_5
  (bit-stack LZW with 0xff00-leaf / 0x800x-special records).
- LVOs: xpksub standard; -42/-60 share the free routine,
  -48 is a null stub.
- Descriptor decoded via RELRELOC32 pointer fields:
  XpkInfo {ver 1, lib 3, 'BLZW', flags 0x8009, min 0x80,
  def 0x20000, msgs} + XpkMode {packmem 0x3c006, unpackmem
  0x20000, "15 bits"}.
- Python oracle (work/oracle.py): pack+unpack round-trip on
  ~620 inputs incl. width-up/freeze/reset paths.
- C packer byte-identical to oracle on 224 packed streams;
  C decoder round-trips all + 112 large oracle streams.
- Documented defects: hash OOB past table for keys >= 0xa001,
  unconditional FreeMem, divu divisor truncation, decoder
  bound/stack quirks.
