# dsp3210.library 2.1 (4.3.2021)

**Status:** reconstructed — `source/dsp3210_lib.s` (verbatim lifecycle + -36
reloc engine + helpers), `source/dsp3210.c` (-30/-42/-48).

**Summary:** manual-init (non-AUTOINIT) library implementing an AT&T
DSP3210 **big-endian COFF object loader/relocator**. Validates a COFF
image, copies sections into a flat destination buffer applying
relocations, and provides a file-loading front end that wraps the
loaded image in a tagged descriptor (`0x32102011` magic + size) and
flushes the CPU data cache for DSP DMA access.

## Layout (code hunk, orig offsets)

| Off    | Contents |
|--------|----------|
| 0x00   | `moveq #0,d0; rts` stub before RomTag |
| 0x04   | RomTag: flags=0 (non-AUTOINIT), ver 2, NT_LIBRARY, pri 0 |
| 0x1e   | `"dsp3210.library"` |
| 0x2e   | `"$VER: "` + idstr (`rt_IdString` points *inside* at 0x34) |
| 0x56   | `"dos.library"` |
| 0x64   | rt_Init code: `MakeLibrary(functab,NULL,libInit,46,seglist)` + `AddLibrary`; ret 1/0 |
| 0x90   | libInit: fills ln_Type/Name/Version(2)/Revision(1)/IdString/OpenCnt, seglist@+34 |
| 0xca   | -6 LibOpen |
| 0xda   | -12 LibClose |
| 0xf4   | -18 LibExpunge (closes dosbase via helper @0x5f2) |
| 0x136  | -24 return-0 stub |
| 0x13a  | functab: 8 absolute longs + 0xffffffff |
| 0x15e  | -30 dsp_objsize |
| 0x1d8  | rdlong helper (BE long read, a2 preserved) |
| 0x1ec  | rdword helper (BE word read, a2 preserved) |
| 0x1fa  | -36 dsp_loadimg (COFF loader + reloc engine) |
| 0x46a  | -42 dsp_loadfile |
| 0x5ac  | -48 dsp_unload |
| 0x5d4  | lazy dos.library open helper (base+42) |
| 0x5f2  | dosbase close helper (expunge) |

## Dependencies

- **exec**: MakeLibrary(-84), AddLibrary(-396), AllocMem(-198),
  FreeMem(-210), Remove(-252), OpenLibrary(-552), CloseLibrary(-414),
  CachePostDMA(-642)
- **dos** (lazy-opened v36 into base+42): Open(-30), Close(-36),
  Read(-42), Lock(-84), UnLock(-90), Examine(-102)

## Verification

- Verbatim block 0x1fa-0x469 (loader + cmpstr + helpers): **byte-identical**
- Lifecycle/init/open/close/expunge: byte-identical modulo relocs
- Functab resolves to correct targets in both builds
- dsp_loadfile syscall sequence verified insn-by-insn (dosbase→a6 per call)
