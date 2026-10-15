# Findings & defects

- Zero-size DATA hunk emitted by the original linker (quirky
  but legal; fixup pre-seeds an empty pool).
- Close underflows open count (65534).
- init allocates two MsgPorts + member blocks, sets up signal
  masks — full runtime structure created even with stubbed dos.
