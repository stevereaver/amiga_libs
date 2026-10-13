# utility 41.0 (020) — defects & inconsistencies

All reproduced in the reconstruction, oracle-verified byte-identical.

## FreeNamedObject frees the wrong pointer

`lea a0@(-16),a0; jsr a6@(-690)` — the block address is computed
into **a0**, but exec FreeVec takes its argument in **a1**.  The
function therefore FreeVecs whatever stale pointer the caller left
in a1 (observed freeing a message pointer instead of the node).
Reproduced in `utility_lib.s` by leaving a1 untouched.

## Pack/UnpackStructureTags stream desync

The table reader only performs a paired {tag,pstg} fetch once;
every continuation path (`bras 0x5ce`) reads a single pstg longword
with the tag register frozen.  Consequences:

- In a normal {tag,pstg}-pair table, entry N's tag longword is
  consumed as entry N+1's pstg — so subsequent lookups use a stale
  tag and the offset/type bits of what was meant to be a tag.
- bit29 (pack) / bit30 (unpack) "skip" entries step one longword,
  not one pair.
- Count includes entries processed after desync (orig `Pack 5` on a
  3-entry table, writing `0x5678`/`0x78` — fragments of the first
  value — into fields meant for other tags).
- Table offset is `addaw` — sign-extended low 16 bits only.

## UnpackStructureTags writes through ti_Data

`moveal a0@(4),a0` then `movel d1,a0@` — ti_Data is treated as a
destination POINTER and always receives a 32-bit store, even for
byte/word fields.  (Matches the real utility.library semantics but
surprising vs the doc'd API.)

## RemNamedObject fall-through

After removing a node and stashing the caller's message in obj[8],
RemNamedObject falls through into ReleaseNamedObject: refcount is
decremented and, on reaching 0, the stored message is replied.

## AllocNamedObjectA quirks

- NULL name returns the incoming a0 (0), not an error code —
  `beqs` to the ReleaseNamedObject `rts`.
- ANO_NameSpace is a boolean: any nonzero value allocates the
  62-byte namespace block; it is not a size.
- refcount (word @node+14) starts at 1 via `addqw`.

## FindNamedObject a2 seed

The caller's a2 is read as a "previous object" pointer; when nonzero
the scan starts at `a2@(-16)` — the node of the previous object —
so an uninitialised a2 dereferences garbage.

## Lifecycle stubs

- Expunge (-18) and reserved -24 are the same `moveq#0;rts`;
  Close just decrements OpenCnt.  The library can never be removed.
- lib_Revision is explicitly cleared to 0 in init.

## CloneTagItems terminator

CloneTagItems counts n+1 (the NextTagItem loop increments before
testing), allocates (n+1)*8, and RefreshTagItemClones writes a
single 4-byte terminator longword; ti_Data of the terminator stays
0 from MEMF_CLEAR.

## Init namespace overrun (deliberate)

LibInit creates the default object with `{ANO_NameSpace,1}` — the
boolean quirk means a 62-byte ns block is allocated (not 1), so the
"small namespace" request actually creates a full block.
