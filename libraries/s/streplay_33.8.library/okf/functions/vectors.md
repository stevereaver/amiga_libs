# streplay 33.8 — vectors and LVOs

## Library vectors (functab @hunk+0x7e, 10 absolute longs, `-1` terminator)

| LVO  | name        | code offset | notes |
|------|-------------|-------------|-------|
| -6   | Open        | 0x104 | `opencnt++`, clears LIBF_DELEXP (bit 3 of ln_Flags @14), returns libbase |
| -12  | Close       | 0x112 | `opencnt--`; if 0 and DELEXP set → falls into Expunge; else returns 0 |
| -18  | Expunge     | 0x122 | if open → set DELEXP, return 0. Else: Stop + freebuf + Remove + FreeMem, returns seglist in d0 (via a5@(34)) |
| -24  | Null        | 0x166 | `moveq #0,d0; rts` |
| -30  | LoadModule  | 0x178 | a0=filename → d0: 0 ok / -1 dos.Open failed / -2 AllocMem failed. Stops+unloads current module first. File size via Seek(0,OFFSET_END) then Seek(0,OFFSET_BEGINNING); buffer in MEMF_CHIP |
| -36  | Unload      | 0x1fc | `bsr _stop; bra _freebuf` — Stop then FreeMem(lib+0x26, lib+0x2a) |
| -42  | ModulePtr   | 0x172 | d0 = lib+0x26 (module buffer, in chip RAM) |
| -48  | Play        | 0x202 | no-op unless buf!=0 && flag==0; sets flag 0x525a @lib+0x2e then `jmp _play2` (setup + AddIntServer) |
| -54  | Stop        | 0x21c | no-op unless playing; clears flag then `jmp _stop2` (RemIntServer + mute) |
| -60  | IsPlaying   | 0x16a | d0 = word @lib+0x2e sign-extended (0x525a → +0x525a) |

## Local routines (not vectored)

| offset | routine |
|--------|---------|
| 0xd6   | initfn: stores seglist @lib+0x22, zeroes buf@+0x26 and flag@+0x2e |
| 0xe6   | _freebuf: FreeMem(lib+0x26, lib+0x2a) if buf set; NULL branch shares Open's rts @0x110 |
| 0x240  | _play2: `_setup` + AddIntServer(5, &_intstruct) |
| 0x25c  | _stop2: RemIntServer(5, &_intstruct) + `_mute` |
| 0x2a6  | _setup: speed=6; scan 128 pos bytes for max pattern #; build 31-entry sample-offset table; AUDxVOL=0; clear patidx/patoff/patptr; songlen ← buf+950 (0x3b6) |
| 0x348  | _mute: AUDxVOL=0 ×4, DMACON=0x000f |
| 0x36a  | _handler: vertb server stub → _tickmain |
| 0x376  | _tickmain: tick++ vs speed (self-mod `cmpiw` imm); tick<speed → midtick effects; == → newrow |
| 0x3ec  | _effect dispatch: E0 filter toggle / E9 port-up / EA port-down / EC vol-slide / arpeggio (param nibble pair) |
| 0x514  | _newrow: advance row, decode 16-byte packed note rows ×4 ch; pattern wrap → next position; effects EB pos-jump, ED patbreak, EE filter, EF speed, EFxx>0x20 ignored |
| 0x664  | _note: period lookup via 36-entry table → AUDxPER; sample index → AUDxLC/LEN/VOL via samtab |

## Exec calls

| LVO  | name | site |
|------|------|------|
| -210 | FreeMem | _freebuf, _expunge |
| -252 | Remove  | _expunge |
| -168 | AddIntServer | _play2 |
| -174 | RemIntServer | _stop2 |
| -552 | OldOpenLibrary | _loadmod (dos.library) |
| -198 | AllocMem | _loadmod (MEMF_CHIP) |

## dos.library calls (a6 = DOSBase)

| LVO | name | site |
|-----|------|------|
| -30 | Open (MODE_OLDFILE=1005) | _loadmod |
| -66 | Seek | _loadmod (end → size, then start) |
| -36 | Close | _loadmod |
| -42 | Read | _loadmod |

## Hardware registers touched

`0xdff096` DMACON, `0xdff0a0/0b0/0c0/0d0` AUDx bases (+4 LEN, +6 PER, +8 VOL, +0 LOC), `0xbfe001` CIA-A pra (audio filter bit 1).
