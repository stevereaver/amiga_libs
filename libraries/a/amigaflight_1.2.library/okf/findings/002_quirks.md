# Finding 002 -- smaller shipped quirks

1. **Flush-per-character.** -72 and -102 call `Flush` (-360)
   after every `FPutC`/`FPuts`. Interactive-safe but O(chars)
   dos round-trips -- slow hex dumps.
2. **NewLine order.** -36 emits LF(10) then CR(13) -- the
   reverse of conventional CR-LF.
3. **LibOpen returns the arg on refusal.** `cmpl #1,d0;
   blts rts` returns the `<=0` version argument itself; a
   negative arg yields a non-NULL garbage "library" pointer.
4. **Unchecked OpenLibrary.** LibInit stores the
   `dos.library` OpenLibrary result without a NULL check;
   failing to open dos -> every I/O vector dereferences
   NULL+40-ish offsets via `a6@(40)`.
5. **AFReadHex always exits carry-set.** The loop only exits
   on a non-hex char, so C is always set on return -- the
   error flag conveys nothing.
6. **CSI half-swallow.** -48 maps a lone 0x9b to 0 but leaves
   the following escape-sequence bytes to be read as input.
7. **Empty input = address 0.** AFEnterAddress accepts an
   immediate CR as address 0 (d2 digit-count unchecked).
