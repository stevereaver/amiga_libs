---
file: vectors
---
# Vectors (6 abs-longs @hunk+0x64, -1 term)

-6 Open +0xe8 | -12 Close +0x100 | -18 Expunge +0x130 |
-24 reserved +0x168 (rts 0) | -30 ParseTuple +0x5ce |
-36 FreeTuple +0x1210.

initfn +0xae: execBase->lib+0x26, segList->lib+0x22,
opens utility.library v36 -> lib+0x2a (fail -> cleanup
+0x172, ret 0). +0x172 = CloseLibrary(utility)+FreeMem.

-30 ParseTuple(tuple a0): d2=*a0; code<0x46 ->
CloneTagItems(table[code] @hunk+0x3a8) into a6; dispatch
(code-1)<=32 via word jumptab @hunk+0x624: 0x01 DEVICE
->+0x6b6, 0x15 VERS_1->+0x860, 0x17 ALTSTR->+0x6b6,
0x1a CONFIG->+0x8b6, 0x1b CFTABLE_ENTRY->+0x930,
0x20 MANFID->+0x1172, 0x21 FUNCID->+0x11c8 (args pushed
a2/lib,a6/clone,a3/tuple). Handlers NextTagItem-walk the
clone and fill ti_Data (AllocVec buffers, string arrays
via +0x12b8, +0x1394 strlen, +0x13b0 mul32, +0x13e8
div32). Returns cloned TagList* (0 if table[code]==0 or
code>=0x46).

-36 FreeTuple(tl a0): NextTagItem walk; tag in
arr@hunk+0x554 (09,0a,0b,14,15,16) -> recurse ti_Data;
in @0x570 (07,08,1c,1d,1e) -> FreeVec(ti_Data); in
@0x588 (22) -> FreeVec each ptr in array; then
FreeTagItems(root). a0==0 early-outs.
