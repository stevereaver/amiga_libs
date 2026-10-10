---
type: Finding
title: No-FPU init path
description: Behaviour of the init routine when AttnFlags lacks AFF_68881.
---

# No-FPU init path

none -- on missing AFF_68881 the init routine frees the freshly allocated base and fails the resident init (returns 0).

The init routine runs with a6 = ExecBase, d0 = new base, a0 = seglist.

Singbas has no `Libs:NoFPU` string at all: without a coprocessor the init
routine simply runs the shared free tail on its *own* freshly allocated
base (a1 = d0) and returns 0, so the resident init fails cleanly.
