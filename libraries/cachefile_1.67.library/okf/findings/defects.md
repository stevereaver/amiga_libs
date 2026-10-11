# cachefile.library 1.67 — shipped defects & quirks

## 1. Expunge is dead code (critical)

Vector -18 targets the `return 0` stub at hunk+0x1be, and LibClose's
deferred-expunge path also branches to that stub, not to the real
expunge body at hunk+0x1c2. Nothing can ever expunge the library —
arguably deliberate (the spawned daemon executes the library's own
hunk, so expunging while it lives would be fatal), but the full
expunge implementation sits in the binary as unreachable dead code.

## 2. CacheFile_FreeAll deadlocks (critical)

-48 obtains the semaphore, then calls -42 per node, which obtains the
same semaphore again. Exec semaphores are not recursive — the second
obtain blocks forever on any non-empty list.

## 3. Semaphore helper quirks

- The "shared lock" shim (0x348) calls `AttemptSemaphoreShared` (-720)
  and `ObtainSemaphoreShared` (-678) on exec < 39, versions where these
  LVOs do not exist — latent crash on old kickstarts.
- Shared acquisitions are released with plain `ReleaseSemaphore`
  (0x37e), not `ReleaseSemaphoreShared`, on V39+.
- `CacheFile_Free` decrements `count` *after* releasing the
  semaphore — a small race window; count is protected by nothing.

## 4. -36 closes the caller's filehandle on Read failure

If `Read` returns < 0 the function `Close(fh)` — a handle the caller
opened and owns — before freeing the node. On AllocVec failure the fh
is left open instead. Asymmetric ownership.

## 5. Daemon exit handshake is a busy-wait

The dead expunge signals bit 12 then spins on `tst.l _ltask` until the
daemon clears it — burning CPU with no timeout. Harmless only because
the expunge itself is unreachable.

## 6. Daemon opens with MODE_READWRITE (1005)

Every notify-triggered reload opens the watched file read-write,
failing (silently skipping the reload) on read-only media.

## 7. Name folding is ASCII+high-page only

`CacheFile_Find`'s fold maps `0xe0`-`0xf6`/`0xf8`-`0xfe` to uppercase
but skips `0xf7` (÷) and `0xff` (ÿ) — ISO-8859-1-aware but
incomplete; `0xf8` (ø) folds but `0xff` doesn't.

## 8. Init failures are partially unchecked

`CreateNewProc` failure returns 0 (correct) but leaves dos.library
open — the close path is in the unreachable expunge. If OpenLibrary
itself fails the code `Alert(0x38007)`s then continues with
`DOSBase = 0` and uses it anyway (the subsequent `a5@(40)` jsr would
fault).
