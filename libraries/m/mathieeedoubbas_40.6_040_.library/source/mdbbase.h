#ifndef MDBBASE_H
#define MDBBASE_H
/*
**	mstbase.h
**
**	Private library base for mathieeedoubbas.library 40.6
**	"for 68881/82" ($VER-style id: "mathieeedoubbas 40.6
**	(7.4.95) for 68881/82").
**
**	InitTable dataSize is 0x2c = struct Library (34 bytes) plus
**	SysBase, the seglist BPTR, and a private flag byte whose
**	bit 3 plays the DELEXP role -- the original does NOT use
**	lib_Flags for deferred expunge (see okf/findings/).
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */

#define MDBF_DELEXP	0x08	/* bit 3 of the private flag byte */

struct MDBBase
{
    struct Library   mdb_Lib;       /* 0x00                      */
    struct ExecBase *mdb_SysBase;   /* 0x22 -- a6 saved by init  */
    BPTR             mdb_SegList;   /* 0x26 -- a0 saved by init  */
    UBYTE            mdb_Flags;     /* 0x2a -- private DELEXP    */
    UBYTE            mdb_pad;       /* 0x2b                      */
};                                  /* 0x2c                      */

#endif /* MDBBASE_H */
