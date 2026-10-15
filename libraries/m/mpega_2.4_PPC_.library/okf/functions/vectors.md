---
type: Functions
title: mpega.library 2.4 (PPC) vector map
---

# Vector map (functab: h1+0x10, absolute longs -> hunk0)

| LVO | target | behavior |
|-----|--------|----------|
| -6  | 0x03a | Open — `lea h1,a4`, bump open count, clear DELEXP, return a6 |
| -12 | 0x052 | Close — decrement open count; on 0 with DELEXP set, bsr Expunge, returns cmpiw result (quirk: d0 = `cmpiw #0x7000` outcome path) |
| -18 | 0x074 | Expunge — frees lib via exec Remove/FreeMem when count==0 |
| -24 | 0x0c0 | reserved — returns 0 |
| -30 | 0x5de | user vector — calls exec -684 (AllocSignal region) |
| -36 | 0x6e6 | user vector — ppc proxy call slot 3 |
| -42 | 0x724 | user vector — ppc proxy call slot 4 |
| -48 | 0x7f6 | user vector — ppc proxy call slot 5 |
| -54 | 0x84a | user vector — ppc proxy call slot 6 |
| -60 | 0x900 | user vector — ppc proxy call slot 7/8 (returned -4 in oracle with stubs) |
| -66 | 0x90e | user vector — ppc proxy call slot 9 |

The -36..-66 vectors all funnel through a common dispatcher that
issues ppc.library calls (exec -564 proxy / ppc message port
'MPEGA.library PPC port') — this library is a thin 68k wrapper
around `mpegappc_library.elf`.

## initfn (h0+0xe)

Opens dos.library and ppc.library (v44), attempts to load the PPC
companion `mpegappc_library.elf` then `LIBS:mpegappc_library.elf`
via ppc -30, performs follow-up ppc calls, closes both libraries,
and returns 0 when the PPC side cannot be fully established (the
observed oracle behavior with stubbed ppc.library).

## hunk0+0 module entry

`lea h1,a4; moveq #-1,d0; rts` — returns -1; the real Resident is
the one embedded at hunk1+0x100, found by the exec hunk scan.
