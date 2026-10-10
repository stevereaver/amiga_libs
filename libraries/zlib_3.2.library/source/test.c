#include <clib/asyncio_protos.h>
#include <clib/zlib_protos.h>
#include <stdio.h>
#include "zlib.h"

char buf[65536];

int main(void)
{
struct AsyncFile *fr;
if(fr=OpenAsync("ram:astorb.dat",MODE_WRITE,65536))
	{
	APTR gz;
	if(gz=GZ_Open("DH1:astorb.dat.gz",MODE_OLDFILE,0,0))
		{
		ULONG tot=0;
		for(;;)
			{
			long len;
			len=GZ_Read(gz,buf,65536);
			if(len<=0) break;
			WriteAsync(fr,buf,len);
			tot+=len;
			printf("\r%lu",tot);
			}
		GZ_Close(gz);
		}
	CloseAsync(fr);
	}
return 0;
}

/*
void main()
{
APTR gz;
if(gz=GZ_Open("DH1:astorb.dat.gz",MODE_OLDFILE,0,0))
	{
	printf("%ld\n",GZ_FileLength(gz));
	printf("%lx\n",GZ_FileLength(gz));
	GZ_Close(gz);
	}
}
*/
