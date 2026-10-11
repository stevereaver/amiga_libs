CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
	 -I/opt/amiga/m68k-amigaos/ndk-include -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
TARGET = bfbplayGMOD.library
OBJS = bfbplayGMOD_lib.o bfbplayGMOD.o endmodule.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET)
