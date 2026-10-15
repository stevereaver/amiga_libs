# Findings -- shipped defects and inconsistencies

## 1. Double Permit (TDNestCnt underflow)

Both proxy functions `Forbid()` once but `Permit()`
twice per invocation (once inside the attempt branch,
once unconditionally at the end).  Every successful or
skipped call decrements the task's forbid-nesting count
one step too far -- after N calls a task that Forbids
for real later will find its nest count already
negative.  On a long-lived task this is a slow-acting
scheduler-state corruption.

## 2. RomTag is decorative / unbuildable by InitResident

RT_FLAGS has RTF_AUTOINIT set, but RT_INIT = 0 and
RT_ENDSKIP points at +0x1e (inside LibInit).  Standard
InitResident cannot build this library; it requires the
private loader that consumes the manual InitTable in
hunk2.  The RomTag fields are vestigial SAS/C template
output.

## 3. port+46 is an undocumented application field

The WarpCore base is read from MsgPort+46 -- six bytes
past the standard 40-byte MsgPort.  Relies on the
service allocating an extended port; any other port
named "ReqAttack Warp Core" with a standard layout would
return garbage past its allocation.

## 4. Dead "li" tail bytes in hunk0

The last two bytes of the code hunk are "li" -- the
start of a truncated extra string (probably a leftover
"library" fragment from linker's string pool).

## 5. Empty SAS/C far-data fixup template

hunk1 is two zero longs -- the offset table the init
scans is empty (count 0), so the entire fixup loop plus
the base+0x30 region exists for a relocation that never
happens in this build.

## 6. -3 is the "not handled" sentinel in-band with data

The proxy forwards the WarpCore result verbatim unless
it equals -3.  If a legitimate requester call could
produce -3 it would be silently re-routed through
intuition a second time.
