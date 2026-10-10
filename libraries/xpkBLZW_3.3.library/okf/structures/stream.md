# BLZW stream layout

```
word 0    max code width used (9..15); decoder allocs
          4 << w0 bytes for the decode table
word 1    max string length & ~3; decoder stack bytes
byte 4..  MSB-first packed codes
```

## Bit packing

Both directions use the same scheme: a 32-bit window at an
even cursor; a "bits remaining" counter starts at 32 and
decreases by the code width each code; when it goes negative
the cursor advances 2 bytes and 16 is added back.  Writer
ORs `code << bits` into the window; reader takes
`window >> bits & mask`.

## Codes

- 0..255   literal bytes
- 0x100    END
- 0x101    RESET  (decoder: width->9, mask->0x1ff, free->259,
           budget reload, next code read at 9 bits is a literal)
- 0x102    WIDTH-UP (width++, mask = mask<<1|1)

## Decoder table

4 bytes per record, `4<<w0` total:

    +0 u16   char (literal) / 0xff00+i leaf tag / 0x800x special
    +2 u16   2 * previous code (pre-doubled chain pointer)

Index 0x100..0x102 hold the specials; free records from 259.

## Encoder hash table

6 bytes per record, 0xa001 records (0x3c006 bytes):

    +0 u16   byte (bit15 set = empty)
    +2 u16   previous code
    +4 u16   assigned code

key = ((byte << (mode-8)) ^ prev) & 0xffff, index = key*6;
probe step = index*? -- actually step = d6 - 0x3c006 + 6 bytes,
applied once, wrapped with +0x3c006 when sign goes negative.
