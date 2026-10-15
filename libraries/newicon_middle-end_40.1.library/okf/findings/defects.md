# Findings & defects

- Functab and InitTable live in the DATA hunk; initfn is in CODE —
  the cross-hunk resident/init wiring is the inverse of the usual
  shape (same family as rexxmathlib/newicon_39.1).
- initfn opens dos37/graphics39/icon37 then immediately does a
  speculative read of ENV:NewIcons.prefs (openlib/GetVar path).
- 0 invalid accesses.
