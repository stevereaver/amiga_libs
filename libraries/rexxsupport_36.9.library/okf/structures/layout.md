# rexxsupport.library 36.9 — structures

## Private library data (InitTable dataSize = 0x2e = 46)

Built on a standard `struct Library` (34 bytes).  posSize = 80
(34 + 46):

| off | field | contents |
|-----|-------|----------|
| +24 | IdString | set **by initfn code** (`lea _idstr; movel a0,24(a5)`) — 34.9 set it via a `8018` datatab record |
| +34 | SysBase | exec.library base (a6 at init) |
| +38 | RexxSysBase | `OpenLibrary("rexxsyslib.library",0)` — any version; `a6` in the dispatcher body, `a4` inside handlers |
| +42 | SegList | seglist (a0 at init); returned by Expunge |

Registers in handlers (unchanged from 34.9): `a4`=RexxSysBase,
`d4`=ExecBase (from `a4+36`), `d5`=scratch index, `a5`=request
block, `a2`=task block, `a3`=result buffer, `a6`=call target
(exec/dos/rxs base swapped in via `exg`).

Registers in the dispatcher body (**changed**): `a6`=RexxSysBase,
`a4`=libbase, `a3`=data ptr of a 400-byte scratch argstring
allocated per dispatch by rxs-126 and freed by rxs-132 on exit
(pointer kept in a pushed long on the stack).

rexxsyslib private fields used: `+36` ExecBase, `+40` DOSBase,
`+64/68/72` rl_NULL/rl_FALSE/rl_TRUE stored as *header*
addresses (callers `addqw #8` to reach data).

## Request block (a5, the ARexx message)

| off | contents |
|-----|----------|
| +20 | task block T |
| +31 | argcount excluding the command name (byte → d7) |
| +40 | command-name argstring |
| +44 | arg0 argstring (4-byte tokens carry pointers) |
| +48 | arg1 argstring |
| +52 | arg2 argstring |
| +56 | arg3 argstring |

## Task block (T = *(a5+20))

| off | contents |
|-----|----------|
| +136 | unused in 36.9 (34.9 stored the *result buffer pointer* here; the 400-byte per-dispatch scratch argstring replaced it) |
| +235 | caller signal bit (WAITPKT) |
| +316 | private port-node list head (type-2 nodes) |

## Argstring

data pointer returned by mkarg; header lives at `ptr-8`:

`[+0 size.l][+4 length.w][+6 0x46][+7 checksum.b][+8 data..]`

The dispatcher's 400-byte scratch buffer is itself an argstring
(`CreateArgstring(0,400)`): handlers write into its data area
and raw results are re-copied into a *second* argstring sized
to `d3` before the scratch is freed.

## RexxMsg packet (GETARG/TYPEPKT/REPLY/FORWARD tokens)

| off | field | contents |
|-----|-------|----------|
| +28 | action long | high byte = class (1 or 2 valid for GETARG); byte +29 bit1 = "reply wants resultstring"; low byte = argcount |
| +32 | Result1 | set by REPLY (rc arg) |
| +36 | Result2 | resultstring argstring set by REPLY when rc==0 & flag |
| +40 | Args[] | array of argstring pointers (GETARG index) |

## Port node (internal, type 2; allocated by rxs-198)

| off | field | contents |
|-----|-------|----------|
| +0  | succ | chain link in T+316 list |
| +8  | type | 2 |
| +10 | name | argstring ptr |
| +32 | MsgPort | embedded 1.x-style port; SigBit @ +47 (node+47), msg list head @ +52 |
| +66 | pending | MinList of dequeued packets: head@+70, tail@+72, tailpred@+74 |

GETPKT trick: after AddTail, `node+74` (lh_TailPred) equals the
just-added message — the raw-4 result reads `node+74` directly
(or `node+70`=0 when empty) instead of keeping a pointer.

## Command table record

`[cksum.b][name.4-9][max<<4|min.b][argflags.b]` — sections per
name length overlap (trailing bytes of a shorter record double
as the leading bytes of the next-longer one). `argflags` bit i
requests dispatcher conversion of arg i through rxs-474 into
`d3` (failure → err18).  Byte-identical to 34.9.

## Result conventions

`d0` = error code: 0 ok, 1 unknown name, 3 result-allocation
failure, 17 arg count, 18 conversion/handle/class error.
`a0` = result argstring.  Handlers flag the packaging mode in
`d7`: bit31 raw(a3,d3len), bit16 numeric(d3), bit17 bool(d3),
bit18 empty; no bits → `a0` already holds the argstring.
