# screennotify.library 1.0 — structures

## Library node (dsize = 0x19a = 410 = 44 + 3*122)

| off | field                                                        |
|-----|--------------------------------------------------------------|
| +36 | seglist                                                      |
| +40 | intuition.library base (lazy-opened at first Open)           |
| +44 | notify object 0 — screen-close list (class-0, 18 B nodes)    |
| +166| notify object 1 — PubScreenStatus list (class-1, 14 B nodes) |
| +288| notify object 2 — WorkBench list (class-2, 14 B nodes)       |

## Notify object (122 bytes, stride 0x7a)

| off  | field                                                        |
|------|--------------------------------------------------------------|
| +0   | MinList of subscriber nodes (NewList'd)                      |
| +14  | SignalSemaphore (46 B, InitSemaphore'd) guarding the list    |
| +60  | embedded Message (28 B): mn_ReplyPort=obj+74→&obj+88, mn_Length=28 (obj+78); payload +20=type, +24=arg |
| +88  | embedded MsgPort (34 B): ln_Type=NT_MSGPORT(4)@+96, mp_Flags=PA_SIGNAL(0)@+102, mp_MsgList NewList'd @+108; mp_SigBit/mp_SigTask filled per-broadcast |

## Subscriber node

- class-0 (screen close): 18 B — MinNode(14) + `screen`@+14
- class-1/2: 14 B — plain MinNode; ln_Name=client MsgPort,
  ln_Pri=priority byte

## Client-visible message

```
struct Message mn;   /* 14+4+2 = ReplyPort/Length prelinked */
ULONG  +20 type;     /* 0 close-screen / 1 pub-changed / 2 pub-changing / 3 workbench */
ULONG  +24 arg;      /* Screen* (type 0), PubScreenNode* (types 1/2), 0/1 (type 3) */
```

## DATA hunk globals (hunk 1, 24 B alloc / 8 B on disk)

a4 = _DATA+0x7ffe:

| a4 disp    | data off | field                              |
|------------|----------|-------------------------------------|
| -32766     | +0       | SysBase                             |
| -32762     | +4       | library base                        |
| -32758     | +8       | old intuition -66  (CloseScreen)    |
| -32754     | +12      | old intuition -78  (CloseWorkBench) |
| -32750     | +16      | old intuition -210 (OpenWorkBench)  |
| -32746     | +20      | old intuition -552 (PubScreenStatus)|
