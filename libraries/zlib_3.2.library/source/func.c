#include <clib/dos_protos.h>
#include <exec/libraries.h>
#include <libraries/zlib.h>
#include <string.h>
#include <zlib.h>

struct ZLibBase
{
struct Library zb_lib;
};

#pragma libbase ZLibBase

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

#ifdef __STORMGCC__
APTR __saveds GZ_Open(char *filename __asm("a0"),ULONG openmode __asm("d0"),ULONG strategy __asm("d1"),ULONG level __asm("d2"),struct Library *ZLibBase __asm("a6"))
#else
APTR __saveds GZ_Open(register __a0 char *filename,register __d0 ULONG openmode,register __d1 ULONG strategy,register __d2 ULONG level,register __a6 struct Library *ZLibBase)
#endif
{
char mode[4];
if(!getmode(mode,openmode,strategy,level)) return 0;
return gzopen(filename,mode);
}

#ifdef __STORMGCC__
APTR __saveds GZ_OpenFromFH(BPTR fh __asm("a0"),ULONG openmode __asm("d0"),ULONG strategy __asm("d1"),ULONG level __asm("d2"),struct Library *ZLibBase __asm("a6"))
#else
APTR __saveds GZ_OpenFromFH(register __a0 BPTR fh,register __d0 ULONG openmode,register __d1 ULONG strategy,register __d2 ULONG level,register __a6 struct Library *ZLibBase)
#endif
{
char mode[4];
if(!getmode(mode,openmode,strategy,level)) return 0;
return gzdopen(fh,mode);
}

#ifdef __STORMGCC__
long __saveds GZ_Close(APTR gzhandle __asm("a0"),struct Library *ZLibBase __asm("a6"))
#else
long __saveds GZ_Close(register __a0 APTR gzhandle,register __a6 struct Library *ZLibBase)
#endif
{
return gzclose(gzhandle);
}

#ifdef __STORMGCC__
long __saveds GZ_Read(APTR gzhandle __asm("a0"),APTR buf __asm("a1"),ULONG len __asm("d0"),struct Library *ZLibBase __asm("a6"))
#else
long __saveds GZ_Read(register __a0 APTR gzhandle,register __a1 APTR buf,register __d0 ULONG len,register __a6 struct Library *ZLibBase)
#endif
{
return gzread(gzhandle,buf,len);
}

#ifdef __STORMGCC__
char* __saveds GZ_FGetS(APTR gzhandle __asm("a0"),char *buf __asm("a1"),ULONG len __asm("d0"),struct Library *ZLibBase __asm("a6"))
#else
char* __saveds GZ_FGetS(register __a0 APTR gzhandle,register __a1 char *buf,register __d0 ULONG len,register __a6 struct Library *ZLibBase)
#endif
{
return gzgets(gzhandle,buf,len);
}

#ifdef __STORMGCC__
long __saveds GZ_FGetC(APTR gzhandle __asm("a0"),struct Library *ZLibBase __asm("a6"))
#else
long __saveds GZ_FGetC(register __a0 APTR gzhandle,register __a6 struct Library *ZLibBase)
#endif
{
return gzgetc(gzhandle);
}

#ifdef __STORMGCC__
long __saveds GZ_Write(APTR gzhandle __asm("a0"),APTR buf __asm("a1"),ULONG len __asm("d0"),struct Library *ZLibBase __asm("a6"))
#else
long __saveds GZ_Write(register __a0 APTR gzhandle,register __a1 APTR buf,register __d0 ULONG len,register __a6 struct Library *ZLibBase)
#endif
{
return gzwrite(gzhandle,buf,len);
}

#ifdef __STORMGCC__
long __saveds GZ_CompressMem(APTR srcbuf __asm("a0"),ULONG srclen __asm("d0"),APTR destbuf __asm("a1"),ULONG destlen __asm("d1"),ULONG strategy __asm("d2"),ULONG level __asm("d3"),ULONG *poutlen __asm("a2"),struct Library *ZLibBase __asm("a6"))
#else
long __saveds GZ_CompressMem(register __a0 APTR srcbuf,register __d0 ULONG srclen,register __a1 APTR destbuf,register __d1 ULONG destlen,register __d2 ULONG strategy,register __d3 ULONG level,register __a2 ULONG *poutlen,register __a6 struct Library *ZLibBase)
#endif
{
z_stream stream;
int err,stra;
memset(&stream,0,sizeof(stream));
if(poutlen) *poutlen=0;
stream.next_in=(Byte *)srcbuf;
stream.avail_in=(uInt)srclen;
stream.next_out=destbuf;
stream.avail_out=(uInt)destlen;
if(level>9) level=9;
switch(strategy)
	{
	case GZ_STRATEGY_FILTERED:
		stra=Z_FILTERED;
		break;
	case GZ_STRATEGY_HUFFMAN:
		stra=Z_HUFFMAN_ONLY;
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

#ifdef __STORMGCC__
long __saveds GZ_DecompressMem(APTR srcbuf __asm("a0"),ULONG srclen __asm("d0"),APTR destbuf __asm("a1"),ULONG destlen __asm("d1"),struct Library *ZLibBase __asm("a6"))
#else
long __saveds GZ_DecompressMem(register __a0 APTR srcbuf,register __d0 ULONG srclen,register __a1 APTR destbuf,register __d1 ULONG destlen,register __a6 struct Library *ZLibBase)
#endif
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

#ifdef __STORMGCC__
ULONG __saveds GZ_FileLength(APTR gzhandle __asm("a0"),struct Library *ZLibBase __asm("a6"))
#else
ULONG __saveds GZ_FileLength(register __a0 APTR gzhandle,register __a6 struct Library *ZLibBase)
#endif
{
UBYTE c[4];
gz_stream *s=(gz_stream *)gzhandle;
long oldpos=Seek(s->file,-4,OFFSET_END);
FRead(s->file,c,4,1);
Seek(s->file,oldpos,OFFSET_BEGINNING);
return (c[3]<<24)|(c[2]<<16)|(c[1]<<8)|c[0];
}
