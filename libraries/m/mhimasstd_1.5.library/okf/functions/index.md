# Functions

Standard MHI sublibrary vector table (mhi_dev spec):

- MHIAllocDecoder(d0=sigmask, a0=task) - 64KB+25B handle; defaults
  volume=100, params[6]=50; claims misc.resource MR units 2+3
  (parallel port bits/alloc); single decoder via _mhiallocated latch.
- MHIFreeDecoder(handle) - FreeMem, FreeMiscResource x2, drains a
  MinList of 20-byte queue nodes, closes graphics.library.
- MHIQueueBuffer/GetEmpty - FIFO of queued stream buffers.
- Play/Stop/Pause - CIA-B port bit strobe control.
- MHIQuery - capability bitmask.  MHISetParam - params 0..5.
