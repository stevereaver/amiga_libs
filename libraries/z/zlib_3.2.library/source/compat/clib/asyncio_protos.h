/* Build-verification shim: StormC <clib/asyncio_protos.h> (asyncio.library
   prototypes). Only needed for the example programs, not the library. */
#ifndef CLIB_ASYNCIO_PROTOS_H
#define CLIB_ASYNCIO_PROTOS_H
#include <exec/types.h>
#include <dos/dos.h>
struct AsyncFile;
extern struct AsyncFile *OpenAsync(STRPTR,ULONG,LONG);
extern LONG CloseAsync(struct AsyncFile *);
extern LONG ReadAsync(struct AsyncFile *,APTR,LONG);
extern LONG WriteAsync(struct AsyncFile *,APTR,LONG);
extern LONG SeekAsync(struct AsyncFile *,LONG,ULONG);
extern LONG WriteCharAsync(struct AsyncFile *,UBYTE);
extern LONG ReadCharAsync(struct AsyncFile *);
extern void SetAsyncMode(struct AsyncFile *,LONG);
#endif
/* asyncio open modes */
#define MODE_READ   0
#define MODE_WRITE  1
#define MODE_RDWR   2
