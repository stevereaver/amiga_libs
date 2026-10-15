# mhimdev 1.5 — quirks and defects

- **UNIT arg off-by-three**: AllocDriver parses the MHIMDEV env var's
  `UNIT` field by reading `unitstr[3]` — the 4th byte of the argument
  string — rather than converting it to a number. For a normal
  `ReadArgs` numeric result like `"2"`, byte+3 is NUL → unit is
  effectively always 0 unless the value is padded to ≥4 chars.
  Preserved verbatim (oracle confirms `unit=0` for env `"test.device,2"`).

- **Blind 255-byte device-name copy**: the DEVICE arg string is copied
  into the handle's name buffer with `CopyMem(src, dst, 255)` — a
  fixed-size copy regardless of string length. `notb d0` after
  `moveq #0` yields d0=255 (only the low byte is inverted).
  Overreads short env strings; buffer is 255 B so writes stay inside
  the handle.

- **If `dos.library` fails to open**, the DEVICE/UNIT parse is skipped
  entirely: devname buffer stays zeroed (empty string) and unit stays 0 —
  OpenDevice is still attempted on the empty name. Verified identical
  on rebuild.

- **AllocDriver arg check is on `task` (a0), not the result**: a NULL
  task pointer makes AllocDriver return 0 immediately; a NULL sigmask
  is accepted (Signal(…,0) from the softint is then a no-op mask).

- **Pause only toggles states 0↔3**: calling Pause while state==1
  (idle/stopped) or any other value is a silent no-op. Likewise Start
  sends the cmd-9 ioreq only when state!=3 (paused → Pause instead).

- **GetStatus returns**: `1` for NULL handle, `2` for a non-pending
  state-0 handle, otherwise the raw state byte — 2 is *also* a valid
  state value, so callers can't distinguish "free" from state 2.

- **Query classifier is a hand-rolled range ladder**, not a table —
  capabilities are 1 for {1..3, 11,12, 20,21, 41, 1010} and pointers
  for {1000,1001,1002}; note 1 (not 0) is returned for d1=1..3 while
  d1=0 → 0.

- **ioreq byte@51 = 2 and long@52 cleared** on every write buffer —
  inside the io_Data/io_Length region semantics of whatever mpeg.device
  command 3 interprets; reproduced verbatim.

- **port1.mp_SigTask points into the handle's embedded Interrupt**
  (PA_SOFTINT). Exec treats SigTask as an Interrupt* for softint
  ports; the is_Data field carries the handle back to the handler.

- **vbcc runtime at tail**: `__mulsi3`/`__udivmodsi4`/`__divmodsi4`
  take stack args, but the signed wrapper enters the unsigned core at
  +6 (register args) — the `_divreg` mid-function entry is required
  for byte identity.

- **Trailing `.long 0, .long 1`** at hunk end — static data emitted by
  the compiler's runtime region.
