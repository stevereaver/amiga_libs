# memorymanage.library — shipped defects and constraints

1. **68030-only.** All PMMU instructions (`pmove`/`pflusha`/`ptestr`)
   are 68851/68030-specific. On 68040/060 the CRP/TC bit layouts
   differ — the context image written here would be interpreted
   incorrectly. On 68000/010/020 the library traps immediately
   inside `Supervisor()`. No CPU check is performed anywhere.

2. **Uncooperative translation.** `mm_map` inserts page descriptors
   into tables it allocates itself, but does not flush the ATC
   after modifying them — callers relying on `pflusha` behavior get
   it only from the enable/disable/loadregs paths. Incremental
   `mm_map` on a live context can leave stale translations.

3. **Enable clobbers live descriptors without coordination.** When
   `mm_enable` finds the PMMU already active (`foreign=1`) it adopts
   the existing root pointer, but subsequent `mm_map` calls write
   descriptors into tables belonging to whatever foreign context was
   running — there is no refcount or ownership on the adopted tree.

4. **`mm_disable` restore relies on stored `descaddr`/`olddesc` only
   for tables allocated by the library.** For the foreign path the
   saved ctx is reloaded via `_mm_ctx_disable`, but if the foreign
   OS context was itself changed underneath, the restored CRP/SRP/TC
   image may be stale — it was snapshotted at enable time.

5. **Allocation-failure path leaves partial state.** In `mm_map`,
   if the level-B AllocMem fails the code branches around the fill
   but still proceeds to test/write through the just-allocated
   (null) table descriptor — faithful reproduction kept in
   `memorymanage_lib.s` (the `bcs` to the shared fill loop skips
   init but not the descriptor write).

6. **`mm_vatophys` ignores `ptestr` failure.** The MMUSR result is
   never checked; a failed translate returns
   `(desc & ~0xfff)|(va & 0xfff)` computed from whatever stale bytes
   `a1` pointed at — indistinguishable from a real address except
   that desc may be garbage.

7. **No locking.** Enable/disable/map mutate shared library fields
   and the table tree with no semaphore; concurrent tasks race.
