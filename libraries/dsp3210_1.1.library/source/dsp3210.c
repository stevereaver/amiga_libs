/*
 * dsp3210.c -- C reconstruction of dsp3210.library 1.1 (3.1.2020)
 *              Thomas Winischhofer -- loader for AT&T d32 objects
 *
 * NON-AUTOINIT resident module: rt_Init points at _ResidentInit which
 * calls MakeLibrary() + AddLibrary() itself.  Six vectors: the four
 * standard system vectors plus DSPCalcLen (-30) and DSPRelocate (-36).
 *
 * The user functions load "blob" files produced by the AT&T d32 tools:
 * DSPCalcLen returns the memory a relocation needs; DSPRelocate copies
 * the section images to the target address and applies the fixups.
 * Errors use this build's even numbering (-1,-2,-3,-10,-20,-21,-30);
 * later releases switched to odd negative codes.
 *
 * Quirks of the original reproduced here:
 *  - LibClose tests lib_OpenCnt BEFORE decrementing (over-close safe).
 *  - The blob-bound check multiplies the symbol count by 18 using a
 *    16-bit MULU (low word only).
 *  - Section data is copied with a byte loop, not CopyMem.
 *  - The third DSPRelocate argument is a plain {name,value} pair array,
 *    not the DSP3210GlobSymHeader struct of later versions.
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <proto/exec.h>
#include "dspbase.h"

#define ABSEXECBASE (*(struct ExecBase **)4)

/* resident-module symbols emitted by dsp3210_lib.s */
extern const APTR functab[];		/* _functab */
extern const UBYTE libname[];		/* _libname */
extern const UBYTE idstr[];		/* _idstr */

struct DSP3210Base *InitBase(struct DSP3210Base *base __asm("d0"),
			     BPTR seglist __asm("a0"));

/*
 * _ResidentInit -- rt_Init code for this non-AUTOINIT module.
 * Called by exec's resident scan with a0 = module seglist.
 * Builds the library via MakeLibrary and registers it with AddLibrary.
 * Returns nonzero on success, as resident init code must.
 */
ULONG ResidentInit(BPTR seglist __asm("a0"))
{
	struct Library *base;

	base = __MakeLibrary_base(ABSEXECBASE, (APTR)functab, NULL,
				  (ULONG (*)())InitBase, 0x2a,
				  (ULONG)seglist);
	if (base != NULL) {
		__AddLibrary_base(ABSEXECBASE, base);
		return 1;
	}
	return 0;
}

/*
 * InitBase -- libInit hook passed to MakeLibrary.
 * d0 = freshly allocated base, a0 = seglist; fills the library fields
 * manually (no InitStruct data is used by this module).
 */
struct DSP3210Base *InitBase(struct DSP3210Base *base __asm("d0"),
			     BPTR seglist __asm("a0"))
{
	base->db_SegList            = seglist;
	base->db_Lib.lib_Node.ln_Type = NT_LIBRARY;
	base->db_Lib.lib_Node.ln_Name = (STRPTR)libname;
	base->db_Lib.lib_Version    = 1;
	base->db_Lib.lib_Revision   = 1;
	base->db_Lib.lib_IdString   = (STRPTR)idstr;
	base->db_Lib.lib_OpenCnt    = 0;
	return base;
}

/* LibOpen (LVO -6): bump open count, clear deferred expunge, return base */
struct DSP3210Base *LibOpen(struct DSP3210Base *base __asm("a6"))
{
	base->db_Lib.lib_OpenCnt++;
	base->db_Lib.lib_Flags &= ~LIBF_DELEXP;
	return base;
}

APTR LibExpunge(struct DSP3210Base *base __asm("a6"));

/*
 * LibClose (LVO -12): quirk -- tests lib_OpenCnt BEFORE decrementing,
 * so a Close on an already-closed library returns NULL instead of
 * running the count negative.
 */
APTR LibClose(struct DSP3210Base *base __asm("a6"))
{
	if (base->db_Lib.lib_OpenCnt == 0)
		return NULL;
	if (--base->db_Lib.lib_OpenCnt == 0 &&
	    (base->db_Lib.lib_Flags & LIBF_DELEXP))
		LibExpunge(base);
	return NULL;
}

