# RunBar.library 1.0 — OKF index

SAS/C-built support library, `$VER: RunBar.library 1.0
(24.11.96)` — part of the RunBar commodity/toolbar tool.  The
library is a **registration + synchronous message-dispatch
table**: 16 slots (15 usable — loop bound quirk) keyed by an
opaque long, each slot owning an anonymous MsgPort.  Clients
register a handler object, others post a fixed 28-byte request
message `{0x8080000X, arg}` to the slot's port and WaitPort on a
private reply port.

- Binary: `binary/RunBar_1.0.library` — 2156 bytes, m68k,
  three hunks (CODE 0x704B / DATA 36B / DATA 88B), AUTOINIT.
- Reconstruction: `source/` — `runbar.c` (register-ABI C) +
  `runbar_lib.s` (RomTag + DATA-hunk InitTable + functab).
- InitTable lives in the DATA hunk at +4 (rt_Init -> hunk1+4);
  datatab is NULL — LibInit fills the library header by hand,
  then copies a 32-long template (overrunning the 36-byte hunk)
  into lib+48 and runs a dead base-relative fixup pass.
- Register-parameter ABI (a6 = base; args in d0/a0..a3), so the
  vector entries can be plain `__asm`-bound C functions — no
  stubs.

## Contents

- `functions/vectors.md` — LVO map + per-vector semantics
- `structures/layout.md` — lib base / priv block / slot /
  RBObj / RBMsg layouts, hunk map
- `findings/defects.md` — quirks: locked-remove returns 1,
  OOB template read, slot[15] unreachable, Reset leaks ports,
  dead hooks, dead compares
- `log.md` — RE session log
