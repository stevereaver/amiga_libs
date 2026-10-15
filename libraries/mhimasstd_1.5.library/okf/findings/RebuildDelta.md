# Rebuild delta

- Semantic port, not byte-identical.  Shipped binary is SAS/C
  (link a5 + jsr(pc) stubs); rebuild uses GCC -m68000.
- MHIQuery/MHIPlay/MHIStop/MHIPause bodies are minimal-shape ports;
  the shipped versions do the CIA-B bit twiddling for the MAS
  protocol (worth a deeper pass if bit-exact protocol matters).
