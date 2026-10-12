# screennotify.library 1.2 — library base (0x386 = 902 bytes)

```
+0   Library (34)
+34  flag (UBYTE) — "workbench closed" state byte.
      Set to 0xff by SNE when CloseWorkBench succeeds;
      cleared when a WBENCH-type screen opens.
      Checked by CloseWorkBench patch (skip pre-notify)
      and by the worker (skip type-3 broadcast).
+36  seglist
+40  exec base
+44  intuition base
+48  graphics base   (opened LAST in init, used for WaitTOF)
+52  dos base        (used for CreateNewProcTagList, Delay)
+56  handshake Message (mn_Length=0x18)
      +70 = mn_ReplyPort -> replyport
      +76 = body: out = lib base / in = worker MsgPort
+80  reply MsgPort (CreateMsgPort)
+84  worker MsgPort (the "context" the patches PutMsg to)
+88  list block 1 (122 bytes) — screen-close clients
+210 list block 2 (122 bytes) — pub-status clients
+332 list block 3 (122 bytes) — workbench clients
+454 old OpenScreenTagList
+458 old CloseScreen
+462 old CloseWorkBench
+466 old PubScreenStatus
+470 patch image copy (0x1b0 = 432 bytes) -> +902
```

## list block (122 bytes)

```
+0   MinList (12)
+14  SignalSemaphore (46)
+60  Message (28): mn_ReplyPort -> own port, mn_Length = 28
      body blk+80 = type, blk+84 = arg
+88  MsgPort (34): ln_Type=NT_MSGPORT, mp_SigBit=8 (hardcoded),
      mp_SigTask=self (set per broadcast), mp_MsgList
```

## patch image (0x1b0 bytes, copied to lib+470)

```
+0    (+470) OpenScreenTagList hook
+0x3a (+528) CloseScreen hook
+0x4e (+548) broadcast walker   <- worker jmp target: `jmp 548(a5)`
+0xda (+688) PubScreenStatus hook
+0x16e(+836) CloseWorkBench hook
+0x1a6(+892) next-node helper
```

## worker process image (0x9c = 156 bytes)

AllocVec'd copy; CreateNewProcTagList with
`NP_Entry = image`, `NP_Name = image+136` ("scn service process").

Entry: `FindTask(NULL)` -> wait on `pr_MsgPort`; handshake msg
body[0] = lib base; creates its own port, writes it into the
handshake reply body, computes its signal mask.

Loop: Wait(mask); GetMsg -> NULL means die (DeleteMsgPort +
FreeVec(self)); otherwise Delay(10) via dos base, then if flag@34
== 0 broadcast type 3 / arg 1 on list 3 via `jmp 548(libbase)`.
