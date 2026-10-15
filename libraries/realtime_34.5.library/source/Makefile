CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: realtime.library

realtime_h0.o: realtime_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

realtime.library: realtime_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/realtime_34.5.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o realtime.library
