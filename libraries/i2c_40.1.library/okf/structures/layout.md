# i2c.library 40.1 — library base layout (dataSize = 0xc2 = 194)

| off  | field | notes |
|------|-------|-------|
| 0x00 | struct Library | OpenCnt +0x20 |
| 0x22 | stat_wrc       | write calls (long) |
| 0x26 | stat_wrb       | bytes written |
| 0x2a | stat_rdc       | read calls |
| 0x2e | stat_rdb       | bytes read |
| 0x32 | stat_nopres    | "no controller" events |
| 0x36 | stat_noreply   | address NAKs |
| 0x3a | stat_rej       | mid-transfer NAKs |
| 0x3e | stat_err       | timeout + arb-lost (shared counter) |
| 0x42 | flag42         | datatab-inited to 4; purpose unknown (vestigial node type byte?) |
| 0x43 | dexp           | bit 3 = private delayed-expunge flag (NOT lib_Flags!) |
| 0x44 | delay          | I2CDELAY long; prescaler index, clamped <=3 unsigned |
| 0x48 | SignalSemaphore| 46 bytes (0x2e) — ends exactly at 0x76 |
| 0x76 | sys            | ExecBase |
| 0x7a | cfgdev         | ConfigDev* (mfg 0x1389 prod 15) |
| 0x7e | seglist        | for expunge |
| 0x82 | clk[4]         | prescaler row (packed long); scratch for StrToLong(I2CXTAL) |
| 0x86 | present        | controller present (0xff = ST) |
| 0x87 | state          | last probe result 0..6 |
| 0x88 | sdown          | shutdown flag (0xff = ST) |
| 0x8c | timeout        | word; VBlank-decremented by I2CIntr; armed with 25 |
| 0x96 | intr           | Interrupt node: ln_Type=2, ln_Name=name, is_Data=base (runtime), is_Code=I2CIntr; added AddIntServer(5) = INTB_VERTB |
| 0xac | intr2          | second Interrupt node: type=2 pri=0x7d name=lib, is_Data/is_Code 0 — fully initialized, NEVER added (dead) |

## datatab

Standard exec entries (ln_Type=NT_LIBRARY, ln_Name, lib_IdString,
version 40, revision 1, lib_Flags=6) plus INITBYTE @0x42=4, the intr
node (type/name/is_Code) and the dead intr2 node (type/pri/name).

Note `SignalSemaphore` is 46 bytes in the NDK, not 34 — the original
layout assumes the full 46-byte struct and packs `sys` at 0x76.
