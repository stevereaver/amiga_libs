# Functions

- LibInit — stores sys(+36)/seglist(+44), opens dos.library -> +40.
- LibOpen/LibClose/LibExpunge — Expunge also CloseLibrary's dos,
  calls medplayer's -36 vector then exec CloseLibrary (double
  close — see defects), frees base.
- InitModule — see okf/index.md tag table; builds 80B session.
- EndModule — MPStop if playing, MPFree if mpinit, frees module
  buffer + session, closes medplayer, clears base+48.
- PlayModule — one-shot medplayer -30 init (base+156 gate), stop-
  current via -54, then -42 on the module buffer.
- StopModule — -54 + flags; ContModule — -48 when stopped.
- SetVolume — stop, clamp to sess+20 maxvol, -96, restart.
- GetDesc — static description string.
