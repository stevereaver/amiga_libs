---
file: vectors
---
# Vectors

10 LVOs (-6 .. -60) via thunk slots @h0+0x5a..0xc2:

open/close/expunge/reserved + 6 user vectors; handlers do fifo
channel work (exec -132/-138 = Disable/Enable-style or signal ops,
-246/-384/-252 = PutMsg/WaitPort/CloseLibrary on a fifo device
port, AllocMem/FreeMem buffers). One slot is a literal 0 vector
(reserved entry kept in the table).
