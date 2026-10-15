/* Build-verification stub for StormC's <libbase.h>.
   Real StormC semantics: sLibBaseC declares a base-library descriptor;
   the library's init code opens "powerpc.library" (min version) into a
   global base pointer, FALSE = non-fatal if open fails. Reproduced here
   only well enough to syntax-check libbase.c as C89. */
#ifndef LIBBASE_H
#define LIBBASE_H
#include <exec/types.h>
struct sLibBaseC_ { char *name; unsigned long minver; int required; void *base; };
#define sLibBaseC  static struct sLibBaseC_
#define PowerPCBase(n,v,r)  PowerPCBase_desc = { (n),(v),(r),0 }
#endif
