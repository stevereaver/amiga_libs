#ifndef VERSIONBASE_H
#define VERSIONBASE_H
/*
**	versionbase.h
**
**	Private library base for version.library 40.42 (Workbench 3.1).
**	Layout was recovered by disassembling the shipped binary
**	"version_40.42(WB3.1).library" ($VER: version 40.42 (18.2.94)).
**
**	InitTable dataSize is 0x2a = struct Library (34 bytes) plus
**	two private longs filled in by the init routine.
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
