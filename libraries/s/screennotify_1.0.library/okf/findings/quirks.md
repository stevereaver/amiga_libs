# screennotify.library 1.0 — quirks & defects

- **Unhook order is destructive-first**: `_uninstall` SetFunctions all
  four vectors back to the saved originals unconditionally (pass 1),
  THEN checks whether the returned current values were all ours.  When
  a foreign patcher sits on top, pass 1 momentarily exposes the
  original vectors and pass 2 pushes the foreign handlers back.  Net
  effect: on the abort path the slots end up with the foreign handler
  restored and our handlers *removed from the chain entirely* — the
  foreign patcher's saved-next pointer still references our (resident,
  since expunge aborted) handler.  Consistent only because expunge
  refuses to complete in that state.

- **Broadcast reuses one shared Message** per class object: the same
  28-byte embedded message is PutMsg to every subscriber in turn; each
  iteration ends with WaitPort+GetMsg on the object's own port to reap
  the client's expected ReplyMsg.  A client that never replies stalls
  every subsequent subscriber (and the calling task) inside the
  patched intuition call.

- **Same-task ports skipped**: subscriber ports whose mp_SigTask is the
  calling task are skipped, preventing self-deadlock — but also meaning
  a task never receives its own screen's close notification if it
  closed the screen itself.

- **CloseScreen notify precedes the close**: type-0 message arrives
  while the screen still exists, before old CloseScreen runs.

- **Contended unregister drains the caller's port**: when
  AttemptSemaphore fails, `_remnode` GetMsg+ReplyMsg's one message off
  the *client* port (node+10) — silently consuming a pending client
  notification.

- **mp_SigBit/SigTask assigned per broadcast**: the embedded ports have
  a fresh AllocSignal bit each broadcast; on AllocSignal failure the
  whole broadcast is skipped and the wrapper just chains to the old
  vector.

- **msg+24 semantics differ per class**: Screen* for close, the
  PubScreenNode* found by the handler for pubstatus, literal 0/1 for
  workbench close/open.

- **Dead tail code**: two stack-argument wrappers (0x926 getnext,
  0x936 NewList) are never called with stack args — all internal calls
  are register-arg — plus a 30-byte block of nop/rts/moveq stubs at
  0x94a.
