---
type: Finding
title: GhostRider quirks
---

# Quirks

1. **Close never expunges.**  LibClose decrements lib_OpenCnt,
   tests LIBF_DELEXP -- then returns 0 either way.  The
   branch-if-set target is the same `rts`, so the DELEXP test is
   dead code and a close can never trigger expunge; the library
   only goes away via an explicit Expunge call with count 0.
   Reproduced literally (see [LibClose](../functions/LibClose.md)).

2. **Handler eats the whole input chain.**  The input handler
   returns NULL unconditionally, so while the handler is armed
   *every* input event is consumed each tick -- not just the
   trigger.  Presumably intentional: "GhostRider" locks the user
   out of the machine while the ghost is riding.

3. **Entry returns 20.**  The +0 stub is `moveq #20,d0 / rts`;
   executing the file as a program yields 20.

4. **GRDispatch hardcodes key 0.**  LVO -30 looks like a generic
   "call function by id" but the findfn parameter is `moveq #0`;
   it always invokes table entry 0 and discards all results.

5. **Re-arm updates config silently.**  GRArm stores
   mode/key/qual before checking the installed flag, so calling
   it again while armed changes the trigger without reinstalling
   (early-out, returns 0).

6. **Reply-port node named "Setup GhostRider Launcher".**  The
   private reply MsgPort is AddPort'ed publicly under that name;
   the actual service lookup uses "GhostRider.Port" (the
   launcher's port).  ln_Pri is `st` (-1).

7. **port+0x22 read is off-struct.**  The launcher table pointer
   lives one longword past a standard MsgPort -- the launcher's
   port is larger than usual by private contract.

8. **`installed` flag value.**  Original uses `st` (0xff);
   reconstruction writes 1 -- semantically identical (only
   tstb-tested).
