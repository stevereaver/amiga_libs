CC=/opt/amiga/bin/m68k-amigaos-gcc
TARGET=streplay.library

all: $(TARGET)

$(TARGET): streplay_lib.o
	$(CC) -nostdlib -nostartfiles -Wl,-s -o $@ $<
	python3 fixup.py $@

%.o: %.s
	$(CC) -m68000 -c -o $@ $<

clean:
	rm -f *.o $(TARGET)
