# HEADDBGV01 debug hunk

The shipped binary leads with a HUNK_DEBUG hunk containing a
"HEADDBGV01" blob (14 longs) before the code hunk - an unusual
custom debug-info header.  Standard hunk layout otherwise.
