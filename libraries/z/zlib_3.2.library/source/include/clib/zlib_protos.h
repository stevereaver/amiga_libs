#ifndef CLIB_ZLIB_PROTOS_H
#define CLIB_ZLIB_PROTOS_H
#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif
#ifndef LIBRARIES_ZLIB_H
#include <libraries/zlib.h>
#endif

#ifndef __PPC__

#ifdef __cplusplus
extern "C" {
#endif

/* V1.0 */

APTR GZ_Open(char *filename,ULONG openmode,ULONG strategy,ULONG level);
APTR GZ_OpenFromFH(BPTR fh,ULONG openmode,ULONG strategy,ULONG level);
long GZ_Close(APTR gzhandle);
long GZ_Read(APTR gzhandle,APTR buf,ULONG len);
char *GZ_FGetS(APTR gzhandle,char *buf,ULONG len);
long *GZ_FGetC(APTR gzhandle);
long GZ_Write(APTR gzhandle,APTR buf,ULONG len);

/* V2.0 */

long GZ_CompressMem(APTR srcbuf,ULONG srclen,APTR destbuf,ULONG destlen,ULONG strategy,ULONG level,ULONG *poutlen);
long GZ_DecompressMem(APTR srcbuf,ULONG srclen,APTR destbuf,ULONG destlen);

/* V3.0 */
ULONG GZ_FileLength(APTR gzhandle);

#ifdef __cplusplus
}
#endif

#else /* __PPC__ */

#ifdef __STORMGCC__

#ifndef EXEC_LIBRARIES
#include <exec/libraries.h>
#endif

extern struct Library *ZLibBase;

#define PPCGZ_Open(filename,openmode,strategy,level) \
	((APTR (*)(struct Library *,char *,ULONG,ULONG,ULONG)) \
	(*(long *)(((char *)ZLibBase)-0x48+2)))(ZLibBase,filename,openmode,strategy,level)

#define PPCGZ_OpenFromFH(fh,openmode,strategy,level) \
	((APTR (*)(struct Library *,BPTR,ULONG,ULONG,ULONG)) \
	(*(long *)(((char *)ZLibBase)-0x4e+2)))(ZLibBase,fh,openmode,strategy,level)

#define PPCGZ_Close(gzhandle) \
	((long (*)(struct Library *,APTR)) \
	(*(long *)(((char *)ZLibBase)-0x54+2)))(ZLibBase,gzhandle)

#define PPCGZ_Read(gzhandle,buf,len) \
	((long (*)(struct Library *,APTR,APTR,ULONG)) \
	(*(long *)(((char *)ZLibBase)-0x5a+2)))(ZLibBase,gzhandle,buf,len)

#define PPCGZ_Write(gzhandle,buf,len) \
	((long (*)(struct Library *,APTR,APTR,ULONG)) \
	(*(long *)(((char *)ZLibBase)-0x6c+2)))(ZLibBase,gzhandle,buf,len)

#define PPCGZ_FGetS(gzhandle,buf,len) \
	((char * (*)(struct Library *,APTR,char *,ULONG)) \
	(*(long *)(((char *)ZLibBase)-0x60+2)))(ZLibBase,gzhandle,buf,len)

#define PPCGZ_FGetC(gzhandle) \
	((long (*)(struct Library *,APTR)) \
	(*(long *)(((char *)ZLibBase)-0x66+2)))(ZLibBase,gzhandle)

#define PPCGZ_CompressMem(srcbuf,srclen,destbuf,destlen,strategy,level,poutlen) \
	((long (*)(struct Library *,APTR,ULONG,APTR,ULONG,ULONG,ULONG,ULONG *)) \
	(*(long *)(((char *)ZLibBase)-0x7e+2)))(ZLibBase,srcbuf,srclen,destbuf,destlen,strategy,level,poutlen)

#define PPCGZ_DecompressMem(srcbuf,srclen,destbuf,destlen) \
	((long (*)(struct Library *,APTR,ULONG,APTR,ULONG)) \
	(*(long *)(((char *)ZLibBase)-0x84+2)))(ZLibBase,srcbuf,srclen,destbuf,destlen)

#define PPCGZ_FileLength(gzhandle)
	((ULONG (*)(struct Library *,APTR)) \
	(*(long *)(((char *)ZLibBase)-0x90+2)))(ZLibBase,gzhandle)

#elif defined(__STORM__)

extern "AmigaLib" ZLibBase
{
APTR PPCGZ_Open_(struct Library *,char *,ULONG,ULONG,ULONG)=-0x48;
APTR PPCGZ_OpenFromFH_(struct Library *,BPTR,ULONG,ULONG,ULONG)=-0x4e;
long PPCGZ_Close_(struct Library *,APTR)=-0x54;
long PPCGZ_Read_(struct Library *,APTR,APTR,ULONG)=-0x5a;
char *PPCGZ_FGetS_(struct Library *,APTR,char *,ULONG)=-0x60;
long *PPCGZ_FGetC_(struct Library *,APTR)=-0x66;
long PPCGZ_Write_(struct Library *,APTR,APTR,ULONG)=-0x6c;
long PPCGZ_CompressMem_(struct Library *,APTR,ULONG,APTR,ULONG,ULONG,ULONG,ULONG *)=-0x7e;
long PPCGZ_DecompressMem_(struct Library *,APTR,ULONG,APTR,ULONG)=-0x84;
ULONG PPCGZ_FileLength_(struct Library *,APTR)=-0x90;
}

extern struct Library *ZLibBase;

__inline APTR PPCGZ_Open(char *a1,ULONG a2,ULONG a3,ULONG a4)
{
return PPCGZ_Open_(ZLibBase,a1,a2,a3,a4);
}

__inline APTR PPCGZ_OpenFromFH(BPTR a1,ULONG a2,ULONG a3,ULONG a4)
{
return PPCGZ_OpenFromFH_(ZLibBase,a1,a2,a3,a4);
}

__inline long PPCGZ_Close(APTR a1)
{
return PPCGZ_Close_(ZLibBase,a1);
}

__inline long PPCGZ_Read(APTR a1,APTR a2,ULONG a3)
{
return PPCGZ_Read_(ZLibBase,a1,a2,a3);
}

__inline char *PPCGZ_FGetS(APTR a1,char *a2,ULONG a3)
{
return PPCGZ_FGetS_(ZLibBase,a1,a2,a3);
}

__inline long *PPCGZ_FGetC(APTR a1)
{
return PPCGZ_FGetC_(ZLibBase,a1);
}

__inline long PPCGZ_Write(APTR a1,APTR a2,ULONG a3)
{
return PPCGZ_Write_(ZLibBase,a1,a2,a3);
}

__inline long PPCGZ_CompressMem(APTR a1,ULONG a2,APTR a3,ULONG a4,ULONG a5,ULONG a6,ULONG *a7)
{
return PPCGZ_CompressMem_(ZLibBase,a1,a2,a3,a4,a5,a6,a7);
}

__inline long PPCGZ_DecompressMem(APTR a1,ULONG a2,APTR a3,ULONG a4)
{
return PPCGZ_DecompressMem_(ZLibBase,a1,a2,a3,a4);
}

__inline ULONG PPCGZ_FileLength(APTR a1)
{
return PPCGZ_FileLength_(ZLibBase,a1);
}

#endif /* __STORM__ */

#endif /* __PPC__ */

#endif

