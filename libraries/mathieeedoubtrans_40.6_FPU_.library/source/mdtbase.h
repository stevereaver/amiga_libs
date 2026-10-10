#ifndef MDTBASE_H
#define MDTBASE_H
/*
**	mdtbase.h
**
**	Private library base for mathieeedoubtrans.library 40.6
**	"for 68881/82" (id: "mathieeedoubtrans 40.6 (7.4.95) for
**	68881/82", "(c) 1995 by Martin Berndt").
**
**	InitTable dataSize is 0x2c = struct Library (34 bytes) plus
**	SysBase, the seglist BPTR, and a private flag byte whose
**	bit 3 plays the DELEXP role -- the original does NOT use
**	lib_Flags for deferred expunge.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */

#define MDTF_DELEXP	0x08	/* bit 3 of the private flag byte */

struct MDTBase
{
    struct Library   mdt_Lib;       /* 0x00                      */
    struct ExecBase *mdt_SysBase;   /* 0x22 -- a6 saved by init  */
    BPTR             mdt_SegList;   /* 0x26 -- a0 saved by init  */
    UBYTE            mdt_Flags;     /* 0x2a -- private DELEXP    */
    UBYTE            mdt_pad;       /* 0x2b                      */
};                                  /* 0x2c                      */

#endif /* MDTBASE_H */
