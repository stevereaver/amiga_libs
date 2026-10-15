#ifndef VERSIONBASE_H
#define VERSIONBASE_H
/*
**	versionbase.h
**
**	Private library base for version.library 47.2 (Workbench 3.2).
**	Layout was recovered by disassembling the shipped binary
**	"version.library_47.2(WB3.2)" ($VER: version 47.2 (10.4.2021)).
**
**	InitTable dataSize is 0x2a = struct Library (34 bytes) plus
**	two private longs filled in by the init routine -- the same
**	compact base as the 39/40.x builds (no hidden semaphore
**	probe fields like the 44.x/45.x line).
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */

struct VersionBase
{
    struct Library   vb_Lib;        /* 0x00                      */
    struct ExecBase *vb_SysBase;    /* 0x22 -- a6 saved by init  */
    BPTR             vb_SegList;    /* 0x26 -- a0 saved by init  */
};                                  /* 0x2a                      */

#endif /* VERSIONBASE_H */
