---
type: Findings
title: launcher 41.9 quirks
---

# Findings / quirks

- initfn spawns/waits on a handler task (FindName
  'launcher.library' + WaitPort/GetMsg/Signal) — the service
  is message-driven.
- Default output is a CON: window; TOOLPRI env var read.
