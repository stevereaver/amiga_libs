---
type: Functions
title: rexxidentify 1.16 vector map
---

# Vector map (functab h0+0x110, 5 absolute longs -> h0)

-6  Open      h0+0x24e — opencnt++ @a6+0x20; bclr #0,a6+0x23
              (clears deferred-expunge flag); returns a6.
-12 Close     h0+0x25c — opencnt--; on 0 with flag bit set calls
              Expunge; returns 0.
-18 Expunge   h0+0x270 — busy: sets flag bit 0 @a5+0x23, ret 0.
              Else: exec Remove(-252), CloseLibrary(-414) on
              identify/commodities/expansion/rexxsyslib bases,
              exec FreeMem(-210); returns seglist (d2).
-24 Reserved  h0+0x2e6 — returns 0.
-30 Dispatch  h0+0x2ea — ARexx entry. a0 = RexxMsg; rm_Args[0]
              (msg+0x28) matched case-insensitively against the
              ID_ keyword list @h0+0x34a by helper h0+0xc56;
              index*4 through jump table @h0+0x31a.

## Jump table h0+0x31a (12 entries) vs keyword list h0+0x34a

ID_RELEASE   -> h0+0x3d0  version string 'h0+0x3ee'
ID_NUMBOARDS -> h0+0x402  itoa(count @h0+0xda2)
ID_EXPANSION -> h0+0x424  board query: MANUF/PROD/CLASS/ADDRESS/
                          SIZE/SHUTUP/CLASSID/MANUFID/PRODID
                          (kw list h0+0x594); SIZE in KB units
ID_HARDWARE  -> h0+0x6a4  system info kw list h0+0x758
                          (SYSTEM/CPU/FPU/MMU/OSVER/EXECVER/
                          WBVER/ROMSIZE/CHIPSET/...); identify
                          -36/-30 calls
ID_FUNCTION  -> h0+0x94e  identify -48 (IdFunction/IdAlertFmt)
ID_ALERT     -> h0+0x9b6  DEAD/SUBSYS/GENERAL/SPEC kw list
                          h0+0xa30; identify -42
ID_EXPNAME   -> h0+0x5d2  MANUF/PROD/CLASS kw list h0+0x692
ID_LOCKCX    -> h0+0xa4a  commodities -186; alloc 12B record in
                          BSS+0x80 array
ID_COUNTCX   -> h0+0xaa0  count links of record[index]
ID_GETCX     -> h0+0xafa  NAME/TITLE/DESC/ACTIVE kw list
                          h0+0xbdc over 12B records
ID_UNLOCKCX  -> h0+0xbfc  commodities -192; frees record
ID_UPDATE    -> h0+0xc48  identify -60

Convention: handlers return d0=0/a0=CreateArgstring result on
success; d0=12/a0=0 on error; dispatcher returns d0=1/a0=0 when
the command keyword is unknown.

## Helpers (h0)

0xc56 keyword matcher (ci, ' '/'=' terminators), 0xca2 itoa dec,
0xcdc itoa hex8 ('0123456789ABCDEF'@0xd00), 0xd10 atoi dec,
0xd54 atoi hex.

## External LVOs observed

rexxsyslib -126 (CreateArgstring); expansion -72 (FindConfigDev);
commodities -186/-192 (cx list lock/unlock); identify -30/-36/
-42/-48/-60; exec -552/-414/-252/-210.
