# cachefile.library — function detail

## -30 CacheFile_Find(a1=name) — 0x38a

Shared-locks the semaphore (see helpers), walks the node list comparing
`node->ln_Name` to the arg with a locale-less fold: uppercase `a`-`z`
plus high-ASCII `0xe0`-`0xf6` and `0xf8`-`0xfe` (excludes `0xf7`
division sign and `0xff`) via `&0xdf`. Returns the node or 0.

## -36 CacheFile_Load(d0=fh, a1=name) — 0x3f4

Obtains the semaphore, measures `strlen(name)+1`, `Seek(fh,0,END)`
then `Seek(fh,0,BEGIN)` to recover the size, AllocVecs
`size+1+namelen+588` with `MEMF_PUBLIC|CLEAR`, copies the name to +584,
even-aligns the data pointer, `Read`s the whole file, NUL-pads at the
*read result* length (not the requested size), fills ln_Name and the
embedded NotifyRequest (nr_Name->path buf, nr_UserData=node,
nr_Flags=9, nr_Port=daemon port), `NameFromFH`s the path, arms
`StartNotify` (clears nr_Name on failure), manual AddTail, count++.
On AllocVec or Read failure: releases and returns 0 (Read failure also
Closes the caller's fh — see defects).

## -42 CacheFile_Free(a1=node) — 0x534

Obtains the semaphore, `EndNotify` if armed, `Remove`, `FreeVec`,
releases, count-- (after release, using the caller's a6 base — the
register-save quirk is reproduced).

## -48 CacheFile_FreeAll() — 0x50c

Obtains the semaphore then calls -42 on every node — which obtains the
semaphore again. **Deadlocks** on a non-empty list; verbatim.

## -54 CacheFile_GetList() — 0x504

Returns `base+94` (the `struct List`).

## -60/-66 CacheFile_Data / CacheFile_Size

Return `node+580` / `node+576`.

## Embedded daemon (hunk+0x23c, spawned as "CacheFile_Notify")

Copies libbase to its own view, publishes `ThisTask` at hunk+0xf4,
creates a MsgPort (stored at base+110), then loops:

1. `GetMsg` → if none `Wait(portmask)`; **bit 12 set → quit path**
   (DeleteMsgPort, clear the +0xf4 handoff, exit).
2. On a message: opencnt++ (blocks expunge), ObtainSemaphore, grab
   `msg->nm_NReq`, ReplyMsg, then drains and replies all *queued*
   messages for the same NR in one pass.
3. Finds the node (`NReq-14`) in the list, `Open(node->path,
   MODE_READWRITE=1005)`, calls **-36** to build a fresh node, `Close`,
   then calls **-42** on the stale node — atomic-ish swap-in-place.
4. ReleaseSemaphore, opencnt--, loop.

Callers holding an old node pointer must re-`Find` after a change.

## Semaphore helpers (shared daemon/API)

- 0x330: `jmp ObtainSemaphore(sem@48)`
- 0x33c: `jmp ReleaseSemaphore`
- 0x348: versioned "shared or bust" shim — exec >=39 →
  `jmp ObtainSemaphoreShared`; else AttemptSemaphoreShared →
  AttemptSemaphore → ObtainSemaphoreShared chain (pre-39 systems that
  lack these LVOs still reach them — see defects).
- 0x37e: `jmp ReleaseSemaphore` (plain release even after the shared
  shim — technically mismatched on V39+, verbatim).

## Dead code (hunk+0x1c2)

The real expunge body: Remove, free all nodes (helper @ 0x574),
`Signal(daemon, bit12)`, busy-wait on the +0xf4 handoff,
CloseLibrary(dos), FreeMem, return seglist. Never reached — see
findings/defects.md.
