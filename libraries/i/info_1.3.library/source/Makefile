CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/info_1.3.library
OBJS    = info_1_3_h0.o info_1_3_h1.o info_1_3_h2.o info_1_3_h3.o info_1_3_h4.o info_1_3_h5.o info_1_3_h6.o info_1_3_h7.o info_1_3_h8.o info_1_3_h9.o info_1_3_h10.o info_1_3_h11.o info_1_3_h12.o info_1_3_h13.o info_1_3_h14.o info_1_3_h15.o info_1_3_h16.o info_1_3_h17.o info_1_3_h18.o info_1_3_h19.o info_1_3_h20.o info_1_3_h21.o info_1_3_h22.o info_1_3_h23.o info_1_3_h24.o

all: info.library

info.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o info.library
