---
file: layout
---
# mixer 1.11 layout

File 4016B. 1 hunk: h0 CODE 0x3d8 longs (3936B @file 0x20).
Tail: RELOC32 — 7 slots, all ->h0 (5 resident pointers +
2 InitStruct pointer fields).  END.  No DATA/BSS/symbol hunks.

## hunk0 map

| off | contents |
|-----|----------|
| 0x000 | `moveq #-1,d0 / rts` — unreferenced stub before RomTag |
| 0x004 | Resident 26B: matchtag->self, endskip=0xf5c, flags=0 (COLDSTART), ver=1, type=9, pri=0, name->+0x1e, id->+0x32, init->+0xd4 |
| 0x01e | `"mixer.library"` |
| 0x02c | `"$VER: mixer.library 1.11 (22 JUL 10) written by Pawel Stypula and copyright (c) 2001-2010 ELBOX COMPUTER, all rights reserved.\n"` |
| 0x0ac | InitStruct byte-command table (see below) + 7B pad |
| 0x0d4 | rt_Init: decryptor (see below) + zero pad to 0x163 |
| 0x164 | encrypted payload, 0xdfcB -> 0xf5f (the real library) |
| 0xf60 | 32B unscrambled tail (outside decrypt+checksum regions) |

Resident pointer fields all stored as hunk-relative offsets, patched
by RELOC32 @h0+6/0xa/0x12/0x16/0x1a/0xb6/0xc4.

## protection (plaintext region 0xd4-0x163)

rt_Init @0xd4 (`movem d1-d3/a0-a6,-(sp); movea.l 4.w,a6`):
1. `bsr 0x108` stage-1 decrypt: dest=h0+0x164, 0xdfcB/895 longs;
   `d1 = rol.l#4(enc[i] ^ key[i])`, key stream = h0+0xd4 onward —
   first 36 longs are the decryptor itself, afterwards it reads the
   already-decrypted plaintext (0x90B lag = feedback cipher).
   Then exec `CacheClearU` (-636), returns 1.
2. Checksum: adds 932 longs @h0+0xd0..0xf5f (covers InitStruct pad,
   decryptor, and all decrypted payload).  Sum==0 -> `bsr 0x182`
   (stage 2, inside payload); nonzero -> skip -> returns d0=0
   (load fails).  The 0xd0-0xd3 pad word is the checksum fixup.
3. stage 2 @0x182 saves incoming a0 (seglist) to a3, opens
   expansion.library v27, FindConfigDev(0, manuf 2206/0x89e,
   product): probes 32,31,40,48,49,60 then 33 then 63.
   - products 32/31/40/48/49/60 path: OpenLibrary("pci.library",2);
     polls `word[[pcilib+38]+2] & 0x3000 == 0x2000` (16 tries).
   - products 33/63 path: OpenLibrary("pci.library",5); tests
     `byte[[pcilib+38]] & 8`.
   - either fail -> `bsr 0xec0`: intuition EasyRequestArgs with the
     XOR-obfuscated (key 0xaaaaaaaa) text "Hardware ID code
     missing...\nContact support@elbox.com", gadget "Continue".
4. PCI scan @0x286 over 7-entry vendor:device table @0x344 via
   pci.library LVO -30 (d0=entry wordswapped, d1=device, d2=0):
   1274:5000 ES1370, 1274:1371 ES1371, 1274:5880 ES5880,
   1102:8938 (Creative), 1319:0801 FM801, 1102:0002 SB Live!,
   1102:0004 Audigy.  Index kept in d3 (0-6).
5. `[board+14]==0x12745000` (ES1370) picks functab B @0x3a6,
   else functab A @0x38e; both are exec word-offset tables
   (leading 0xffff marker), 10 vectors each.
6. `MakeLibrary(functab, itab@0xac, init=0, dsize=80, seg=0)`;
   fills lib fields, `jsr` per-index init hook (table @0x364),
   `AddLibrary`, CloseLibrary(expansion), returns lib base.
   lib fields written by init: +36=[board+28] codec regs (a4),
   +50=w device index, +52=board node, +56/+60=codec rd/wr fn
   (tables @0x372/@0x380), +64=exec, +68=pci base, +72=seglist.
   Hooks also set +34(chip id), +40/+42(codec regs 0x7c/0x7e),
   +44=state-table ptr 0x65a, +76 flag bits.

## InitStruct @0xac (exec iisscccc byte commands)

| bytes | effect |
|-------|--------|
| a0 08 09 | byte @8  = 9 (ln_Type NT_LIBRARY) |
| a0 09 00 | byte @9  = 0 (ln_Pri) |
| 80 0a +long | long @10 = ->+0x1e "mixer.library" (relocated @0xb6) |
| 90 14 0001 | word @20 = 1 (lib_Version) |
| 90 16 000b | word @22 = 11 (lib_Revision) |
| 80 18 +long | long @24 = ->+0x32 id string (relocated @0xc4) |
| 00 | end |

## payload map (decrypted view)

| off | contents |
|-----|----------|
| 0x164 | "expansion.library\0", 0x176 "pci.library\0" |
| 0x182 | stage-2 init (above) |
| 0x344 | 7 vendor:device longs + 0 terminator |
| 0x364/0x372/0x380 | 7-entry word-offset tables: init hook, codec-read fn, codec-write fn |
| 0x38e / 0x3a6 | functab A / B: `ffff` + 10 word offsets + `ffff` |
| 0x3be/0x3cc | Open (bclr DELEXP, private OpenCnt@+32++), Close |
| 0x3de/0x43c | -18/-24 ret-0 stubs; real expunge @0x3e2 (dead code) |
| 0x440-0x608 | per-chip init hooks (0x5ae/0x440/0x4f6/0x520 families) |
| 0x62a-0x659 | static channel-map byte tables (-30/-36 returns) |
| 0x65a-0x69d | 17-long mixer state/shadow table (updated in place) |
| 0x69e | -42 dispatcher: 17-entry jsr table @0x6d4 |
| 0x9e4 | -48 get: reads long from state table |
| 0x9fc/0xa04 | `jmp [a5+56]`/`jmp [a5+60]` codec rd/wr thunks |
| 0xa0c/0xa28 | -54/-60 framed calls to the thunks |
| 0xa48-0xe87 | codec rd/wr fn bodies (ES1370, serial-codec, FM801, Creative variants) — hw polled via a4=lib+36 with dbf/dbeq timeouts + Forbid/Permit |
| 0xe88 | 56B ^0xaaaaaaaa EasyRequest message text |
| 0xec0-0xf3f | fail path: builds requester, OpenLibrary intuition v27, EasyRequestArgs, CloseLibrary |
| 0xf40 | "intuition.library", 0xf52 "Continue" |
