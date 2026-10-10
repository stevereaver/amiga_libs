/* Build-verification shim: StormC <clib/dos_protos.h> -> NDK protos.
   Not part of the original library; used only to syntax-check the 68k
   sources with m68k-amigaos-gcc (bebbo toolchain). */
#ifndef CLIB_DOS_PROTOS_H
#define CLIB_DOS_PROTOS_H
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#endif
