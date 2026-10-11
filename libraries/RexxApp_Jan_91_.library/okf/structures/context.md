# RAX application context (caller-owned, carried in A5)

    struct MsgPort port;      /* +0  embedded reply port (34 bytes)
                                 mp_Flags@14, mp_SigBit@15 (bit7 = busy-
                                 initialising / invalid mark),
                                 mp_SigTask@16, mp_MsgList@20      */
    UBYTE  flags;             /* +32 bit7 = shutting down            */
    UBYTE  pending;           /* +33 outstanding sent msgs (255 = full)*/
    STRPTR ext;               /* +34 file extension / fwd enable     */
    APTR   handler;           /* +38 app verb handler                */
    APTR   rxs;               /* +42 rexxsyslib base (lazy)          */
    APTR   cb_res;            /* +46 result callback                 */
    APTR   cb_err;            /* +50 error callback                  */
    ULONG  waitmask;          /* +54 1<<sigbit, returned by Setup    */
    ULONG  pad58;             /* +58                                 */
    RaxCmd cmds[];            /* +62 {verb,data} pairs, verb NULL end */

## Callback conventions (three distinct ABIs)

- `cb_res` / `cb_err`: stack args `(ctx, msg, a0, d0)` — original pushes
  `moveml d0/a0/a2/a5,-(sp)` (mask 0x80a4) so lowest addr = a5.
- `args[15]` per-send cb: register args `a0=msg, d0=r1, d1=r2`,
  invoked via `jmp` (no stack frame).
- `handler`: register args `a2=msg, a3=data, a4=cmd-tail`.
- send validator (d1 param): stack args `(ctx, msg)` — pushes
  `moveml a2/a5,-(sp)` (mask 0x0024).

## RexxMsg field use

- `action` @28: RXCOMM 0x01000000 for all sends; RXFF_RESULT bit17,
  RXFF_STRING bit18, RXFF_NONRET bit20 tested via byte 29/30 btst.
- `args[0]` @40: command argstring (or raw string when RXFF_STRING).
- `args[14]` @96: original client msg (forward chaining).
- `args[15]` @100: per-send completion cb.
- `mn_ReplyPort` @14 == our ctx port ⇒ the msg is a reply to our send.
- `r1` @32 / `r2` @36 zeroed on incoming cmds; r1=100 when shutting
  down, r1=30 when no forward ext configured.
