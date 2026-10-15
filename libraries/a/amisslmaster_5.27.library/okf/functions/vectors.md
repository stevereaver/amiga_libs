# amisslmaster.library 5.27 — vector table

`_mFuncTable` in the DATA hunk (hunk1): 10 absolute longs + `-1`.
Public args in registers (d0/d1/a0 as noted); a6 = lib base.

| LVO  | code+  | sym                  | behaviour |
|------|--------|----------------------|-----------|
|  -6  | 0xa0   | mLibOpen             | Forbid; opencnt++; clr flag bit3; Permit; ret lib |
| -12  | 0x120  | mLibClose            | Forbid; opencnt-- (or already-0 -> flag check); bit3 -> inner-expunge, else ret 0 |
| -18  | 0x16e  | mLibExpunge          | Forbid; inner-expunge; Permit; ret seg/0 |
| -24  | 0x192  | mLibNull             | ret 0 |
| -30  | 0x1b2  | InitAmiSSLMaster     | log("InitAmiSSLMaster apiVersion",d0,1); ret 1 |
| -36  | 0x1f8  | OpenAmiSSL           | if +42: log+ret it; else OpenLibrary("amissl.library",0)->+42; log; ret +42 |
| -42  | 0x254  | CloseAmiSSL          | if +42: CloseLibrary(+42) via exec; +42=0 |
| -48  | 0x274  | OpenAmiSSLCipher     | stub: ret 0 |
| -54  | 0x278  | CloseAmiSSLCipher    | bare rts |
| -60  | 0x324  | OpenAmiSSLTagList    | tag walk; see below |

inner-expunge worker (0xc4): if opencnt -> `orib #8,flags` ret 0;
else CloseLibrary(+42) if set, Remove(lib), FreeMem(lib-neg,
neg+pos), ret +38 seglist.  **Never closes DOSBase (+46).**

## OpenAmiSSLTagList(d0=apiVersion, a0=TagItem*)

1. log("OpenAmiSSLTagList apiVersion", apiv, 1)
2. if !+42: OpenLibrary("amissl.library",0) -> +42; log("  amisslBase",+42,1)
3. if !+42: ret 2
4. if a0: scan tags — TAG_DONE(0)/NULL -> goto initamissl;
   tag 3 -> continue list at `(TagItem*)(ti_Data + 8)` (literal +8!);
   tag 0x80000010 -> found.
   On found: ti_Data!=0 -> initamissl; ti_Data==0 -> second scan:
   walk again for tag 0x8000000d (same chain rule); on found:
   log("  Zweig: InitAmiSSL=FALSE, GetBasePtr",ti_Data,1);
   if ti_Data: *(APTR*)ti_Data = +42.  Either way
   log("OpenAmiSSLTagList -> 0 (OK)") + ret 0.  Not found -> same
   two logs (val 0) + ret 0.
5. initamissl: log("  Zweig: InitAmiSSL=TRUE -> rufe InitAmiSSLA");
   rc = amisslBase @LVO-36 (InitAmiSSLA, a0=tags a1=amisslBase);
   log("  InitAmiSSLA rc",rc,1); rc==0 -> log OK + ret 0;
   rc!=0 -> ret 3.   (**rc semantics: 0 = OK**)

## Debug logger (code+0x4c0)

`log(ctx, fmt, val, flag)` — ctx = lib+46 DOSBase (0 disables).
Builds `fmt[<=71] [" = " dec(val)] \n` in a ~72B stack frame, then
every line does: Open("RAM:awmaster.log",1004) else (…,1006);
Seek(fh,0,OFFSET_END); Write; Close.  itoa via 68020
`mulul 0xcccccccd` >>35 ÷10 trick; '-' prefix for negatives.
