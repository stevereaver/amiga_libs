# Byte-identical rebuild

xpkRLEN_h0.s is a verbatim reassembly; fixup.py rewrites the RELOC32
tail to the original's order. `make` verifies with cmp: BYTE-IDENTICAL.
