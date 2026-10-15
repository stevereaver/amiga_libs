---
type: Structure
title: xpkPWPK 1.2(000) structures
---

# Structures

## Library base (dataSize 0x26, InitStruct datatab @code+0x74)

Standard `struct Library` + private word:
- +0x22 (34) ln_Succ slot reused as **seglist** store
  (initfn writes A0 there; Expunge returns it)
- +0x24 (36) from datatab -> idstring ptr
- InitStruct ops used: `a0 08` name@8, `80 0a` name ptr,
  `a0 0e 06` flags=LIBF_CHANGED? (6), `90 14` ver=1,
  `90 16` rev=2, `80 18` idstr ptr.

## XpkSubParams (A0 to pack/unpack)

| off | use |
|-----|-----|
| +0x00 | src ptr |
| +0x04 | src len |
| +0x08 | dst ptr |
| +0x0c | dst max len |
| +0x10 | out: bytes written |
| +0x1c | mode selector: `(v-1)/20 & 15` -> mode idx |
| +0x20 | **userdata ptr** — if non-NULL: content is checksummed
        (LAB_006A) into the stream trailer and used as XOR key
        (LAB_0068/006C) on the packed data |
| +0x34 | packer ctx (lazy-allocated on first pack; -42 frees it) |
| +0x38 | chosen mode index (also appended to stream) |
| +0x3c | userdata checksum (trailer path) |
| +0x40 | trailer key copy |

## Stream format

Bitstream written low-word-first via `MOVE.L D5,(A6)+`; tokens:
literal `1`+byte, or match `0` + class-coded (len,offset) from the
mode's exponent triple {e1,e2,e3}.  Tail: reversed-length long,
then long `(srclen<<8)|lastbits`.  With userdata: 4B mode +
4B checksum + XOR-crypted payload.  Unpack returns -32 on
checksum mismatch, -17 for encoder margin overflow.
