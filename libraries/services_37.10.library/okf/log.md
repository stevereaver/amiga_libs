# Log

## 2026-10-10T17:15:00Z -- reconstruction complete

- Parsed single-hunk services.library 37.10: RomTag
  AUTOINIT v37 (rev 10 from datatab), InitTable@0x4c
  (dataSize 0x9a), word-offset functab@0x5c, 6 vectors.
- Decoded framework: LibInit opens utility v37 (fail ->
  CloseLibrary(NULL-slot) + Alert(0x3800c)), inits two
  SignalSemaphores (+0x32/+0x6c) and a NewList at +0x60
  (342-byte nodes freed at expunge).  LibOpen lazily opens
  nipc.library under the +0x6c semaphore and registers the
  client via nipc -66; expunge unregisters and closes both.
- -30 SvcControl: full nipc entity-registration sequence
  decoded (anchor create -> 256B request object -> find
  "Services" -> fill request -> submit -> cleanup),
  result propagated through caller tag 0x80000802.
- -36 SvcFormat: RawDoFmt wrapper with a3@+ putch hook.
- All LVO call sites verified in the rebuilt binary
  (exec: -552/-558/-414/-108/-564/-570/-252/-258/-210/
  -198/-522; utility: -30 x3; nipc: -66/-126/-114/-138/
  -150/-144/-120/-132).
- Reconstructed in C + two-pass word-offset functab.
