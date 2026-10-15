---
file: defects
---
# Findings (000 build)

- Clean hunk0: declared 0x423 longs == physical body
  (the 020 sibling's 2B overrun is absent here).
- No AttnFlags gate on initfn — this is the 68000 build.
- Same codec bugs as 020: unpacker trusts xsp+0x10 output
  length (no dst bounds check); flag-2 continuation stream
  on a fresh decoder ctx silently yields garbage.
- PackerInfo lname is "Shrink V3.0" (vs "Shrink 020+ V3.0");
  everything else (sign, flags, mode count, wire format)
  is shared.
