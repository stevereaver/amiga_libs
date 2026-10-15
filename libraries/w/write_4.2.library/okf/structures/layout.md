# write.library 4.2 — structures

## Hunk layout

```
hunk0 CODE 0x868  — stub+RomTag+init+all code+strings
hunk1 CODE 0x40   — functab (9 longs) + "write.library" + "Version 1.0"
hunk2 DATA 0x54   — pad + InitTable + 60B runtime template
```

## RomTag (h0+4)

`4afc`, matchtag→h0+4, endskip→h0+0x1e, flags=0x80|0x06 (AUTOINIT|?),
ver=4, type=9 (NT_LIBRARY), pri=0, name→h1+0x24, idstr→h1+0x34,
init→h2+4.

## InitTable (hunk2+4)

```
+0  .long 0xb0          dataSize = 176
+4  .long ftab → h1+0   absolute-long table, 8 vecs
+8  .long 0             no datatab
+12 .long h0+0x20       init function
```

## Library data (lib+0x3c = globals a4)

Init copies hunk2 bytes 0..75 to lib+0x3c (76B via overlap loop).
Fields (a4-relative):
- a4@(52)  = template+0x34 = 0x18 — list head for _listwalk
- a4@(56)  = "con:10/10/320/80/" console spec string
- a4@(88)  = reply-port field set by -42
- a4@(92)  = flag byte (set by _listwalk tail)
- a4@(96)  = dosver arg to OldOpenLibrary
- a4@(100)/(104) = rexxsyslib base (dup)
- a4@(108)/(112) = dos base (dup)
- lib+0x2e = ptr to 8B table buf (template[0x4c]=1 → 1*4+4)
- lib+0x32 = opencnt (word)
- lib+0x24→+0x3b = std node fields filled by init

## Client ctx (Open allocates 224B)

ctx+0x3c becomes the per-client globals base (a2/a5@(60) region mirrors
lib layout); ctx+46 = cleared link word, ctx+32 = secondary opencnt,
ctx+40 = alloc'd string buf from -42's ArgArrayInit-style call.
