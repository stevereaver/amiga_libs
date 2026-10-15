---
file: defects
---
# Findings

- Flags 0x81 (AUTOINIT|bit0), same as the whole mathtrans line.
- 3 zero-length CODE + 1 zero-length DATA linker artifacts.
- Deterministic unmapped reads at 0xffffff2e+ under stubs.
