# f1gp 35.4 — vectors and LVOs

## Library vector table (long-absolute, `-1` terminated, at code+0x1b4)

| LVO | offset | code off | name            | behaviour |
|-----|--------|----------|-----------------|-----------|
| -6  | Open     | 0x24e | Open       | `opencnt++`, clears LIBF_DELEXP, returns libbase |
| -12 | Close    | 0xc8  | Close      | `opencnt--`; if 0 && DELEXP -> Expunge path |
| -18 | Expunge  | 0xce  | Expunge    | opencnt>0 -> sets DELEXP, returns 0; else Remove+FreeMem lib node (62B) + RemHead patch list, returns seglist |
| -24 | null     | 0xd6  | —          | `moveq #0,d0; rts` (reserved vector) |
| -30 | FindPatch| 0x684 | FindPatch  | walks TaskReady/TaskWait lists under Disable, locates F1GP task by seglist hunk-size signature, installs hooks, returns 0 |
| -36 | AllocNode| 0x344 | AllocNode  | AllocMem 16B (PUBLIC), stores task ptr (a0) & signal mask (d0) in node, AddTail to patch list under ObtainSemaphore; returns node |
| -42 | FreeNode | 0x39a | FreeNode   | Signals task (Signal(node->task, node->sigs)), removes node under semaphore, FreeMem 16B |
| -48 | Checksum | 0x100 | Checksum   | byte checksum: `d3 += byte`, `d2 = ROL.3(d2) + byte` each byte; result `(d3<<16)|d2` |

## Exec LVO call sites (SysBase in a6/@4)

| LVO  | function          | used in |
|------|-------------------|---------|
| -30  | Supervisor        | `_Install` — reads VBR for hook install |
| -84  | MakeLibrary       | `rt_Init` |
| -120 | Disable           | `_Install`, `FindPatch` |
| -126 | Enable            | `_Install`, `FindPatch` |
| -132 | Forbid            | patch install/exit paths |
| -138 | Permit            | patch install/exit paths |
| -198 | AllocMem          | init (62B lib node), AllocNode (16B), patch workspace |
| -210 | FreeMem           | Expunge, FreeNode |
| -246 | AddTail           | AllocNode |
| -252 | Remove            | Expunge, FreeNode |
| -258 | RemHead           | Expunge (drains patch list) |
| -300 | SetTaskPri        | init tail |
| -324 | Signal            | FreeNode, `_UnsigAll` |
| -396 | AddLibrary        | `rt_Init` |
| -558 | InitSemaphore     | init (data-hunk semaphore @+0x78) |
| -564 | ObtainSemaphore   | AllocNode/FreeNode |
| -570 | ReleaseSemaphore  | AllocNode/FreeNode |
| -624 | CopyMem           | `_Install` (copies hook code into task mem) |
| -636 | CacheClearU       | `_Install`, after code self-modification (v>=37 only) |

## Internal routines

| off  | name         | role |
|------|--------------|------|
| 0x6a | `rt_Init`    | RomTag entry — clears 96B workspace @a4-96, builds lib via MakeLibrary, protection predicates, AddLibrary, post-init |
| 0x26e| `_Install`   | installs JSR hooks into the F1GP task's code hunk; CopyMem + CacheClearU |
| 0x684| `FindPatch`  | task-list walk (see vectors) |
| 0x844| `MulDiv`     | partial-product multiply/divide helper |
| 0x868| `NextNode`   | list next/first-node helper |
| 0x878| `Patch1`     | protection predicate — stub `rts` (always pass) |
| 0x880| `Patch2`     | protection predicate — stub `rts` (always pass) |
| 0x890| `InitList`   | MinList header init (`lh_Head=a0+4`,`lh_Tail=0`,`lh_TailPred=a0`) |
