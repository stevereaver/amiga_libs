# GRArm (LVO -36)

Signature: `GRArm(UWORD mode d0, UBYTE keycode d1, UWORD qual d2)`

- `d0 == 0` -> removal path: if `installed`, reopen input.device
  + reply port, build the IOStdReq (mn_ReplyPort, io_Data =
  &intr, io_Command = 10 = IND_REMHANDLER), DoIO, CloseDevice +
  RemPort, clear `installed`.
- `d0 != 0` -> install path: stores `mode` (byte) at state+0x71,
  `keycode` (byte) at +0x70, `qual` (word) at +0x6e **before**
  the installed check -- re-arming while installed updates the
  trigger parameters without reinstalling.  If not installed:
  openio; then builds the request with `mn_Node.ln_Type = 5`
  (NT_MESSAGE), mn_ReplyPort = &state.port, io_Data = &state.intr
  (at state+6), Interrupt `ln_Pri = 64`, `ln_Name = 973`
  (unrelocated literal, see findings), `is_Data = 0`,
  `is_Code = handler`, io_Command = 9 (IND_ADDHANDLER), DoIO,
  closeio, `st` installed (0xff).

Always returns 0 (errors from DoIO/openio are silently dropped;
an openio failure just skips the install).
