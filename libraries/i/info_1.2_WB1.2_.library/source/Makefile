CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/info_1.2(WB1.2).library
OBJS    = info_1_2_WB1_2__h0.o info_1_2_WB1_2__h1.o info_1_2_WB1_2__h2.o info_1_2_WB1_2__h3.o info_1_2_WB1_2__h4.o info_1_2_WB1_2__h5.o info_1_2_WB1_2__h6.o info_1_2_WB1_2__h7.o info_1_2_WB1_2__h8.o info_1_2_WB1_2__h9.o info_1_2_WB1_2__h10.o info_1_2_WB1_2__h11.o info_1_2_WB1_2__h12.o info_1_2_WB1_2__h13.o info_1_2_WB1_2__h14.o info_1_2_WB1_2__h15.o info_1_2_WB1_2__h16.o info_1_2_WB1_2__h17.o info_1_2_WB1_2__h18.o info_1_2_WB1_2__h19.o info_1_2_WB1_2__h20.o info_1_2_WB1_2__h21.o info_1_2_WB1_2__h22.o info_1_2_WB1_2__h23.o info_1_2_WB1_2__h24.o

all: info.library

info.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o info.library
