# Payload writes target the segment base

Copy-out writes every non-tag 4-byte record at `segbase+0` (the asm
is unambiguous: `moveal a3,a1` into the copy).  A literal reading
means each segment only receives its first long from records - which
is consistent with the "ring IS the output" design: the executable
image materialises inside the hunks by the decoder itself, and the
record pass only patches header longs (BPTR links/sizes) plus relocs.
The reconstruction preserves the literal behaviour; the exact intent
remains a research question (see algorithms doc).
