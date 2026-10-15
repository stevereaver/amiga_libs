# screennotify.library 1.2 — defects & quirks

## Partial-unchain frees the library anyway

On expunge each of the four patched vectors is restored and
verified. If another library repatched a vector, the restore
cascade falls through to `LAB_0029` which **still frees the
library memory and returns the seglist** — but skips `Remove`,
the worker kill, `DeleteMsgPort`, and all three `CloseLibrary`
calls. Result: the library remains linked in the exec list with
freed memory, the worker process keeps running (leaked MsgPort,
leaked 0x9c image), and the foreign patch still chains through
the freed hook code. Any subsequent call to the affected
intuition vector jumps into freed memory.

## Worker leaks the handshake message port on failure

If `CreateMsgPort` fails inside the worker it replies the
handshake msg and exits — but the reply carries `0` in body[0],
so the library-side init treats `workerport == 0` as failure and
goes down the cleanup path; the reply port itself is the only
thing it cleans (correct), but the worker's 0x9c AllocVec image
is never freed (proc exit does not FreeVec it on that path).
Actually on `wfail` the worker does `jmp -378` (ReplyMsg) then
falls off — the image stays allocated.

## Hardcoded signal bit 8

Every per-block notify port gets `mp_SigBit = 8` written
unconditionally (`move.b #$08,15(a3)`). If task signal bit 8 is
already allocated for another purpose, the synchronous
WaitPort/GetMsg handshake can wake on unrelated signals or lose
the ack.

## Broadcast blocks on uncooperative clients

Each notify is PutMsg + WaitPort + GetMsg — if a client never
reads its port, the walker (and therefore the intuition caller
holding it — e.g. CloseScreen) blocks forever while holding the
block semaphore. The remove path mitigates this by stealing and
replying the pending message, but only when a remove is
attempted.

## Same-task clients are silently skipped

The walker skips nodes whose `mp_SigTask == FindTask(NULL)` —
a client registering from the same task that triggers the event
never receives it (deadlock avoidance, undocumented).

## Node removed while notifier in flight

`remnode`'s failure path GetMsg+ReplyMsg drains one pending
message from the client's port and replies it — the ack goes to
whichever notifier was waiting, which is correct, but the client
loses that notification silently.

## PubScreenStatus bit-0 logic is opaque

The post-call broadcast fires type 1 both on `(req&1)==0 &&
(ret&1)==1` and on `(req&1)==1 && (ret&1)==0` — i.e. on any
bit-0 disagreement between request and result, not on an actual
public<->private transition; clients see "something may have
changed" rather than a real transition event.

## Worker exit relies on a bare Signal

Expunge signals the worker port's sigtask directly
(`Signal(task, 1<<sigbit)`) without a message; the worker only
dies because Wait() returns and GetMsg yields NULL. If a real
message is queued at the same time, the worker processes it
instead and the lib may be freed while the worker lives on —
the worker's next `jmp 548(freed_lib)` then crashes.

## Patch image refs depend on copy placement

The 0x1b0 patch image is functional only when copied to lib+470
(the PC-relative refs resolve into the lib base via the +0x35a
shadow layout). Copying it elsewhere produces hooks that read
garbage fields — this is by design but makes the code fragile to
any relayout.
