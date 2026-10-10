# mcpsupport2.library — public functions

- `-30 mcpLoadFile(d0=flags, d1=name)`: reads the whole
  named file into an AllocVec buffer; returns buffer in d0
  and size in d1.
- `-36 mcpCmdNameBuf(d0=flags, d1=len, a0=task, a1=dest)`:
  copies the resolved command name (basename if flags&1)
  into dest[len].
- `-42 mcpCmdName(d0=flags, a0=task)`: returns a pointer to
  the command-name BSTR text (or its basename).
- `-48 mcpMatch(d0=pattern, d1=string)`: AmigaDOS wildcard
  match, 1/0.
