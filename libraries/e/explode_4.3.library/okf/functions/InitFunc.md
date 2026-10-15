# InitFunc

AUTOINIT `in_InitRoutine`.  Called with d0 = base, a0 = seglist.

1. lib_OpenCnt (+0x20) = 1; seglist stored at +0x26.
2. `OldOpenLibrary("dos.library", 33)` -> +0x22 (DOSBase).
   Failure: `Alert(0x38007)` (AG_OpenLib | AO_DOSLib).
3. Probe DOSBase-0x96 code: `4ef9` JMP vs `70` BCPL MOVEQ.
4. Patch the two counter stubs (HookCount/ByteCount operands).
5. `SetFunction(DOSBase, -0x96, LoadSegStub + {0|2})`.
6. Return base.
