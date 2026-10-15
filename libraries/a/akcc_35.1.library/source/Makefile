CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: akcc.library

OBJS=ak_h0.o ak_h2.o ak_h3.o ak_h4.o ak_h5.o

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

akcc.library: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@
	cmp $@ "../binary/akcc_35.1.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o akcc.library
