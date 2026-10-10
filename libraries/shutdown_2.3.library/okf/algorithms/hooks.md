# algorithms

## shutdown-hook registration
A shared MinList of {MinNode, name, callback, namebuf} nodes, guarded by sem1 (Obtain/Release around AddTail / Remove+FreeVec). FireShutdown serialises invocation with sem2 via `AttemptSemaphore` (non-blocking — a second concurrent fire just returns 0).

The per-open context carries its own dos/utility bases (opened lazily in ctx_init, closed in ctx_free) — the original uses these for the hook-invocation helper and any DOS work the hooks trigger.
