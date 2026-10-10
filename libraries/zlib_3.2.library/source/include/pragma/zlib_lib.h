#ifndef _INCLUDE_PRAGMA_ZLIB_LIB_H
#define _INCLUDE_PRAGMA_ZLIB_LIB_H

#ifndef CLIB_ZLIB_PROTOS_H
#include <clib/zlib_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ZLibBase,0x01E,GZ_Open(a0,d0,d1,d2))
#pragma amicall(ZLibBase,0x024,GZ_OpenFromFH(a0,d0,d1,d2))
#pragma amicall(ZLibBase,0x02A,GZ_Close(a0))
#pragma amicall(ZLibBase,0x030,GZ_Read(a0,a1,d0))
#pragma amicall(ZLibBase,0x036,GZ_FGetS(a0,a1,d0))
#pragma amicall(ZLibBase,0x03C,GZ_FGetC(a0))
#pragma amicall(ZLibBase,0x042,GZ_Write(a0,a1,d0))
#pragma amicall(ZLibBase,0x048,PPCGZ_Open())
#pragma amicall(ZLibBase,0x04E,PPCGZ_OpenFromFH())
#pragma amicall(ZLibBase,0x054,PPCGZ_Close())
#pragma amicall(ZLibBase,0x05A,PPCGZ_Read())
#pragma amicall(ZLibBase,0x060,PPCGZ_FGetS())
#pragma amicall(ZLibBase,0x066,PPCGZ_FGetC())
#pragma amicall(ZLibBase,0x06C,PPCGZ_Write())
#pragma amicall(ZLibBase,0x072,GZ_CompressMem(a0,d0,a1,d1,d2,d3,a2))
#pragma amicall(ZLibBase,0x078,GZ_DecompressMem(a0,d0,a1,d1))
#pragma amicall(ZLibBase,0x07E,PPCGZ_CompressMem())
#pragma amicall(ZLibBase,0x084,PPCGZ_DecompressMem())
#pragma amicall(ZLibBase,0x08A,GZ_FileLength(a0))
#pragma amicall(ZLibBase,0x090,PPCGZ_FileLength())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ZLibBase GZ_Open              01E 210804
#pragma  libcall ZLibBase GZ_OpenFromFH        024 210804
#pragma  libcall ZLibBase GZ_Close             02A 801
#pragma  libcall ZLibBase GZ_Read              030 09803
#pragma  libcall ZLibBase GZ_FGetS             036 09803
#pragma  libcall ZLibBase GZ_FGetC             03C 801
#pragma  libcall ZLibBase GZ_Write             042 09803
#pragma  libcall ZLibBase PPCGZ_Open           048 00
#pragma  libcall ZLibBase PPCGZ_OpenFromFH     04E 00
#pragma  libcall ZLibBase PPCGZ_Close          054 00
#pragma  libcall ZLibBase PPCGZ_Read           05A 00
#pragma  libcall ZLibBase PPCGZ_FGetS          060 00
#pragma  libcall ZLibBase PPCGZ_FGetC          066 00
#pragma  libcall ZLibBase PPCGZ_Write          06C 00
#pragma  libcall ZLibBase GZ_CompressMem       072 A32190807
#pragma  libcall ZLibBase GZ_DecompressMem     078 190804
#pragma  libcall ZLibBase PPCGZ_CompressMem    07E 00
#pragma  libcall ZLibBase PPCGZ_DecompressMem  084 00
#pragma  libcall ZLibBase GZ_FileLength        08A 801
#pragma  libcall ZLibBase PPCGZ_FileLength     090 00
#endif

#endif	/*  _INCLUDE_PRAGMA_ZLIB_LIB_H  */
