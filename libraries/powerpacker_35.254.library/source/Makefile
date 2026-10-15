CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles
all: powerpacker.library
powerpacker.library: pp_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/powerpacker_35.254.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<