/*
 * LibExpunge (LVO -18): set LIBF_DELEXP and defer while open; otherwise
 * Remove() the node, free the base block (NegSize + PosSize), return
 * the seglist.  SysBase is read from 4.w.
 */
APTR LibExpunge(struct DSP3210Base *base __asm("a6"))
{
	APTR    seglist = NULL;
	UBYTE  *block;
	ULONG   size;

	if (base->db_Lib.lib_OpenCnt != 0) {
		base->db_Lib.lib_Flags |= LIBF_DELEXP;
		return NULL;
	}

	seglist = (APTR)(ULONG)base->db_SegList;
	__Remove_base(ABSEXECBASE, (struct Node *)base);

	block = (UBYTE *)base - base->db_Lib.lib_NegSize;
	size  = (ULONG)base->db_Lib.lib_NegSize + base->db_Lib.lib_PosSize;
	__FreeMem_base(ABSEXECBASE, block, size);

	return seglist;
}

/* LibNull (LVO -24, reserved): always returns 0 */
APTR LibNull(void)
{
	return NULL;
}

/* ------------------------------------------------------------------ */
/* d32 blob helpers                                                     */
/* ------------------------------------------------------------------ */

/*
 * On m68k the file's big-endian fields are read by plain loads -- the
 * original either uses native reads or assembles them byte-wise
 * (LAB_0018/LAB_0019) to the same effect.
 */
#define RD16(p)		(*(const UWORD *)(p))
#define RD32(p)		(*(const ULONG *)(p))
#define WR16(p,v)	(*(UWORD *)(p) = (UWORD)(v))
#define WR32(p,v)	(*(ULONG *)(p) = (ULONG)(v))

#define SECTAB(b)	((UBYTE *)(b) + 20 + RD16((const UBYTE *)(b) + 16))
#define SYMTAB(b)	((UBYTE *)(b) + RD32((const UBYTE *)(b) + 8))
#define SYMCNT(b)	RD32((const UBYTE *)(b) + 12)

/* the original's MULU: only the low word of the count participates */
#define SYMTABSIZE(b)	((ULONG)(UWORD)SYMCNT(b) * 18)

/* shared header validation + symtab bound check (blob, bound) -> bool */
static int BlobBad(const UBYTE *blob, ULONG bound)
{
	if (RD16(blob) != D32_MAGIC)
		return 1;
	if (RD32(blob + 8) + SYMTABSIZE(blob) > bound)
		return 1;
	return RD16(blob + 2) == 0;
}

static int Streq(const char *a, const char *b)
{
	while (*b != '\0' && *a == *b) {
		a++;
		b++;
	}
	return *a == '\0';
}

/*
 * DSPCalcLen (LVO -30): compute the destination buffer size needed to
 * relocate the blob at a0.  d0 carries a caller-supplied bound on the
 * blob (the symtab must end below it).
 *
 * Returns the aligned byte total, or:
 *   -1  bad magic / symtab out of bounds / no sections
 *   -2  a section flag word is not one of 0x20/0x40/0x80
 */
LONG DSPCalcLen(const UBYTE *blob __asm("a0"), ULONG bound __asm("d0"))
{
	const UBYTE *sect;
	ULONG	total = 0;
	UWORD	nsec, i;

	if (BlobBad(blob, bound))
		return DSP_ERR_BADBLOB;

	nsec = RD16(blob + 2);
	sect = SECTAB(blob);
	for (i = 0; i < nsec; i++, sect += 40) {
		ULONG flags = RD32(sect + 36);

		if (flags != D32SF_LOAD_20 &&
		    flags != D32SF_LOAD_40 &&
		    flags != D32SF_LOAD_80)
			return DSP_ERR_UNKNOWN_SECT;
		total += (RD32(sect + 16) + 3) & ~3UL;
	}
	return (LONG)total;
}

/*
 * DSPRelocate (LVO -36): load the blob at a0 to the destination a1,
 * resolving external symbols against the {name,value} pair array at a2
 * (NULL-terminated; may itself be NULL).  d0 is the blob bound as in
 * DSPCalcLen.
 *
 * Pass 1 copies each section's data to consecutive aligned slots and
 * records each load address; pass 2 walks each section's 16-byte reloc
 * records and patches the loaded image.  Relocation types:
 *   0x2c write the 32-bit value
 *   0x2e write the low 16 bits at offset+2
 *   0x2f write the high 16 bits at offset+2
 *   0x1c write the low 16 bits at offset+2, error -30 if it overflows
 *
 * Errors: -1 bad blob, -3 out of memory, -10 unknown reloc type,
 * -20 bad symbol section, -21 unresolved external, -30 short-reloc
 * overflow.
 */
