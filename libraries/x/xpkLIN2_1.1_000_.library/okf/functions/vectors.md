# Vectors / library interface

Ten-vector **word-offset** functab (`0xffff` marker … `0xffff`
terminator), identical layout to xpkDUKE/xpkNUKE 1.8.  Entries are
signed words relative to the functab base (hunk+0x94); the two null
entries are `-0x94` (`ff6c`), resolving to the entry stub at code+0
(`moveq #0,d0; rts`).

| off  | name             | code+ | behavior |
|------|------------------|-------|----------|
| -6   | Open             | 0x0b4 | `lib_OpenCnt++`, `bclr #3,lib_Flags` (clears LIBF_DELEXP), returns libbase |
| -12  | Close            | 0x0c2 | `--lib_OpenCnt`; nonzero -> `bra.w code+0` (ret 0 via stub); zero && DELEXP clear -> ret 0; zero && DELEXP -> falls into Expunge |
| -18  | Expunge          | 0x0d4 | if opencnt!=0 -> `bset #3,lib_Flags`, ret 0 via stub; else shared body at 0x0e4: `Remove`(LVO -252) + `FreeMem(base-NegSize, NegSize+PosSize=132)`(LVO -210), returns seglist |
| -24  | null (ExtFunc)   | 0x000 | entry stub |
| -30  | XpksPackerInfo   | 0x132 | `lea code+0xaa0(pc),a0; move.l a0,d0; rts` — returns &XpkInfo |
| -36  | XpksPackChunk    | 0x13a | encoder, see algorithms/codec.md |
| -42  | XpksPackFree     | 0x112 | shared `XpkSubFree`: `if (xsp_Sub[0]) FreeMem(xsp_Sub[0], xsp_Sub[1]=+0x38)` then `clr.l xsp+0x34` — **does** clear the pointer (unlike DUKE/NUKE 1.8); if already NULL just `rts` with stale d0 |
| -48  | null             | 0x000 | XpksPackReset is a no-op — the head table is re-cleared inline on every PackChunk |
| -54  | XpksUnpackChunk  | 0x75c | decoder |
| -60  | XpksUnpackFree   | 0x112 | same shared `XpkSubFree` (the unpacker's 0x20-byte state block is also freed via +0x34/+0x38) |

## Init

- RomTag at code+4: `RTF_AUTOINIT`(0x80), ver 1, `NT_LIBRARY`(9),
  pri 0.  **`rt_EndSkip = 0`** (sic — same 1.8-generation quirk).
- InitTable at code+0x64: dataSize **0x26**, functab@0x94,
  datatab@0x74, LibInit@0xac.
- LibInit (0xac): `a1=d0` (libbase); `a1@(0x22) = a0` (seglist);
  returns libbase.  No dependencies, no CPU gate.
- datatab: ln_Type=9, ln_Name, lib_Flags=6 (LIBF_CHANGED|LIBF_SUMUSED),
  version=1, revision=1, idstring.
- NegSize=60 (10 vectors), PosSize=34+38=72; FreeMem total 132.

## Lifecycle trace (oracle, identical orig/rebuild)

```
open -> libbase, opencnt 1 -> 2
expunge(open) -> 0, flags 0e (LIBF_DELEXP set)
close -> 0, opencnt 1
close -> seglist, opencnt 0 -> deferred expunge:
  Remove(lib); FreeMem(libbase-60, 132)
```

## Return codes (XpksPackChunk / XpksUnpackChunk)

| d0 | meaning |
|----|---------|
| 0     | success (pack writes xsp_OutLen; unpack produced bytes must equal preset xsp_OutLen) |
| -7    | AllocMem failed for the pack workspace |
| -14   | unpack: produced != preset xsp_OutLen |
| -17   | pack: out-of-output (`OutBuf+InLen` bound hit mid-stream) or `xsp_OutLen >= xsp_InLen` (did not shrink) |
| -32   | unpack: stream[0:4] != 0 and != pwhash(xsp_Password) — wrong/missing password |
