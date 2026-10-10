# Inconsistencies / quirks

1. **+130 is dead state.** I2CStatus() (-66) returns a longword no
   code ever writes — always 0 after zeroed alloc. Likely a stub
   for an unfinished status field.
2. **BYTE@0x42=3 dead init.** datatab writes 3 at base+66 but no
   instruction reads it (the value duplicates the hardcoded idle
   ctrl constant 3 — probably meant to be configurable).
3. **GetVar writes into the code hunk.** The 12-byte I2CDELAY
   scratch buffer lives at hunk+0x2c0, inside read-only code space;
   harmless on systems that don't protect hunks, but it means the
   loaded image is mutated at init.
4. **Over-read quirk.** ReceiveI2C with count<=0 still clocks one
   full byte (SCL toggled) before discarding it — a real bus
   transaction for a zero-length request.
5. **Last-byte NACK on send counts as success.** If the final data
   byte is NACK'd the send reports err=0 (d1==0 branch taken first).
6. **RestartI2C clears the shutdown flag outside the semaphore**
   while ShutdownI2C set it inside — a narrow race window.
7. **AllocI2C returns 0 when already claimed**, making success and
   "claimed by earlier open" indistinguishable; the only failure is 5.
8. **Error-string packing overlaps.** Index 13 rides the tail of
   "no temporary shutdown" ("temporary shutdown") and five slots
   share "???" — deliberate but fragile.
9. **Module entry returns 10** rather than a clean -1/0.
10. **Error code byte0 semantics inverted:** any nonzero byte0 maps
    to "OK" while zero maps to "error" — backwards-looking but
    shipped as-is (result record sets byte0=0xff only on success).
