# Work log

- ira disasm -> identified 22-vector AUTOINIT lib
- decoded init (3 OldOpenLibrary + unwind), tick-wait, IOStdReq
  send/cancel, dos-internal calls, charset/format/tokenize helpers
- C model + asm shell; builds valid library
- pending: deep pass on supervisor trampoline + mode-2/3 dispatcher
