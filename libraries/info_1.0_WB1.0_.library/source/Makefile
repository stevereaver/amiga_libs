CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/info_1.0(WB1.0).library
OBJS    = info_1_0_WB1_0__h0.o info_1_0_WB1_0__h1.o info_1_0_WB1_0__h2.o info_1_0_WB1_0__h3.o info_1_0_WB1_0__h4.o info_1_0_WB1_0__h5.o info_1_0_WB1_0__h6.o info_1_0_WB1_0__h7.o info_1_0_WB1_0__h8.o info_1_0_WB1_0__h9.o info_1_0_WB1_0__h10.o info_1_0_WB1_0__h11.o info_1_0_WB1_0__h12.o info_1_0_WB1_0__h13.o info_1_0_WB1_0__h14.o info_1_0_WB1_0__h15.o info_1_0_WB1_0__h16.o info_1_0_WB1_0__h17.o info_1_0_WB1_0__h18.o info_1_0_WB1_0__h19.o info_1_0_WB1_0__h20.o

all: info.library

info.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o info.library
