# GRDispatch (LVO -30)

```
moveml d0-a6,-(sp)
movel  d0,d7          ; save arg
moveq  #0,d0          ; findfn key = 0 (hardcoded)
bsr    findfn
bmi    done
movel  d7,d0          ; handler arg = caller's d0
jsr    (a4)
done: moveml (sp)+,d0-a6   ; ALL regs restored -> returns arg
```

Invokes the launcher's table entry with key 0, passing the
caller's d0 through.  The handler's return registers are
discarded by the full register restore, so the vector effectively
returns its own argument.  Used by the input handler itself
(via `bsr` to this entry point with d0=d1=0) to fire the
"trigger matched" callback.
