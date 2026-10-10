# cxb.library — shipped defects & inconsistencies

## 1. Half-cleared context table

`INITFUNCTION` clears **128 longs = 512 bytes** at base+48:

```
LEA 48(A5),A0
MOVEQ #127,D0
L: CLR.L (A0)+
   DBF D0,L
```

But the context table is indexed by `(ThisTask & 0x380)`
added to base+48, and 16 slots of 8 bytes per region —
regions run to `base+48+0x380+0x80 = base+0x430`, i.e. the
full dataSize.  So only the **first half** of the table
(indices 0x000/0x080/0x100/0x180) is zeroed; tasks whose
`ThisTask & 0x380 >= 0x200` scan uninitialized memory —
non-empty garbage "slots" can make Open return 0 for no
reason or, worse, dereference garbage as a context.

## 2. Custom flag byte at offset 34

The library stores its delayed-expunge bit at `base+34`
(`BCLR/BSET/BTST #3,34(Ax)`).  Offset 34 (0x22) is
`struct Library`'s `lib_SegList` — the library does NOT use
that field (it keeps the seglist at base+44 instead), so it
repurposed the byte.  Anything reading `lib_SegList` at 0x22
gets a flag byte, not a BPTR.

## 3. lib_IdString points at the lib name

The InitStruct DATATABLE sets `lib_IdString` (offset 0x18)
to `libname` ("cxb.library") rather than the idstring
("cxb.library 37.1 (20.01.98)").  Cosmetic, but a real
deviation from convention — reproduced in the
reconstruction byte-for-byte.

## 4. Context slot indexing uses the task *pointer*

Slots are keyed by `ThisTask & 0x380` — bits 7-9 of the
task's ADDRESS, not `tc_Type`/`tc_Node` or any stable id.
Two unrelated tasks hashing to the same 0x380-region share
a slot region; the 16-slot run is only a linear spill.

## 5. cxbMult reads its second arg off the stack

`-36` pushes only `d0` then reads the second operand from a
stack slot — the 2-arg register ABI is thin; callers must
supply `d1`.  (The reconstruction takes a clean `d1` arg.)
