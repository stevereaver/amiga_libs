/* Build-verification shim for the __PPC__ path (not compiled on 68k). */
#ifndef CLIB_POWERPC_PROTOS_H
#define CLIB_POWERPC_PROTOS_H
#include <proto/exec.h>
static inline APTR AllocVecPPC(ULONG size, ULONG flags, ULONG align) { return AllocVec(size, flags); }
static inline void FreeVecPPC(APTR p) { FreeVec(p); }
#endif
