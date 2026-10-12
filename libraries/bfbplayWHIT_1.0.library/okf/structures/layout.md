# bfbplayWHIT.library -- structures

## Library base (dataSize 0xb2 = 178)

    +0..33   struct Library (via datatab: ln_Type 9, ln_Name,
             flags 6, ver 1, rev 0, IdString)
    +34      flag byte, bit3 = delayed expunge
    +36      ExecBase*        (set by LibInit from a6)
    +40      dos.library base (OpenLibrary, any version)
    +44      seglist          (a0 at init)
    +46..157 unused
    +158     UWORD CIA period = 0x3781 (written by cia_start)
    +160     ciaa.resource base   (lazy)
    +164     ciab.resource base   (lazy; name patched 'a'->'b')
    +168     CIA chip base in use (0xbfe001 or 0xbfd000)
    +172     resource base in use
    +176     UBYTE timer (0 = timer A, 1 = timer B)

## Session block (80 bytes, AllocMem MEMF_CLEAR; or caller-supplied
## via tag 0x80000007 ti_Data)

    +0   UBYTE type = 8
    +1   UBYTE running   (module code active)
    +2   APTR  modbuf    (UNALIGNED offset)
    +6   APTR  (unused)
    +10  ULONG modlen    (unaligned)
    +14  ULONG (unused)
    +18  pad
    +20  UWORD detector result (subsong count base)
    +22  pad
    +24  UWORD cursong (0-based)
    +26  ULONG = 0x00000074 (116) -- constant, probably a Whittaker
         tempo/format word (replaces GMOD's "GMOD" fmtname ptr)
    +30..45 unused
    +46  UBYTE stopped   (set by StopModule; gates ContModule)
    +47..55 pad
    +56  ULONG playing   (CIA timer allocated & ticking)
    +60..79 pad

## Interrupt chain (inside code hunk)

    node1 @ code+0x754  struct Interrupt, "BFBPlay CIA timer."
      is_Data -> node2, is_Code -> jsr a6@(-180) = Cause(node2)
    node2 @ code+0x772  struct Interrupt, name NULL
      is_Data = 0x00bfe001 (CIAA_PRA, unused by the code)
      is_Code -> code+0x208 forwarder:
        if cur_sess && cur_sess+1(running): jsr (cur_sess+2)+14

## Code-hunk global

    code+0x204  cur_sess -- set by InitModule, never cleared
    (dangling after EndModule)
