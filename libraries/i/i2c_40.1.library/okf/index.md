# i2c.library 40.1 — "di2c.library" (PFC8584 I2C bus driver)

- **Binary**: `binary/i2c_40.1.library`, 1812 bytes, single code hunk
- **Id string**: `i2c.library 40.1 (18 Jul 99) for PFC8584 bus controller`
- **Reconstruction**: `source/` — C (`i2c.c`) + AUTOINIT/lib skeleton asm
  (`i2c_lib.s`); builds `i2c.library` (m68k-amigaos-gcc, `-m68000 -O2`)
- **Status**: complete. Data region (hunk+0x00-0x19c: RomTag, strings,
  init table, functab, datatab, error table, error strings, config
  strings) is byte-identical to the original modulo relocated pointers.
  All 14 vectors resolved; codegen reviewed instruction-by-instruction
  against the IRA dump; the VBlank handler is byte-identical.

## Layout

```
code+0x000  _start: moveq #10,d0 / rts      (nonzero stub return)
code+0x004  RomTag: 0x4afc AUTOINIT v40, rt_EndSkip -> _libname (0x1e)
code+0x01e  "i2c.library"
code+0x02a  idstring + CRLF
code+0x064  init table: dataSize 0xc2 / functab / datatab / LibInit
code+0x074  functab: 14 x DC.L absolute pointers + ffffffff
code+0x0b0  datatab: exec base fields + user fields + 2 intr nodes
code+0x0f0  errtab: 17 byte offsets (see findings/defects.md!)
code+0x101  "OK" + packed error strings (to 0x19b)
code+0x19c  LibInit + the rest of the code
code+0x684  I2CIntr: VBlank timeout decrementer (byte-identical)
```

## Hardware

PFC8584 I2C controller on a Zorro board found via
`expansion.library/FindConfigDev(mfg 0x1389, prod 15)`.  Register file
at `ConfigDev->cd_BoardAddr`: data register at +0, control/status at +2.
Polled (BB/AL/LRB bits), VBlank-driven timeout (25 ticks ~ 0.5 s),
semaphore-protected.

## Config

`ENV:I2CDELAY` -> base+0x44 (delay/prescaler index, clamps to 0..3),
`ENV:I2CXTAL` -> clock prescaler row (3/4/6/8 MHz; else 20 MHz row).

See `functions/vectors.md`, `structures/layout.md`,
`algorithms/i2c_proto.md`, `findings/defects.md`.