LONG DSPRelocate(UBYTE *blob __asm("a0"), UBYTE *target __asm("a1"),
		 const struct DspExtSym *extsyms __asm("a2"),
		 ULONG bound __asm("d0"))
{
	ULONG	      *sectptrs = NULL;
	const UBYTE   *sectab, *symtab;
	UBYTE	      *dst;
	LONG	       err = 0;
	UWORD	       nsec, i;

	if (BlobBad(blob, bound))
		return DSP_ERR_BADBLOB;

	nsec = RD16(blob + 2);
	sectptrs = __AllocMem_base(ABSEXECBASE, (ULONG)nsec * 4,
				   MEMF_PUBLIC | MEMF_CLEAR);
	if (sectptrs == NULL)
		return DSP_ERR_NOMEM;

	sectab = SECTAB(blob);
	symtab = SYMTAB(blob);

	/* pass 1: copy section images, remember each load address */
	dst = target;
	for (i = 0; i < nsec; i++) {
		const UBYTE *sect = sectab + i * 40;
		ULONG size = RD32(sect + 16);

		sectptrs[i] = (ULONG)dst;
		if (size != 0) {
			const UBYTE *src = blob + RD32(sect + 20);
			ULONG n = size;

			while (n--)
				*dst++ = *src++;
			dst = (UBYTE *)sectptrs[i] + ((size + 3) & ~3UL);
		}
	}

	/* pass 2: apply each section's reloc records */
	for (i = 0; i < nsec; i++) {
		const UBYTE *sect = sectab + i * 40;
		const UBYTE *rec;
		ULONG nrel, j;
		UBYTE *patchbase;

		nrel = RD32(sect + 30);
		if (nrel == 0 || RD32(sect + 24) == 0)
			continue;

		rec = blob + RD32(sect + 24);
		patchbase = (UBYTE *)sectptrs[i];
		for (j = 0; j < nrel; j++, rec += 16) {
			const UBYTE *sym;
			ULONG sval;
			WORD ssect;
			UBYTE *patch;
			UWORD type;

			sym = symtab + (UWORD)RD32(rec + 4) * 18;
			sval = RD32(sym + 8);
			ssect = (WORD)RD16(sym + 12);

			if (ssect == 0) {
				/* external: resolve by name in extsyms */
				const char *name;
				const struct DspExtSym *p;

				if (sym[0] != 0)
					name = (const char *)sym;
				else
					name = (const char *)symtab +
					       SYMTABSIZE(blob) +
					       RD16(sym + 6);
				if (extsyms == NULL) {
					err = DSP_ERR_EXT_SYM;
					goto out;
				}
				for (p = extsyms; p->ds_Name != NULL; p++)
					if (Streq(p->ds_Name, name))
						break;
				if (p->ds_Name == NULL) {
					err = DSP_ERR_EXT_SYM;
					goto out;
				}
				sval = p->ds_Value;
			} else if (ssect < 0) {
				err = DSP_ERR_BAD_SYM_SECT;
				goto out;
			} else {
				/* internal: linked value -> load address */
				ULONG sidx = (ULONG)(ssect - 1);

				sval = sval - RD32(sectab + sidx * 40 + 12)
				       + sectptrs[sidx];
			}

			type = RD16(rec + 8);
			patch = patchbase + RD32(rec + 0);
			switch (type) {
			case D32R_LONG:
				WR32(patch, sval);
				break;
			case D32R_LO16:
				WR16(patch + 2, sval);
				break;
			case D32R_HI16SW:
				WR16(patch + 2, sval >> 16);
				break;
			case D32R_HI16:
				WR16(patch + 2, sval);
				if (sval & 0xffff0000UL) {
					err = DSP_ERR_SHORT_RELOC;
					goto out;
				}
				break;
			default:
				err = DSP_ERR_UNKNOWN_RELOC;
				goto out;
			}
		}
	}

out:
	__FreeMem_base(ABSEXECBASE, sectptrs, (ULONG)nsec * 4);
	return err;
}
