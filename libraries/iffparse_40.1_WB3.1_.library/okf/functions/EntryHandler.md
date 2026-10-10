---
type: Function
title: EntryHandler
description: Installs an 'ehnd' LCI {hook,object} at position in the current context's LCI list.
lvo: -102
registers: a0,d0,d1,d2,a1,a2
timestamp: 2026-10-10T18:00:00Z
---

# `LONG EntryHandler(iff,type,id,pos,hook,obj)`

**LVO -102** — registers `a0,d0,d1,d2,a1,a2`

Installs an 'ehnd' LCI {hook,object} at position in the current context's LCI list; invokes on chunk entry.
