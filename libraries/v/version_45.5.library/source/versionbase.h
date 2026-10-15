#ifndef VERSIONBASE_H
#define VERSIONBASE_H
/*
**	versionbase.h
**
**	Private library base for version.library 45.5.
**	Layout was recovered by disassembling the shipped binary
**	"version_45.5.library" ($VER: version 45.5 (25.4.2010)).
**
**	InitTable dataSize is 0x36 = struct Library (34 bytes) plus
**	five private longs.  The last three are new since 44.x and are
**	not used by the library itself -- they are written once by
**	LibInit for external consumers that know the private layout.
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
    struct Library  *vb_Self;       /* 0x2a -- self-pointer      */
    ULONG            vb_Date;       /* 0x2e -- always 0x11081999 */
    APTR             vb_Check;      /* 0x32 -- hidden probe func */
};                                  /* 0x36                      */

#endif /* VERSIONBASE_H */
