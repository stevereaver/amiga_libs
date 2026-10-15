# prometheus.library 2.5 — layouts

## Hunk map (file offsets)

```
0x000  HUNK_HEADER  (0x3f3, 2 hunks, first=0 last=1, sizes [0x266, 0x13])
0x024  HUNK_CODE hdr (0x3e9, 0x266)  -> body 0x024..0x9BB  (2456 B)
0x9BC  RELOC32 (0x3ec): group1 h0: [06,0a,12,16,1a,4fc,516]
                        group2 h1: [4dc]   (terminator)
0x9F4  HUNK_END (0x3f2)
0x9F8  HUNK_DATA hdr (0x3ea, 0x13)   -> body 0xA00..0xA4B  (76 B)
0xA4C  RELOC32 (0x3ec): group h0: [00..44 step 4] (18 offs)
0xAA0  HUNK_END (0x3f2)             -> EOF 0xAA8
```

hunk0 body:

| off | contents |
|-----|----------|
| 0x000 | DOS stub `70ff 4e75` |
| 0x004 | RomTag (26 bytes): 4afc / MatchTag->0x04 / EndSkip->0x1e / 00 02 09 00 / name->0x20 / id->0x34 / init->0x4ce |
| 0x01e | `0000` (EndSkip target / pad) |
| 0x020 | "prometheus.library\0" + pad |
| 0x034 | "$VER: prometheus.library 2.5 (22.07.2003) (c) 2000-2003 by Matay.\n" + pads |
| 0x078 | SizeToPri |
| 0x092 | nop pad |
| 0x094 | AddRequest |
| 0x0ee | QueryCard |
| 0x346 | WriteAddresses |
| 0x3fe | ScanBoard |
| 0x4ac | "utility.library\0" |
| 0x4bc | "expansion.library\0" |
| 0x4ce | rt_Init |
| 0x5c6 | Open |
| 0x5d8 | Close |
| 0x5fe | Expunge |
| 0x66e | reserved `clr.l d0; rts` |
| 0x672 | nop pad |
| 0x674 | FindBoardTagList |
| 0x6e2 | GetBoardAttrsTagList |
| 0x748 | ReadConfigLong |
| 0x76e | ReadConfigWord |
| 0x79a | ReadConfigByte |
| 0x7c6 | WriteConfigLong |
| 0x7e6 | WriteConfigWord |
| 0x806 | WriteConfigByte |
| 0x826 | settable tags `{0x6eda0005,0}` |
| 0x82e | SetBoardAttrsTagList |
| 0x8ac | AddIntServer |
| 0x8ca | RemIntServer |
| 0x8e6 | "Prometheus.card\0" |
| 0x8f6 | AllocDMABuffer |
| 0x930 | FreeDMABuffer |
| 0x96a | GetPhysicalAddress (ends 0x998) |

hunk1 body: 18 x `.long` vectors to hunk0 + `0xffffffff` terminator.

## prometheus.library base (dsize 0x54)

std `struct Library` 0x00..0x21, then:

| off | field | notes |
|-----|-------|-------|
| +34  | pb_SysBase      | exec base |
| +38  | pb_UtilityBase  | utility.library v36 |
| +42  | pb_CardBase     | Prometheus.card v7, lazy |
| +46  | pb_SegList      | as passed in a0 |
| +50  | pb_Pool         | CreatePool(MEMF_CLEAR, 752, 752) |
| +54  | pb_BoardAddr    | last cdev's cd_BoardAddr |
| +58  | pb_Cards        | MinList of PCIBoard (AddTailMin) |
| +70  | pb_Requests     | List of SpaceReq, ln_Type=0xFE, Enqueue by pri |

## PCIBoard (188 bytes, AllocPooled)

| off | field |
|-----|-------|
| +0  | MinNode (succ/pred) |
| +8  | pn_ConfigBase — pointer into PCI cfg space `boardaddr+0xF0000+slot*0x2000+func*0x100` |
| +12 | pn_TagList — inline TagItem array (up to 22 entries, zero-terminated by pool MEMF_CLEAR, no TAG_DONE) |

Tag IDs written by QueryCard: `0x6eda0000` Vendor, `..01` Device,
`..02` Revision, `..03` Class(base class code cfg+11), `..04` SubClass
(cfg+10), `0x6eda0010+i` MemoryAddr i (i=0..4), `0x6eda0020+i`
MemorySize i, `0x6eda0016` ROM_Address, `0x6eda0026` ROM_Size,
`0x6eda0005` BoardOwner, `0x6eda0006` SlotNumber, `0x6eda0007`
FunctionNumber. (Sizes precede their Addr tags in the array.)

## SpaceReq (30 bytes, AllocPooled)

| off | field |
|-----|-------|
| +0  | Node ln_Succ/ln_Pred |
| +8  | ln_Type = 0xFE |
| +9  | ln_Pri  = SizeToPri(size) |
| +10 | ln_Name = 0 |
| +14 | sr_Size |
| +18 | sr_Type (0=MEM, 1=IO) |
| +22 | sr_Tag  — &board->pn_TagList[k] to receive the address |
| +26 | sr_CfgAddr — &cfg->BAR[k] to program |

## ConfigDev fields used (expansion.library)

`+14` cd_Flags (bit1 cleared when claimed), `+32` cd_BoardAddr,
`+36` cd_BoardSize, `+44` cd_Driver <- libbase.
FindConfigDev(a0=prev, d0=manuf 0xAD47, d1=prod 1).

## Stack frame convention

All routines use `sub/lea sp` for locals FIRST, then `moveml regs,-(sp)`:
locals live *above* the register save block (between it and the return
address); stack args at `sp@(framesize+4+off)`.
