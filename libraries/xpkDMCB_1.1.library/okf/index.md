# xpkDMCB.library 1.1

**sha256** `20b8049b56fe28b34758354c17b00d55d4a7e695d4e5a5a6ca43304f91bba756` — 1,456 bytes, single CODE hunk

## Purpose
XPK sublibrary implementing **DMC — Dynamic Markov Compression** (Cormack–Horspool): a binary arithmetic coder over a state-cloning Markov model, computed in 68881 extended precision. `LibInit` refuses to load without a 68020 **and** a 68881 (checks `AttnFlags` AFB_68020 + AFB_68881).

## API (word-offset functab, 10 vectors)
| off | fn |
|-----|----|
| -6/-12/-18 | LibOpen / LibClose / LibExpunge |
| -24/-42/-48/-60 | null `moveq #0,d0/rts` |
| -30 | `XpksPackerInfo` → static XpkInfo descriptor |
| -36 | `XpksPackChunk` — DMC encoder |
| -54 | `XpksUnpackChunk` — DMC decoder |

## Layout
- RomTag: AUTOINIT, ver 1, NT_LIBRARY
- datatab: ver 1, rev 0, idstring `xpkDMCB v1.1`
- dataSize 0x2a: base + seglist@34 + DELEXP flag byte @38
- workmem: AllocMem(0x200000, MEMF_PUBLIC|MEMF_CLEAR)

## Descriptor
XpkInfo: ver 1/1/2/0, name "DMCB", longname "Dynamic Markov Compression v1.1", desc "Arithmetic coding using dynamic Markovmodelling", id `DMCB`, flags 9, chunk limits 100..0x28000 (def 0x28000), msgs Compressing/Expanding/Compressed/Expanded, DefMode 100.
XpkMode: upto 100, flags 1, pack/unpack memory **0x800** (KB units → 2 MB), speeds 7/7, ratio 0x1bd=445, desc "normal".

## Source
`source/xpkDMCB.c`, `xpkDMCB_lib.s`, `genfunctab.py`, `Makefile`. The C codec compiles with `-m68020 -m68881` so `long double` maps onto the fp registers exactly as the original.`
