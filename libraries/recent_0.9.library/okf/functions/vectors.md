# recent.library — vectors

All 13 function-table entries are absolute longs (ftab @h0+0x84,
terminated by 0xffffffff). `-6` is the InitTable initfn; the table
below starts at Open.

| LVO | name      | entry | signature / semantics |
|-----|-----------|-------|------------------------|
| -12 | _open     | 0x124 | `a6=lib -> a6` : increments OpenCnt, returns lib base. Standard SAS/C form. |
| -18 | _close    | 0x132 | `a6=lib -> 0` : decrements OpenCnt; if it hits 0 and the deferred-expunge flag (lib flag byte) is set, falls into _expunge. |
| -24 | _expunge  | 0x146 | `a6=lib -> seglist|0` : if OpenCnt>0, sets the deferred flag and returns 0; else exec Remove(lib), CloseLibrary(dos), CloseLibrary(gadtools), FreeMem(lib-neg, 0x34+neg). Returns seglist (h0 base). |
| -30 | _nullv    | 0x19c | `-> 0` stub (`moveq #0,d0; rts`). |
| -36 | _load     | 0x1a0 | `a0=name, a1=&out -> d0=1|0` : allocates a 12-byte group-header block (`blk[0]`=name copy, `blk[4]`=`"ENVARC:Recent/"+name` buffer, `blk[8]`=sub-block list head), opens the ENVARC file (MODE_OLDFILE 0x3ed), verifies `RCNT` magic, then reads groups and stores `*a1=blk`. On any failure frees everything, `*a1=0`, returns 0. |
| -42 | _free     | 0x400 | `a1=&blk -> 0` : walks blk[8] sub-block list, FreeVecs every record name buffer (`rec[4]`), each sub-block's menu buffer `[0x10]`, each stored menu `[0xc]` via gadtools FreeMenus, each sub-block, blk[0]/blk[4], and blk itself; `*a1=0`. |
| -48 | _touch    | 0x4b2 | `a0=blk, a1=docpath, d1=key -> 1|0` : dos.Lock(path, ACCESS_READ(-2)); finds sub-block with `sub[4]==key`; allocs 0x100 path buffer and dos.NameFromLock resolves the lock to a full path (then UnLock). Scans existing rec[4] name strings for the resolved path: on match, bubble-swaps that 20-byte record to slot 0 (5 longs/iter); else shifts all used records down one and inserts at 0 — evicting (FreeVec name of) the last record when `used==max`. dos.DateStamp stamps rec+8; rec[0]=basename pointer (after last `/`/`:`). Returns 1, or 0 on Lock/NameFromLock/key-match failure. |
| -54 | _addblk   | 0x6b2 | `a0=blk, d0=key, d1=maxcnt -> 1|0` : head-inserts a new sub-block (size 0x14+maxcnt*0x14): `[0]`=next, `[4]`=key, `[8]=[9]`=maxcnt, `[0xa]`=0 used. Returns 1 even when the key already exists (early-out) — see quirks. |
| -60 | _getblk   | 0x726 | `a0=blk, d0=key, a1=out, d2=maxn -> d0=used` : finds sub-block by key, returns its used count; copies min(used, maxn) 20-byte records into `out` (caller's buffer). |
| -66 | _save     | 0x7a6 | `a0=blk -> 1|0` : Open(blk[4], MODE_NEWFILE 0x3ee); writes `RCNT`; per sub-block: key(4B), then 2 bytes @[9] (`[9]`=max, `[0xa]`=used), then per record: namelen byte (scratch `[0xb]`), name string, 12-byte record payload. Close on success; returns 1. Any short write -> Close, return 0. **Defect**: record loop is `dbra(used-1)` with no zero check — a group with used=0 writes 65536 phantom records (see findings). |
| -72 | _setmax   | 0x8a4 | `a0=blk, d0=key, d1=newmax -> 1|0` : finds sub-block; if newmax > current max ([8]), AllocVecs a bigger sub-block, CopyMem's records, FreeVecs old, relinks into the list; if newmax <= max, stores `[9]=d1` (effective max) and FreeVecs the name buffers of records beyond it. Returns 0 if blk/key/d1 invalid. |
| -78 | _menu     | 0x9c6 | `a0=blk, d0=key, d1=? -> menu|0` : finds sub-block; (re)builds a GadTools NewMenu array at `sub[0x10]` (alloc: `(used+2)*0x14` + 4 size prefix; entry type 2 header then type-3 item per record with rec basename/name); calls gadtools CreateMenusA(menu array, taglist d1) and stores the result in `sub[0xc]` after FreeMenus'ing the previous one. Returns the new menu pointer. |
| -84 | _savefree | 0xafc | `a1=&blk -> d0` : `_save(*a1)` then `_free(a1)` — one-call persist+teardown. Return value is `_free`'s (0) — the save status is discarded. |

## Library-private fields (dsize = 0x34)

| off  | use |
|------|-----|
| +0x20| OpenCnt (word, SAS/C std) |
| +0x22| flags byte? (SAS/C std layout) |
| +0x24| name/id string ptrs area |
| +0x26| dos.library base (long) — accessed via `a6@(0x26)` |
| +0x2a| gadtools.library base (long) — accessed via `a6@(0x2a)` |
| +0x2e| (unused/deferred flag region) |

External calls used: exec `Alert`(-0x6c), `Remove`(-0xfc), `FreeMem`(-0xd2),
`RemLibrary`? (-0x192 via exec is RemLibrary? — actually -0x192 is used on
**dos**: NameFromLock), `OpenLibrary`(-0x228), `CloseLibrary`(-0x19e),
`AllocVec`(-0x2ac), `FreeVec`(-0x2b2), `CopyMem`(-0x270);
dos `Open`(-0x1e), `Close`(-0x24), `Read`(-0x2a), `Write`(-0x30),
`Seek`(-0x42), `Lock`(-0x54), `UnLock`(-0x5a), `DateStamp`(-0xc0),
`NameFromLock`(-0x192);
gadtools `CreateMenusA`(-0x30), `FreeMenus`(-0x36).
