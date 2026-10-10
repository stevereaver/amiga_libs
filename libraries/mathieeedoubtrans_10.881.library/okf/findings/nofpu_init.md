---
type: Finding
title: No-FPU init path
description: Behaviour of the init routine when AttnFlags lacks AFF_68881.
---

# No-FPU init path

on missing AFF_68881: OpenLibrary("Libs:NoFPU/mathieeedoubtrans.library",36), CloseLibrary(result), then runs the shared NegSize/PosSize free tail on the base OpenLibrary returned and fails the resident init.

The init routine runs with a6 = ExecBase, d0 = new base, a0 = seglist.

For this library the odd part is that after `OpenLibrary`/`CloseLibrary`
on `Libs:NoFPU/...` the code runs the shared **free tail** on the base
OpenLibrary returned -- i.e. it FreeMem()s `base - NegSize` of size
`NegSize + PosSize` for the *fallback* library's base (or, if OpenLibrary
failed, dereferences a NULL base's NegSize/PosSize and frees whatever that
yields). The pushed-then-popped copy of the new base (into d1) is a dead
restore. The reconstruction preserves this control flow verbatim; whether
it is intentional (the close already dropped OpenCnt to 0 causing an
internal expunge) or a bug is an open question.
