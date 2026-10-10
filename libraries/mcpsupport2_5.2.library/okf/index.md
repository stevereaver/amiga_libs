---
type: Library
title: mcpsupport2.library 5.x (ALiENDESiGN)
description: >-
  mcpsupport2.library (14.10.98, ALiENDESiGN) -- a helper
  library for an "MCP"-style tool.  dataSize 0x22 (plain
  Library); INIT allocates a 12-byte aux block holding
  {seglist, dosbase v37, utilitybase v36}.  Four public
  functions: a whole-file loader (Lock+Examine+AllocVec+
  Open+Read), two command-name getters that walk
  task->pr_CLI->cli_CommandName, and a recursive AmigaDOS
  wildcard matcher using utility ToUpper.
timestamp: 2026-10-28T00:00:00Z
---

# mcpsupport2.library

A ~1.4KB helper library by ALiENDESiGN (1995-98).  Its init
opens dos.library v37 and utility.library v36 into a small
12-byte aux block (separate from the 0x22 library base),
and exposes four helpers used by a Master-Control-Program-
style application.

## Binary facts

- 1392 bytes, single CODE hunk
- sha256: `4022040eebbe6b7e8a8287e98628f28f83d98edbd5804aaf50a73629a72e7b77`
- RomTag: RTF_AUTOINIT, ver 5, NT_LIBRARY, InitTable at
  hunk-off 0x78, dataSize 0x22
- FUNCTABLE = 8 LONG-address vectors + `0xffff`
- strings: "mcpsupport2.library",
  "$VER: MCPSupport2.library 5.0 (14.10.98) \n(c)1995-1998
  by ALiENDESiGN", "dos.library", "utility.library"

## Public vectors / LVOs

| LVO | name            | semantics                                   |
|-----|-----------------|---------------------------------------------|
|  -6 | Open            | standard opencnt++/clr-DELEXP                |
| -12 | Close           | opencnt--/delayed expunge                    |
| -18 | Expunge         | Remove+FreeMem base+aux (see defect)         |
| -24 | Reserved        | -> entry stub                                |
| -30 | mcpLoadFile     | (d0=allocflags,d1=name)->d0=buf,d1=size      |
| -36 | mcpCmdNameBuf   | (d0=flags,d1=len,a0=task,a1=dst)->dest       |
| -42 | mcpCmdName      | (d0=flags,a0=task)->BSTR/basename ptr        |
| -48 | mcpMatch        | (d0=pat,d1=str)->1/0 wildcard match          |

## Version discrepancy

The filename says **5.2** but the library reports **5.0**:
RomTag rt_Version=5, InitStruct revision=0, and the $VER
string reads "5.0 (14.10.98)".  The file was probably
renamed without rebuilding the version fields.

## External calls

- exec: -132 Forbid, -138 Permit, -198 AllocMem,
  -210 FreeMem, -252 Remove, -294 FindTask,
  -552 OpenLibrary, -684 AllocVec, -690 FreeVec
- dos: -30 Open, -36 Close, -42 Read, -84 Lock, -90 UnLock,
  -102 Examine, -228 AllocDosObject, -234 FreeDosObject
- utility: -174 ToUpper
