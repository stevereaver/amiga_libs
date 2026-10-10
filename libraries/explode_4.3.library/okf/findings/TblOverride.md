# Table override via header nibble

Setup stores `stream[0] >> 4` at frame+19 = tbl[11] = len_bits[7]
(the extra-bit count for literal-count code `11`, class 3).  The
encoder chooses the high nibble of the format byte to patch the
decoder's length table per-file - a compact self-tuning hack.
The lo nibble still selects one of nine 12-byte distance tables;
only formats 0-8 are valid (table space ends at 9 entries).
