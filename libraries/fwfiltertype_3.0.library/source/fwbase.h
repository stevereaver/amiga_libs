#ifndef FWFILTERBASE_H
#define FWFILTERBASE_H

#include <exec/types.h>
#include <exec/libraries.h>

/*
 * Private library base for fwfiltertype.library 3.0.
 * InitTable dataSize = 0x28 (40): struct Library (34) + pad + SegList.
 * No SysBase field -- Expunge reads ExecBase from 4.w directly.
 */
struct FWFilterBase {
	struct Library	fb_Lib;		/* 0x00..0x21 */
	UWORD		fb_Pad22;	/* 0x22 unused */
	BPTR		fb_SegList;	/* 0x24, stored by LibInit,
					   returned by Expunge */
};

#endif
