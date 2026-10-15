CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: cgxvideo.library

OBJS=cgv_h0.o cgv_h1.o cgv_h2.o cgv_h3.o

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

cgxvideo.library: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@
	cmp $@ "../binary/cgxvideo_41.10(020)(CVPPC)(CGX3).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o cgxvideo.library
