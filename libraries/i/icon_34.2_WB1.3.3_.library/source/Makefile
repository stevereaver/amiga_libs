CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: icon.library

OBJS=ic_h0.o ic_h1.o ic_h2.o ic_h3.o ic_h4.o ic_h5.o ic_h6.o ic_h7.o ic_h8.o ic_h9.o

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

icon.library: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@
	cmp $@ "../binary/icon_34.2(WB1.3.3).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o icon.library
