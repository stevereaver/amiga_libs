# Algorithms — memorymanage.library 1.01

## MMUAttach (-30)

1. If base+38 non-NULL -> return it (already attached).
2. MMUReadRegs(&saved): Forbid, Supervisor(sv_readregs), Permit.
3. Reject if any TTR enable bit set: btst #7 at block bytes
   10/14/18/22 = bit15 of DTT0, DTT1, ITT0, ITT1.
4. ++refcnt (word); wrap -> fail.
5. If saved TC bit15 set (MMU already enabled):
   active=0xff, freeblks=0, +38 = saved SRP & ~0x1ff; return it.
   (Existing tables are adopted; no profile is written.)
6. Else build own config:
   - AllocVec(0x100, PUBLIC|CLEAR) -> regionbuf (+46).
   - avail = AvailMem(0x80004 = KICK|FAST).
   - Repeat next_extent() (TypeOfMem scan, mask=4 FAST, 256KB steps)
     storing {start,len} pairs until the running total covers avail.
   - AllocVec(0x410) -> root block; table at +0x1ff-aligned; fill
     128 entries stepping 0x02000000 from 0; trailer at table+512 =
     {0, alloc, 0, 0}; +42 = +38 = trailer.
   - MMUMapIdentity(0, 16MB).
   - For each extent {s,l} with s >= 16MB: MMUMapIdentity(s, l).
   - patch = FreeVec(regionbuf); write patch into both profiles'
     +4 (SRP) and +12 (DTT1); MMUWriteRegs(prof_att @0x37c).
7. Return base+38.

## next_extent(a1=scan, d1=mask) -> a0=start, d0=len, a1=cont

Step a1 += 0x40000 until TypeOfMem(a1)&mask != 0;
start = a1 & ~0x7ffff (512KB floor); step again until &mask == 0;
len = (a1 & ~0x7ffff) - start.

## MMUMap (-42): a0=vaddr a1=phys d0=len d1=flags

desc = (phys&~0xfff) | flagbits (see vectors.md).
root = +38; if !active: root = (root[1] + 0x1ff) & ~0x1ff
  (re-derives the real table through the node's alloc field —
   when active, +38 IS the adopted physical SRP and is used raw).
Loop:
  i1 = (vaddr>>25)&0x7f; if !(root[i1]&2): alloc mid (0x410),
    fill 128 x stepping 0x40000 from root[i1]&0xfffc0000, trailer,
    root[i1] = mid|2.  Else mid = root[i1]&~0x1ff.
  i2 = (vaddr>>18)&0x7f; same for leaf (0x210, 64 x 0x1000 from
    mid[i2]&0xfffff000).  Else leaf = mid[i2]&~0x1ff.
  i3 = (vaddr>>12)&0x3f.
  while len >= 0x1000: leaf[i3]=desc; desc+=4K; vaddr+=4K; len-=4K;
    if len==0 done; if ++i3 >= 64 -> re-walk whole hierarchy.
Tail page (<4KB remainder) is never mapped.
Returns d0 = entry-len (the leaf base lands in a2 but is movm'd away).

## MMUDetach (-36)

--refcnt; if nonzero -> done.  If freelist: when !active
MMUWriteRegs(prof_det @0x396) — writes the SAME patched profile,
not the saved original regs; then two walks: slot <- olddesc, then
FreeVec(alloc).  Clear +42 and +38.
