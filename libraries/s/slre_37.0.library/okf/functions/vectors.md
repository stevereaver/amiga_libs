---
file: vectors
---
# Vectors (abs-long functab @h3+0, 5 entries, -1 term)

-6 Open @h0+0xd0 — OpenCnt++, clears LIBF_DELEXP,
  AllocMem(lib[+0x36]+0x118+60 = 0x172) per-open context,
  returns context+0x1e (a pseudo-libbase: its +0x32 reaches
  the private struct); exec v36+ check -> jsr -636; internal
  helpers h0+0x1154/0x11b8/0x1188.
-12 Close @h0+0x1fe — FreeMem's the context, OpenCnt--;
  if 0 and DELEXP -> tail-calls Expunge.
-18 Expunge @h0+0x268 — sets DELEXP; if OpenCnt==0 frees the
  h1-derived seg-copy, Remove(lib) via exec -252,
  FreeMem(lib-NegSize, Neg+PosSize); returns seglist
  (libbase+0x22, stored from init's A0).
-24 @h0+0 — dummy vector pointing at the `moveq #0,d0;rts`
  guard stub in front of the RomTag (reserved/ExtFunc = NULL).
-30 @h0+0x10fc — the regex worker, register-args ABI
  (d0/d1/d2/a0=pattern?/a1=subject + A6=lib). 2424-byte
  stack frame, strlen(a0) then BSR h0+0xed2 with pushed args;
  uses lib private struct at a6+0x3c (the copied h1 table).
  Probe ("ab*c" vs "abbbc", d0=16,d1=4,d2=1) returned 5.

LVOs -6..-18 are the standard library vectors; -24 is a
deliberate null; only -30 is real API.
