# cxb.library — public function notes

- `-30 cxbFileInfo(name@a0)` : Lock(name,ACCESS_READ) ->
  Examine -> UnLock.  Returns 0 when Examine succeeds, -1
  otherwise.  Uses the caller-context's dos base.
- `-36 cxbMult(a@d0,b@d1)` : 32-bit product.
- `-42 cxbMult209(a@d0)` : `a*209` (original: `MULS #0xd1` —
  the reconstruction uses the equivalent `a*209`).
- `-48 cxbRequest(a0,a1,a2)` : EasyRequestArgs on the static
  "(C) 1998 Captain Crossbones" EasyStruct through the
  context's intuition base.
