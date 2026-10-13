# mhimpegit.library 1.2 — defects & quirks (all reproduced)

1. **rt_IdString/lib+24 point at a pad byte** — data+0x12 is the NUL
   between the lib name and "$VER", so the library's reported id
   string is empty and the version string is one byte late.  Both the
   RomTag field and the manual `lib+24` write use +0x12.
2. **Unchecked dos.library open** — LibInit stores the OpenLibrary
   result without testing it; if dos.library is absent the stored NULL
   later makes Drain `jsr` through a NULL a6.
3. **Create's prelude gate is inverted-looking** — fails ONLY when
   `lib+20 == 5 && lib+22 < 2`; any other version (incl. <5) passes.
   With open-ver 5 that is `5.0/5.1` rejected, `>=5.2` or anything
   else accepted.
4. **Create leaks prelude.library on every failure** — the base is
   stored to data+0x114 before validation and never closed on the
   gate/alloc fail paths.
5. **Create never checks the list-block AllocVec** — OOM passes NULL
   to the NewList helper, dereferencing address 0.
6. **Destroy leaks the 12B MinList block** and a Destroy(NULL) leaves
   prelude open; Destroy always closes the shared prelude base even
   though Create re-opens it per object (use-counting broken by
   design — second Create overwrites data+0x114).
7. **Append never checks its AllocVec** — OOM writes to address 0.
8. **Append's NULL-obj return is `v1 & 0xffff0000`** — the original
   runs `clrw d0` on the v1 argument register, leaking its high word.
9. **Query reads `*(prelude+0x8e)+0x10` with a possibly-NULL
   prelude base** when no Create has run — a wild low-memory read.
10. **Iterate processes the tail sentinel when the list is empty** —
    lh_Head==&lh_Tail makes the loop test flag@+16 of the 12-byte
    header block (OOB read), then dereferences NULL via `tstl a5@`.
11. **Pop's gate compares unrelated counters** —
    `*(prelude+0x8e)+0x10 >= obj+8` mixes the shared prelude depth
    with the object's node count.
12. **Dispatch ignores op high bits** (`d0.w>=7` only) and every call
    leaves stale register residue; ops 1/2/4 silently do nothing.
13. **-72 stub returns stale d0** and still reloads a4 with the data
    base it never uses (dead instruction preserved).
14. **-18 Expunge returns the freed seglist pointer** — fine, but note
    it also closes data+0x96 DOS base and leaves libbase/execbase
    slots stale.
