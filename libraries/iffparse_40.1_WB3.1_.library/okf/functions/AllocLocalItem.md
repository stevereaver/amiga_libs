---
type: Function
title: AllocLocalItem
description: AllocVec(size+24,MEMF_CLEAR).
lvo: -186
registers: d0,d1,d2,d3
timestamp: 2026-10-10T18:00:00Z
---

# `struct LocalContextItem *AllocLocalItem(type,id,ident,size)`

**LVO -186** — registers `d0,d1,d2,d3`

AllocVec(size+24,MEMF_CLEAR); fills lci_ID/type/ident; purge=NULL.
