#ifndef DSPBASE_H
#define DSPBASE_H

#include <exec/types.h>
#include <exec/libraries.h>

/*
 * Private library base for dsp3210.library 1.1 (3.1.2020).
 * MakeLibrary dataSize = 0x2a (42): struct Library (34) + SegList +
 * 4 bytes never touched by the original.
 * No SysBase field -- Expunge/DSPRelocate read ExecBase from 4.w.
 */
struct DSP3210Base {
	struct Library	db_Lib;		/* 0x00..0x21 */
	BPTR		db_SegList;	/* 0x22, stored by InitBase,
					   returned by Expunge */
	ULONG		db_Unused26;	/* 0x26, allocated but never used */
};

/*
 * d32 object format ("blob") as consumed by this library.
 * All multi-byte fields in the file are big-endian; the loader reads
 * them with explicit byte assembly (LAB_0018/LAB_0019 in the disasm)
 * or native big-endian loads -- equivalent on m68k.
 *
 * Header (20 bytes + extension):
 *   +0x00  u16 magic         = 0x0166
 *   +0x02  u16 nsec          number of section records
 *   +0x08  u32 symtabOff     symbol table offset (from blob start)
 *   +0x0c  u32 symCount      symbol count
 *   +0x10  u16 sectOff       section table offset, relative to blob+20
 * String table immediately follows the symbol table.
 *
 * Section record (40 bytes):
 *   +12  u32 linkedBase      address the section was linked at
 *   +16  u32 size            data size in bytes
 *   +20  u32 dataOff         offset of section data in blob
 *   +24  u32 relocOff        offset of reloc records in blob
 *   +30  u32 relocCount      number of reloc records
 *   +36  u32 flags           must equal 0x20, 0x40 or 0x80 (loadable)
 *
 * Symbol entry (18 bytes):
 *   +0   u8  inline flag     nonzero -> name is a NUL-terminated
 *                            inline string starting at +0
 *   +6   u16 strOff          name offset into string table (if +0 == 0)
 *   +8   u32 value           symbol value (linked address)
 *   +12  s16 sect            defining section, 1-based; 0 = external,
 *                            negative -> error
 *
 * Reloc record (16 bytes):
 *   +0   u32 offset          patch offset within the target section
 *   +4   u32 symIdx          symbol index (x18 into symtab)
 *   +8   u16 type            fixup kind (see D32R_*)
 */
#define D32_MAGIC	0x0166

#define D32SF_LOAD_20	0x20	/* section flags accepted by DSPCalcLen */
#define D32SF_LOAD_40	0x40
#define D32SF_LOAD_80	0x80

#define D32R_HI16	0x1c	/* write low half, error if value >= 0x10000 */
#define D32R_LONG	0x2c	/* write full 32-bit value */
#define D32R_LO16	0x2e	/* write low halfword at offset+2 */
#define D32R_HI16SW	0x2f	/* write high halfword at offset+2 */

/* error codes returned by this build (even numbering, pre-v7) */
#define DSP_ERR_BADBLOB		(-1)
#define DSP_ERR_UNKNOWN_SECT	(-2)
#define DSP_ERR_NOMEM		(-3)
#define DSP_ERR_UNKNOWN_RELOC	(-10)
#define DSP_ERR_BAD_SYM_SECT	(-20)
#define DSP_ERR_EXT_SYM		(-21)
#define DSP_ERR_SHORT_RELOC	(-30)

/* caller-supplied global symbol table (v1.1: array of pairs, not the
 * later DSP3210GlobSymHeader struct) */
struct DspExtSym {
	const char *ds_Name;	/* NUL-terminated symbol name */
	ULONG	    ds_Value;	/* resolved address */
};

#endif
