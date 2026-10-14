# Quirks (preserved byte-identically)

- rt_Init returns the **template ptr** (code+0x72), not the base
  MakeLibrary returned — `movel a3,d0` where a3=a1.  Whether this is
  intentional is unknown; the returned value is code+0x72.
- rt_Init forwards its incoming a0 as MakeLibrary's `vectors` arg and
  stores it as the "seglist" — the real loader must pass a pointer to
  the jmp table in a0 (nonstandard contract for a non-AUTOINIT
  resident).
- Expunge calls exec `Remove` on the **template** (code+0x72), not on
  the live library node.
- `_h2` (FreeSignal/RemPort helper): the not-allocated bmis skips the
  `moveq#0,d0` and lands on the bare `rts`, returning the negative
  sigbit byte in d0.
- Dispatcher's `beqs` at 0x1a0 jumps to a bare `rts` (skips the
  moveml pop on the d0==0 path — correct only because that bsr-call
  site hasn't pushed regs).
- `_Gone` tail's bne/beq route to the shared `rts` at 0x44e (inside
  _h3's epilogue) instead of its own trailing rts.
- PortSetup retry loop (dbf) re-enters at 0x4ac, skipping the Forbid
  and sysbase reload on iterations 2..8.
- Strings are packed with no alignment pads (several start on odd
  addresses); "rexxsyslib.library" is carved out of the middle of the
  "Can't find rexxsyslib.library" error string (offset +11).
- Port-name uniquify writes `':'-d2.b` at the tail: first collision
  appends '9', counting down (';',':','9'..).
