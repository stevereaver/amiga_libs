# Decoder (LAB_002D-0051)

Backward-reading LZSS with a sliding ring window.

## Bit reader

`d1` reservoir, MSB first: `add.b d1,d1`; when the result is zero the
reservoir held only the sentinel - refill `d1 = *--src; d1 = d1*2+1`
(the shifted-out 1 becomes bit 0 = next sentinel).  Yields 8 bits per
byte.

## Length/class prefix

| code | len | class |
|------|-----|-------|
| 0 | 2 | 0 |
| 10 | 3 | 1 |
| 110 | 4 | 2 |
| 1110 | 5 | 3 |
| 11110 | 6 + 3 bits | 3 |
| 11111 | raw byte | 3 |

## Next literal count (class-indexed)

- `0` : count = next bit (0/1)
- `10`: count = 2 + tbl[4+class] bits
- `11`: count = tbl[class] + tbl[8+class] bits

(tbl = the 12-byte packed table {06,0a,0a,12,02,03,03,04,04,05,07,00}
serving as len_base[0..7] and len_bits[0..7] overlapped)

## Distance

- `0`  : base=0,            bits = offbits[class]
- `10` : base=range[class], bits = offbits[class+4]
- `11` : base=cum[class],   bits = offbits[class+8]

If the table entry has bit7 set: one raw byte is read, then (bits&0x7f)
extra bits are shifted in.  distance = base + extra + 1; match src =
wpos + distance, wrapped in [rlo, rtop).

## Ring mechanics

Both pull (copy-out) and write (decode) cursors descend.  When the
pull cursor hits the low bound a refill decodes `ring_sz` more bytes;
if a match copy is cut mid-way the remaining length is saved in
`pending` (+3) and resumed on the next refill (a5 persists).
