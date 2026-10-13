# ksort.library — sort workers

Classic recursive quicksort.  All six numeric workers share
this shape (register allocation differs per variant; element
size/compare flavor varies):

```c
worker(a /*d0*/, lo /*d1*/, hi /*d2*/) {
    pivot = a[(lo+hi)/2];          /* signed tst/addq/asr /2 */
    i = lo; j = hi;
    while (i <= j) {
        while (a[i] < pivot) i++;  /* UNBOUNDED scans — safe  */
        while (a[j] > pivot) j--;  /* only because pivot is   */
        if (i <= j) {              /* always an element of a  */
            swap(a[i], a[j]);
            i++; j--;
        }
    }
    if (lo < j) worker(a, lo, j);
    if (i < hi) worker(a, i, hi);
}
```

Notes:

- The pivot index is computed as `(lo+hi)/2` with the classic
  `tst.l d0 / bpl / addq.l #1,d0 / asr.l #1,d0` sequence —
  C truncation-toward-zero on negatives.  For `count <= 0`
  (hi < 0) the partition loop is skipped, but the pivot read
  still happens at `a[(0+hi)/2]` — `a[0]` for count=0, a
  negative index for negative counts (wild read, reproduced).
- Byte workers keep elements in registers via `move.b`; word
  workers via `move.w` plus a descending `&a[j]` cursor in a
  frame slot; long/string workers use `asl.l #2` index scaling
  and the same cursor idiom.
- Signed vs unsigned variants differ ONLY in the element
  compares (`blt/bgt` vs `bcs/bhi`) — **except u32**, which
  also uses unsigned compares for all index tests (below).
- d0 return is unspecified compare residue; wrappers preserve
  d2/d7/a2 as usual for SAS/C registerized code.

## The u32 (-60) index-unsignedness defect

In the unsigned-long worker ALL index comparisons are
unsigned:

| Site               | signed variants | u32 variant     |
|--------------------|-----------------|-----------------|
| exit-inner (i>j)   | `bgt`           | `bhi`           |
| outer loop (i<=j)  | `ble`           | `bls`           |
| left guard (j<=lo) | `ble` skip      | `bls` skip      |
| right guard (i>=hi)| `bge` skip      | `bcc` skip      |

Consequence: when a partition reaches `i = j = 0` (array base)
and self-swaps, `i=1, j=-1`, the unsigned `i <= j` test sees
`1 <= 0xffffffff` → the loop CONTINUES and the j cursor walks
below `&a[0]` — `a[j]` for j = -1, -2, … — reading whatever is
there.  Each `a[j] > pivot` keeps walking; each stop swaps a
wild read into `a[i]` and an array value into `a[j]`.  Since
`i` advances by 1 and `j` retreats unboundedly, the loop only
ends when memory content happens to break it — the array is
overwritten with low-memory garbage (0 in the emulator) and
array elements are scattered below the buffer.

Trigger: any `qs(a,0,hi)` call whose scan converges on index 0
with `a[0] == pivot`.  `qs(a,0,1)` always triggers (pivot is
a[0]).  Empirically: descending n=4 and n=10 inputs corrupt
(`[1,0,0,...]` + displaced elements below the buffer), n=6/8/20
escape only because their partitions never recurse into a
base-0 self-swap.

The C reconstruction reproduces this verbatim: `qs_u32`
declares `i`, `j` and its recursion guards `ULONG`.  The other
variants keep signed indices (their shipped compares are
signed).

## String sort (-66)

Worker signature identical, but elements are `char *` and the
comparator is `stricmp(a[x], pivot)` (stack args, returns
difference).  The inner scans carry an EXTRA `i < j` bound the
numeric workers lack:

```c
while (stricmp(a[i], pivot) < 0 && i < j) i++;
while (stricmp(a[j], pivot) > 0 && i < j) j--;
```

Recursion guards and index compares are signed, like the
numeric workers.  Result order for
`{banana,Apple,cherry,APPLE,apricot}` →
`{Apple,apricot,banana,APPLE,cherry}` — a case-insensitive
sort that is not stable (equal keys keep partition order).
