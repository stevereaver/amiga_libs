# screennotify.library 1.2 — intuition screen-event notification

- **Binary**: `binary/screennotify_1.2.library`, 1852 bytes, one code hunk
- **Id string**: `screennotify.library 1.2 (18.1.2005)` (with a separate
  `$VER: ` cookie for the version command)
- **Reconstruction**: `source/` — C (`screennotify.c`) + AUTOINIT
  skeleton and two position-dependent code images
  (`screennotify_lib.s`); builds `screennotify.library`
  (m68k-amigaos-gcc, `-m68000 -O2`)
- **Status**: complete. Header/datatab/strings byte-identical modulo
  relocated pointers; worker image byte-identical; patch image
  byte-identical except one equivalent branch displacement; all
  vectors and struct offsets verified.

## What it does

Watches intuition for screen lifecycle events by SetFunction-patching
four intuition vectors at init:

| patched vector          | LVO   | hook installed at | behaviour |
|-------------------------|-------|-------------------|-----------|
| OpenScreenTagList       | -612  | lib+470           | if `(screen->Flags & 0xf) == WBENCHSCREEN`, PutMsg to the worker port and clear the lib flag |
| CloseScreen             | -66   | lib+528           | synchronous broadcast, type 0, arg = screen, over list 1, then tail-calls original |
| PubScreenStatus         | -552  | lib+688           | finds the screen's PubScreenNode under LockPubScreenList; broadcasts type 2 pre-call / type 1 post-call on list 2 |
| CloseWorkBench          | -78   | lib+836           | broadcasts type 3 arg 0 pre-call (when flag clear); on failed close broadcasts type 3 arg 1; sets flag on success |

A worker process named **"scn service process"** is spawned via
`CreateNewProcTagList` (NP_Entry/NP_Name tags); the lib copies a
156-byte code image into an AllocVec buffer for it. The worker
handshakes back its own MsgPort, then on each message does
`Delay(10)` and rebroadcasts type 3 / arg 1 on list 3 — this
delivers the "a new Workbench-type screen opened" event
asynchronously, off the OpenScreenTagList caller's context.

## Key mechanism

The 432-byte patch image is CopyMem'd into the library base at +470
and its four hooks installed with SetFunction. Its PC-relative
references are crafted so that in the **copy** they resolve onto
library-base fields — the displacement table shares bytes with the
worker process name ("scn service process"):

    image ref target (file) = lib offset + 0x35a

e.g. the longs at 0x520/0x524/0x528/0x52c are read as addresses of
the saved original vectors at lib+454/458/462/466, and refs to
0x382/0x392/0x3ae/0x37c land on exec base@40, handshake msg@56,
worker port@84, flag@34.

The reconstruction expresses the same mapping with `.set` shadow
symbols (`xNN = pstart + NN - 470`), so the image bytes are
byte-identical to the original and work when copied to any base.

## Lib base (0x386 = 902 bytes)

See `structures/base.md`. Three identical 122-byte client-list
blocks at +88/+210/+332: `{MinList, SignalSemaphore, Message(body
= {type,arg}), MsgPort}` — notifications are synchronous: PutMsg to
each client port then WaitPort/GetMsg for the ack.

## Vectors

-6 Open, -12 Close, -18 Expunge (4-stage verified unchain +
worker kill + free), -24 null stub, -30/-36/-42/-48/-54/-60 three
add/remove client pairs (pri@node+9, port@node+10, arg@node+14).

See `functions/vectors.md`.
