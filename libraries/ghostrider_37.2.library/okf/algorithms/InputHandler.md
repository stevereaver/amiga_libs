---
type: Algorithm
title: InputHandler
---

# Input handler (is_Code, hunk+0x2ba)

Installed at priority 64 via IND_ADDHANDLER.  Walks the event
chain via ie_NextEvent and **returns NULL** -- consuming the
entire chain every tick while armed (see findings).

Per event:

- `ie_Class == IECLASS_RAWKEY (1)` and `mode & 0x08`:
  match iff `lowbyte(ie_Code) == keycode` AND
  `(ie_Qualifier & ~IEQUALIFIER_CAPSLOCK) == qual`.
  On match: write 8 to INTREQ@0xdff09a (clear PORTS irq bit),
  invoke launcher fn 0, write 0x8008 to INTREQ (set request),
  then `ie_Class = IECLASS_NULL` -- the key event is swallowed.
- `ie_Class == IECLASS_RAWMOUSE (2)`:
  match iff `(ie_Qualifier >> 12) & 7 == mode` -- bits 12-14 are
  IEQUALIFIERB_MIDBUTTON/RBUTTON/LEFTBUTTON.  On match invokes
  launcher fn 0 **without** clearing the event class (the event
  still dies with the chain since the handler returns NULL).

INTREQ dance: 0x0008 clears the pending PORTS (bit 3) interrupt
request before the callback; 0x8008 (set/clr bit + bit 3)
re-raises it afterwards -- a forced edge for downstream
interrupt handlers.
