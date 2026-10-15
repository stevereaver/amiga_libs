CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles
all: rtggadtools.library
rtggadtools.library: rt_h0.o rt_h1.o rt_h2.o rt_h3.o rt_h4.o
	$(CC) $(CFLAGS) -o $@ rt_h0.o rt_h1.o rt_h2.o rt_h3.o rt_h4.o
	python3 fixup.py $@
	cmp $@ "../binary/rtggadtools_1.0.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<
