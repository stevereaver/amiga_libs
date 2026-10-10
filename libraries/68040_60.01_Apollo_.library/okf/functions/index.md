---
type: Index
title: Functions
description: System vectors of the Apollo 68040.library 60.01 loader.
---

# Functions

The library exports only the four mandatory system vectors; there are
no user-callable LVOs.

- [LibInit](LibInit.md) — AUTOINIT init routine (not an LVO): CPU-flag
  checks + pre-open of the real CPU library
- [LibOpen](LibOpen.md) — LVO -6, OpenCnt++ and return the base
- [LibClose](LibClose.md) — LVO -12, OpenCnt-- then returns 0
- [LibExpunge](LibExpunge.md) — LVO -18 and -24 (shared stub), returns 0
