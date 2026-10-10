# functions/vectors

## LibOpen @-6
openCnt++, clear DELEXP; on first open `ctx_init` opens dos.library+utility.library (v33), inits both semaphores and the MinList. Returns base.

## LibClose @-12
decrement openCnt; on zero run `ctx_free` (close both libs) and expunge if DELEXP set.

## LibExpunge @-18
if openCnt!=0 set DELEXP and return 0; else ctx_free, `Remove(lib_Node)` + `FreeMem(base-negsize, neg+pos)`; returns seglist.

## sdStub @-30
returns 0 — no-op placeholder.

## RegisterShutdown @-36 `(callback@a0, name@a1) -> node`
if flag set or either arg NULL → 0. `len = strlen(name)`; `h = AllocVec(16+len+1, MEMF_PUBLIC|MEMF_CLEAR)`. ObtainSemaphore(sem1); h->callback = cb; h->name = inline buf; copy name; `AddTail(list, h)`; ReleaseSemaphore. Returns h.

## UnregisterShutdown @-42 `(node@a0) -> 1/0`
if flag or !node → 0. ObtainSemaphore(sem1); walk list for `p == node`; on hit `Remove` + `FreeVec`, release, return 1; miss → release, return 0.

## FireShutdown @-48 `(flags@d0)`
if `!AttemptSemaphore(sem2)` → 0. Iterate the hook list calling each `callback(flags)`; `ReleaseSemaphore`; return 1.
