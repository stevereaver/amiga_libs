# memorymanage.library — layouts

## Library base (datasize 0x4f, LIBF_DELEXP-aware)

```c
struct MMLibBase {        /* extends struct Library (34..) */
    APTR  seglist;        /* 0x22 */
    APTR  rootinfo;       /* 0x26: 16-aligned root node, or saved CRP addr */
    APTR  freelist;       /* 0x2a: node pool head */
    UBYTE saved[24];      /* 0x2e: {CRP[8], SRP[8], TC[4], pad[4]} */
    UWORD usecount;       /* 0x4c */
    UBYTE foreign;        /* 0x4e: PMMU already active at enable */
};
```

## Table node (16 bytes, appended at end of each table block)

```c
struct MMNode {
    struct MMNode *next;     /* +0 */
    APTR           block;    /* +4: raw AllocMem ptr for FreeVec */
    ULONG         *descaddr; /* +8: parent descriptor slot, may be 0 */
    ULONG          olddesc;  /* +12: previous descriptor value */
};
```

## MMU context image (24 bytes)

```c
struct MMCtx {
    ULONG crp[2];   /* +0:  [rootptr:24|limit:4|dt:2] , reserved */
    ULONG srp[2];   /* +8 */
    ULONG tc;       /* +16: bit31=E, bit15=PS(0=8K?1=...) etc */
};
```

`mm_saveregs`/`mm_loadregs` operate on this image; `mm_enable` saves
it into `base->saved` and inspects status bytes at +18/+22/+26
(valid/enable flags in the high bytes of the second longs).

## Page descriptor

4 bytes: `[phys/table addr:28 | flags:4]`, byte 3 bit 1 = DT(type-1).
Leaf entries hold `phys | flagbits` where flagbits come from
`mm_map`'s d1 argument.
