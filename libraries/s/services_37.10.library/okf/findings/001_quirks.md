# Quirks and inconsistencies (services.library 37.10)

## 1. Alert on missing utility.library

LibInit hard-fails with Alert(0x3800c) if utility.library
v37 cannot be opened (it always exists on 2.0+), and calls
CloseLibrary on the uninitialised nipc slot first -- benign
only because AUTOINIT memory is clear.

## 2. nipc LVOs have no shipped fd

The nipc calls (-66, -114, -120, -126, -132, -138, -144,
-150) are documented here by offset; their names are
inferred from context.  nipc.library's own includes were
never part of the standard NDK.

## 3. LibOpen's NULL return

LibOpen returns NULL instead of the base when the lazy
nipc open fails -- OpenCnt is still incremented on the
success path only, so a failed open leaves the count
untouched.

## 4. The {0x7800,"Services"} blob

The data pushed for tag 0x800b1001 is a {u16 0x7800,
"Services"} structure sitting in the code stream at 0x434
-- opaque to services itself, consumed by nipc -126.

## 5. SvcFormat threads the cursor through a3

The putch hook post-increments a3, so RawDoFmt's userdata
is the write position itself -- an unusual but legal use
of the RawDoFmt contract.
