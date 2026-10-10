#include <clib/dos_protos.h>
#include <libraries/zlib.h>
#include <string.h>
#include "zlib.h"

static BOOL getmode(char *mode,ULONG openmode,ULONG strategy,ULONG level)
{
switch(openmode)
	{
	case MODE_OLDFILE:
		mode[0]='r';
		break;
	case MODE_NEWFILE:
		mode[0]='w';
		break;
	default:
		return 0;
	}
switch(strategy)
	{
	case GZ_STRATEGY_DEFAULT:
		mode[1]='d';
		break;
	case GZ_STRATEGY_FILTERED:
		mode[1]='f';
		break;
	case GZ_STRATEGY_HUFFMAN:
		mode[1]='h';
		break;
	default:
		return 0;
	}
if(level>9) level=9;
mode[2]=level+'0';
mode[3]=0;
return 1;
}

APTR __saveds PPCGZ_Open(struct Library *ZLibBase,char *filename,ULONG openmode,ULONG strategy,ULONG level)
{
char mode[4];
if(!getmode(mode,openmode,strategy,level)) return 0;
return gzopen(filename,mode);
}

APTR __saveds PPCGZ_OpenFromFH(struct Library *ZLibBase,BPTR fh,ULONG openmode,ULONG strategy,ULONG level)
{
char mode[4];
if(!getmode(mode,openmode,strategy,level)) return 0;
return gzdopen(fh,mode);
}

long __saveds PPCGZ_Close(struct Library *ZLibBase,APTR gzhandle)
{
return gzclose(gzhandle);
}

long __saveds PPCGZ_Read(struct Library *ZLibBase,APTR gzhandle,APTR buf,ULONG len)
{
return gzread(gzhandle,buf,len);
}

char * __saveds PPCGZ_FGetS(struct Library *ZLibBase,APTR gzhandle,char *buf,ULONG len)
{
return gzgets(gzhandle,buf,len);
}

long __saveds PPCGZ_FGetC(struct Library *ZLibBase,APTR gzhandle)
{
return gzgetc(gzhandle);
}

long __saveds PPCGZ_Write(struct Library *ZLibBase,APTR gzhandle,APTR buf,ULONG len)
{
return gzwrite(gzhandle,buf,len);
}

long __saveds PPCGZ_CompressMem(struct Library *ZLibBase,APTR srcbuf,ULONG srclen,APTR destbuf,ULONG destlen,ULONG strategy,ULONG level,ULONG *poutlen)
{
z_stream stream;
int err,stra;
memset(&stream,0,sizeof(stream));
if(poutlen) *poutlen=0;
stream.next_in=(Byte *)srcbuf;
stream.avail_in=(uInt)srclen;
stream.next_out=destbuf;
stream.avail_out=(uInt)destlen;
if(level<0) level=0;
else if(level>9) level=9;
switch(strategy)
	{
	case GZ_STRATEGY_FILTERED:
		stra=Z_FILTERED;
		break;
	case GZ_STRATEGY_HUFFMAN:
		stra= Z_HUFFMAN_ONLY;
		break;
	default:
		stra=Z_DEFAULT_STRATEGY;
	}
err=deflateInit2_(&stream,level,Z_DEFLATED,MAX_WBITS,8,stra,ZLIB_VERSION,sizeof(z_stream));
if(err!=Z_OK) return err;
err=deflate(&stream,Z_FINISH);
if(err!=Z_STREAM_END)
	{
	deflateEnd(&stream);
	return err==Z_OK?Z_BUF_ERROR:err;
	}
if(poutlen) *poutlen=stream.total_out;
return deflateEnd(&stream);
}

long __saveds PPCGZ_DecompressMem(struct Library *ZLibBase,APTR srcbuf,ULONG srclen,APTR destbuf,ULONG destlen)
{
z_stream stream;
int err;
memset(&stream,0,sizeof(stream));
stream.next_in=(Byte *)srcbuf;
stream.avail_in=(uInt)srclen;
stream.next_out=destbuf;
stream.avail_out=(uInt)destlen;
err=inflateInit(&stream);
if(err!=Z_OK) return err;
err=inflate(&stream,Z_FINISH);
if(err!=Z_STREAM_END)
	{
	inflateEnd(&stream);
	return err==Z_OK?Z_BUF_ERROR:err;
	}
return inflateEnd(&stream);
}

typedef struct gz_stream {
    z_stream stream;
    int      z_err;   /* error code for last stream operation */
    int      z_eof;   /* set if end of input file */
    BPTR     file;   /* .gz file */
    Byte     *inbuf;  /* input buffer */
    Byte     *outbuf; /* output buffer */
    uLong    crc;     /* crc32 of uncompressed data */
    char     *msg;    /* error message */
    char     *path;   /* path name for debugging only */
    int      transparent; /* 1 if input file is not a .gz file */
    char     mode;    /* 'w' or 'r' */
    long     startpos; /* start of compressed data in file (header skipped) */
} gz_stream;

ULONG __saveds PPCGZ_FileLength(struct Library *ZLibBase,APTR gzhandle)
{
UBYTE c[4];
gz_stream *s=(gz_stream *)gzhandle;
long oldpos=Seek(s->file,-4,OFFSET_END);
FRead(s->file,c,4,1);
Seek(s->file,oldpos,OFFSET_BEGINNING);
return (c[3]<<24)|(c[2]<<16)|(c[1]<<8)|c[0];
}
