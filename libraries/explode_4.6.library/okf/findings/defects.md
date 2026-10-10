# Findings / defects

## Shipped quirks (preserved)

- `lib_OpenCnt` is hard-set to 1 at init and never decremented
  (Close is a shared null stub) -> the library can never be
  expunged and the LoadSeg hook is never removed.  A private
  counter at base+0x2a tracks real opens, monotonically.
- OpenLibrary("dos.library",33) failure jumps into a dead-end
  `Alert(0x80038007)` - process is killed rather than a clean
  init failure return.
- Vector-walk failure Alerts `0x00028007` then returns WITHOUT
  patching LoadSeg (the lib stays resident but inert).
- The InitStruct's first command `INITBYTE @0x0c = 9` is dead:
  overwritten by the INITLONG ln_Name that follows.
- `Explode` pops the caller's return address and uses it as the
  packed-stream pointer - packed data is inline after the JSR;
  a call without inline data will decode garbage and jump into it.
- The -23 flag byte (stream[-23]) is read inside the decrunch
  stub area; set -> stream start rewinds 4 bytes and the flag is
  ORed into the low byte of the stream-end offset.
- Raw-byte match length 0 copies 256 bytes (byte-wide `subq.b`
  loop).  Encoder presumably never emits 0.
- Both stub counters are plain `addq.l`/`add.l` to patched
  absolute operands - statistics only, unsynchronized.
- Task priority is boosted to 15 during decode and restored -
  side effect survives in the caller's task even though Explode
  tail-jumps into the decrunched program.

## Reconstruction notes

- The ring decoder, record driver and teardown are ported to C;
  the register-level calling conventions (inline-data call,
  all-register save/restore, tail-jump to the decrunched entry,
  self-patched counter stubs) live in `explode_lib.s`.
- Two fidelity bugs in the sibling 4.3 C port were corrected
  here and are filed on the Plane card: (a) the bit-reservoir
  reload must emit the new byte's MSB, not the drained
  reservoir's sentinel; (b) the `a0@(-23)` flag byte reads
  off the stream pointer, not the computed src cursor.  Also
  noted: the `subq.b` match-length loop means byte-length 0
  decodes 256 bytes, so `len` must wrap at 8 bits.
- ExplodeFrame shim adds `xf_outcount` into `xb_stub_ctr2` via a
  patched `add.l d0,(abs)` exactly like the original teardown.
