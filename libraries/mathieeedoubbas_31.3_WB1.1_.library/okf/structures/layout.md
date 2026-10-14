# mathieeedoubbas 31.3 — layout

## Hunk file

5 hunk table entries; hunks 3 and 4 are declared but have **zero-size**
bodies (CODE and DATA respectively). RELOC32 streams follow hunks 0-2.
The original linker's RELOC32 group order is unusual: multiple separate
groups for the same target hunk appear (e.g. hunk0 relocs to hunk0 come in
four groups, some in descending offset order). `fixup.py` splices the
exact original records back in place of ld's output.

## RomTag (hunk0 + 0x08)

```
4afc ....           rt_MatchWord/rt_MatchTag
      0144          rt_EndSkip (one-past-end of hunk0 structure)
flags 81            RTF_AUTOINIT | type bit
ver   1f (31)       type 09 (NT_LIBRARY)  pri 0
name  -> hunk0+0x1a "mathieeedoubbas.library"
idstr -> hunk0+0x32 "mathieeedoubbas 31.3 (23 Nov 1985)\r\n"
init  -> hunk0+0x58 (InitTable)
```

## InitTable (hunk0 + 0x58)

```
dataSize  0x22         (34 bytes = Library header through ln_Sum?)
funcTab   -> hunk0+0x98   14 longs, absolute, -1 terminated
dataTab   -> hunk0+0x70   InitStruct stream
initFn    -> hunk0+0x68   stores a0 (seglist) at hunk0+0x13e, rts
```

Note `dataSize` = 0x22 ends the initialized area before `ln_IdString`
(+24): the runtime library node has a **null IdString**.

## Datatab (hunk0 + 0x70)

Standard InitStruct 0x80/0x90/0xa0-form stream filling ln_Type(9),
pri(0), ln_Name, lib_Flags(06), lib_Version(31), lib_Revision(3),
lib_NegSize/PosSize supplied by InitMem.

## Functab (hunk0 + 0x98) — 14 longs

```
[0]  Open    -> hunk0
[1]  Close   -> hunk0
[2]  Expunge -> hunk0
[3]  Null    -> hunk0
[4]  IEEEDPFix  -> hunk1+0x20c
[5]  IEEEDPFlt  -> hunk1+0x21e
[6]  IEEEDPCmp  -> hunk1+0x230
[7]  IEEEDPTst  -> hunk1+0x238
[8]  IEEEDPAbs  -> hunk1+0x240
[9]  IEEEDPNeg  -> hunk1+0x248
[10] IEEEDPAdd  -> hunk1+0x250
[11] IEEEDPSub  -> hunk1+0x258
[12] IEEEDPMul  -> hunk1+0x260
[13] IEEEDPDiv  -> hunk1+0x268
```

## Hunk 1 architecture

```
0x000  IEEEDPFix core (d0=ptr -> d0 int)
0x06c  IEEEDPFlt core (d0=ptr(out cell),d1=int)
0x0b6  IEEEDPAbs  body  (d0=dstptr, d1=srcptr)
0x0cc  stub neg   -> jsr _core ; .word 0xff0c
0x0e8  stub cmp   -> jsr _core ; .word 0xff0d ; d0 = -1/0/+1
0x10a  stub tst   -> jsr _core ; .word 0xff0e ; d0 = -1/0/+1
0x124  stub add   -> copy arg1 -> dst cell ; jsr _core ; .word 0xff08
0x140  stub sub             .word 0xff09
0x15c  stub mul             .word 0xff0a
0x178  stub div             .word 0xff0b
0x194  wrapper _w_una (cmp/tst): d0:d1,d2:d3 -> scr0,scr1 cells -> jsr helper
0x1b8  wrapper _w_unb (abs/neg): d0:d1 -> scr0 -> helper(dst=scr2)
0x1da  wrapper _w_bin (add/sub/mul/div): args -> scr0/scr1, dst=scr2
0x20c  vector stubs (lea helper, lea/jmp wrapper)
0x27c  _scr0 .long 0,0
0x284  _scr1 .long 0,0
0x28c  _scr2 .long 0,0
```

The three scratch cells live **inside the CODE hunk** and are written by
the wrappers on every call — self-modifying code in the shipped binary.

## Hunk 2 dispatcher protocol

Each stub does `jsr _core:l` followed by an inline `.word` selector.
`_core` pops the return address, reads the selector, indexes a PC-relative
word-offset jump table, and pushes the real return. Selectors:

```
ff08 add   ff09 sub   ff0a mul   ff0b div
ff0c neg   ff0d cmp   ff0e tst
```

Register convention inside the core: `a0` -> dest double (in/out),
`a1` -> src double; operands are loaded into d1:d2/d3:d4 and the result
stored back through `a0`. Exit tail at 0x488 pops
d0/d3/d5/a0 and returns.

Unused selector values index past the table to a dead tail at 0x48e that
sets `d1 = 224` and **runs off the end of the hunk** (no rts) — a
shipped defect preserved verbatim.
