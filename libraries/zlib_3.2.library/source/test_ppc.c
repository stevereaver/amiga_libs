#include <clib/asyncio_protos.h>
#include <clib/exec_protos.h>
#include <clib/zlib_protos.h>
#include <stdio.h>
#include "zlib.h"

char buf[65536];

struct Library *AsyncIOBase;
struct Library *ZLibBase;

int main(void)
{
struct AsyncFile *fr;
AsyncIOBase=OpenLibrary("asyncio.library",40);
ZLibBase=OpenLibrary("zlib.library",2);
if(fr=OpenAsyncPPC("ram:astorb.dat",MODE_WRITE,65536))
	{
	APTR gz;
	puts("ok1");
	if(gz=PPCGZ_Open("DH1:astorb.dat.gz",MODE_OLDFILE,0,0))
		{
		ULONG tot=0;
		puts("ok2");
		for(;;)
			{
			long len;
			len=PPCGZ_Read(gz,buf,65536);
			if(len<=0) break;
			WriteAsyncPPC(fr,buf,len);
			tot+=len;
			printf("\r%lu",tot);
			}
		PPCGZ_Close(gz);
		}
	CloseAsyncPPC(fr);
	}
CloseLibrary(AsyncIOBase);
CloseLibrary(ZLibBase);
return 0;
}

