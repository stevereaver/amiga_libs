# LoadSeg hook (InitFunc-installed)

At init the library patches DOS vector `-0x96` (LoadSeg) via
`SetFunction`.  Two stub forms are supported, detected by probing the
original vector code:

- KS2+ `JMP` style (0x4ef9): the hook installs at the `JSR` half of
  the stub and calls the original target directly.
- KS1.x BCPL style (`MOVEQ #n,D0; BRA dispatcher`): the hook copies
  the function number into its own `MOVEQ` and JSRs the dispatcher.

On walk failure the function Alerts `0x00028007` and returns without
patching (4.3 re-inspected forever).

Hook body (post-call, result = seglist BPTR):

```
lsl.l #2,d0 ; a0 = first hunk
if !d0: out                       ; NULL check (added in 4.6)
if *(a0+4)  == 0x48e7ffff         ; explode-stub MOVEM prologue
   && *(a0+40) == "expl"          ; signature (4 longs in 4.6)
   && *(a0+44) == "ode."
   && *(a0+48) == "libr"
   && *(a0+52) == "ary\0" :
       ctr1++                     ; decrunch count (patched stub)
       a5 = a0 + 32               ; packed stream
       decode into a 0x3e frame on the stack
       ctr2 += bytes emitted
return d0 (seglist, now decompressed)
```

The counters live in the library base at +0x2e / +0x32; the stub
instructions' operands are patched at init to point there.

Security/behaviour note: this transparently rewrites program files on
load - a Trojan-style vector by modern standards, though standard
practice for 1990 packers.  It also never restores the hook and the
library cannot be expunged (null Expunge, OpenCnt hard-set).
