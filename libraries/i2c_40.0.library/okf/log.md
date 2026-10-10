# Work log — i2c.library 40.0

1. Parsed hunk: single CODE hunk (0x156 lw), packed RomTag, AUTOINIT.
2. InitTable at +0x60: dataSize 0x89, functab +0x70 (14 LONG entries),
   datatab +0xac, initRoutine +0x170.
3. Decoded datatab byte-commands (a0=BYTE/80=LONG/90=WORD):
   ln_Type=9, ln_Name, IdString, ver=40, rev=0, flags=6, BYTE@0x42=3.
4. Identified error-string mechanism: 17-byte index table at +0xce
   feeding a packed pool at +0xdf; entries 6/7/12/14/16 share "???",
   entry 13 points inside "no temporary shutdown" ("temporary shutdown").
5. Resolved all external LVOs via NDK lvo/dos_lib.i + exec list.
6. Decoded the 9-clock byte shifter: sends w bits 7..0 then bit15
   (ACK release), receives SDA into bits 8..0; START=2,0 writes,
   STOP=2,3,3 writes to $de0080.
7. Mapped stats block: +34..+62 = sendops/sentB/recvops/recvB/
   busy/nack/partial/echo counters.
8. C reconstruction + m68k build: datatab & tables byte-identical,
   LibInit LVO sequence matches original (-552/-906/-816/-414/-558).
