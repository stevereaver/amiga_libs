# screennotify.library 1.0 — vectors

Long-absolute functab at code+0x5e, `-1` terminated. 10 vectors.

## Standard

| LVO  | offset | function                                                |
|------|--------|---------------------------------------------------------|
| -6   | 0x192  | Open: opencnt++, clr DELEXP; first open does `OpenLibrary("intuition.library",37)` into lib+40 and installs the 4 hooks via SetFunction |
| -12  | 0x1d8  | Close: opencnt--, deferred expunge when count hits 0 with DELEXP set |
| -18  | 0x216  | Expunge: open→set DELEXP; else unhook intuition (`_uninstall`), on success Remove/CloseLibrary(intuition)/FreeMem, returns seglist; aborts (returns 0, stays resident) if a foreign patcher wrapped any hook |
| -24  | 0x29e  | null → 0                                                 |

## Private API

| LVO  | offset | args                          | returns | class                                  |
|------|--------|-------------------------------|---------|----------------------------------------|
| -30  | 0x832  | a0=screen, a1=port, d0=pri    | node\|0 | register screen-close notify (18 B node, +14=screen) |
| -36  | 0x866  | a0=node                       | bool    | unregister from obj0 list              |
| -42  | 0x88a  | a0=port, d0=pri               | node\|0 | register PubScreenStatus notify (14 B node) |
| -48  | 0x8b4  | a0=node                       | bool    | unregister from obj1 list              |
| -54  | 0x8d8  | a0=port, d0=pri               | node\|0 | register WorkBench notify (14 B node)  |
| -60  | 0x902  | a0=node                       | bool    | unregister from obj2 list              |

Register = AllocMem(size,MEMF_PUBLIC) node{ln_Pri=pri, ln_Name=port},
Enqueue into the class list under its SignalSemaphore; -30 also stores
the screen at node+14.  Unregister = AttemptSemaphore: on success
Remove+FreeMem and return 1; on contention it drains ONE pending msg
off the *client's* port via GetMsg+ReplyMsg and returns 0.

## Patched intuition vectors (installed on first Open)

| intuition LVO | name            | handler | behaviour |
|---------------|-----------------|---------|-----------|
| -66  | CloseScreen        | 0x2b4 | broadcast type-0 msg {screen} to obj0 subscribers: wildcard nodes (+14==0) and nodes matching the closing screen; then calls old CloseScreen |
| -78  | CloseWorkBench     | 0x574 | broadcast type-3 arg=0 BEFORE old; if old returns 0, broadcast type-3 arg=1 after |
| -210 | OpenWorkBench      | 0x5b4 | call old first; on success broadcast type-3 arg=1 |
| -552 | PubScreenStatus    | 0x4c4 | LockPubScreenList, find node(+14)==arg; if (arg&1)==1 broadcast type-2 (pre); call old; if (arg^result)&1 → broadcast type-1 (post) |

Broadcast messages reuse the per-object embedded 28-byte Message
{ mn(14B), ReplyPort=embedded port, Length=28, +20 type, +24 arg },
PutMsg to each subscriber port *except* ports owned by the calling
task (mp_SigTask compare — avoids deadlock, the sender would WaitPort
on itself otherwise).  Each send is followed by WaitPort+GetMsg on
the object's own embedded port to reap the client's ReplyMsg, so the
shared message can be reused serially.
