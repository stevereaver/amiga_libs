# xpkBLZW 3.4 — Vector Map

AUTOINIT, word-offset function table at file offset 0x8e (marker
`ffff`, 10 entries, terminator `ffff`). Offsets relative to the
functab; original values shown.

| LVO | Orig off | Target | Function |
|-----|----------|--------|----------|
| -6  | 0x0020   | 0xae   | LibOpen — `++OpenCnt; flags &= ~8; return base` |
| -12 | 0x002e   | 0xbc   | LibClose — `--OpenCnt; if 0 && DELEXP → bra expunge` |
| -18 | 0x0040   | 0xce   | LibExpunge — OpenCnt? set DELEXP : remove+free, ret seglist |
| -24 | 0xff72   | 0x00   | → hunk+0 `moveq #0,d0; rts` (EndSkip stub) |
| -30 | 0x007e   | 0x10c  | XpksPackerInfo — `lea info(pc),a0; return a0` |
| -36 | 0x00d8   | 0x166  | XpksPackChunk — LZW packer |
| -42 | 0x0086   | 0x114  | XpksPackFree — `FreeMem(param+52, param+56)` if set |
| -48 | 0xff72   | 0x00   | → hunk+0 stub (no reset needed: hash rebuilt per chunk) |
| -54 | 0x0334   | 0x3c2  | XpksUnpackChunk — LZW decoder |
| -60 | 0x0086   | 0x114  | → XpksPackFree (shared: frees cached work buffer) |

## RomTag / init

```
0x00  moveq #0,d0; rts            (EndSkip target / run stub)
0x04  4afc  MatchTag->0x04  EndSkip=0 (literal!)
      flags 0x80 (COLDSTART) ver 3 type 9 pri 0
      name->0x1e "xpkBLZW.library"
      idstr->0x2e "$VER: xpkBLZW V3.4 (1 Oct 2013) by Bryan Ford\r\n"
      init->0x5e {0x26, functab->0x8e, datatab->0x6e, initfn->0xa6}
```

InitTable dataSize = 0x26 (Library + seglist@34). datatab inits
ln_Type=9, ln_Name, lib_Flags=6, version=3, revision=4, IdString.
LibInit stores seglist at base+34, returns base.

## Work-buffer helper (0x132)

Shared by packer and decoder:

```
d1 = param+52 (cached buf); if !d1 -> alloc
if (need < param+56):  a2 = d1; d0 = 1; return   ; reuse (strict <)
else:  PackFree(param)
alloc: param+56 = need; a2 = AllocMem(need, 0); param+52 = a2
       return a2 (0 on failure -> caller returns -7)
```

The cached buffer persists across PackChunk/UnpackChunk calls and is
released by XpksPackFree (-42/-60).

## XpksPackFree (0x114)

```
if (param+52): param+52 = 0; FreeMem(ptr, param+56); return
```
