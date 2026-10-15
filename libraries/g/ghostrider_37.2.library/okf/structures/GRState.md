---
type: Structure
title: GRState
---

# GRState -- static state block (a5 in the original, hunk+0x338)

Zeroed space embedded in the code hunk after the code (0x338-0x3a8).

| offset | size | field |
|--------|------|-------|
| +0x00 | 4 | unused pad |
| +0x04 | 1 | installed flag (`st` = 0xff when handler installed) |
| +0x05 | 1 | pad |
| +0x06 | 22| struct Interrupt (input handler node; ln_Pri 64, ln_Name = literal 973, is_Data 0, is_Code -> hunk+0x2ba) |
| +0x1c | 48| struct IOStdReq for input.device (io_Data -> +0x06, io_Command 9/10) |
| +0x4c | 34| struct MsgPort reply port (ln_Type NT_MSGPORT, ln_Pri -1, ln_Name "Setup GhostRider Launcher", mp_Flags PA_SIGNAL, mp_SigTask self) |
| +0x6e | 2 | qualifier mask (GRArm d2) |
| +0x70 | 1 | keycode byte (GRArm d1) |
| +0x71 | 1 | trigger mode byte (GRArm d0 low byte) |

mode byte layout (as used by the handler):
- bit 3 (0x08): enable the RAWKEY trigger
- the full byte is compared against (ie_Qualifier>>12)&7 for
  RAWMOUSE -- so a mouse trigger only fires when mode <= 7;
  setting bit3 implicitly disables the mouse trigger.
