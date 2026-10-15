# mcpsupport2.library — structures

## Library base (dataSize 0x22)

Plain `struct Library` only — no private fields.
The per-library state lives in a heap aux block instead.

## Aux block (12 bytes, AllocMem'd in INIT)

| off | field                          |
|-----|--------------------------------|
|  0  | seglist (returned by Expunge)  |
|  4  | dos.library base (v37)         |
|  8  | utility.library base (v36)     |

Referenced as `auxblock` (`LAB_003C`).

## DOS structures walked by the cmd-name getters

- `task->ln_Type` @ 8 must equal 0x0d (NT_PROCESS)
- `((struct Process*)task)->pr_CLI` @ 172 — a BPTR, so
  `ptr = bcpl << 2` gives the CommandLineInterface
- `cli->cli_CommandName` @ 16 — a BPTR to a BSTR
  (length-prefixed AmigaDOS string); the code validates
  that byte0 == strlen(bytes 1..N)

## mcpLoadFile contract

`mcpLoadFile(allocflags@d0, name@d1)` ->
`d0 = AllocVec'd buffer` (size+1, NUL at [size]),
`d1 = file size`; both zero on failure.
