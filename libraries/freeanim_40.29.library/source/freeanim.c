/*
**	freeanim.c -- freeanim.library 40.29 (1.4.94)
**
**	C reconstruction of the shipped binary
**	"freeanim_40.29.library" (id: "freeanim 40.29 (1.4.94)").
**
**	The original is a pure stub: the AUTOINIT function table has
**	exactly four entries (LVO -6 Open, -12 Close, -18 Expunge,
**	-24 ExtFunc) and all of them, plus the InitTable init routine,
**	point at the same "moveq #0,d0 / rts".  No public functions.
**
**	Note: an init routine that returns 0 tells MakeLibrary/
**	InitResident that initialisation failed -- see okf findings.
*/

#include <exec/types.h>
#include <exec/libraries.h>

/* the one and only routine in the original image */
LONG LibNull(void);

LONG LibNull(void)
{
    return 0;
}
