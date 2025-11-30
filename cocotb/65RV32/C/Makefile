PROJECT:=baremetal
OBJECTS:=tholinstd.o baremetal.o
TARGETS:=$(OBJECTS) $(PROJECT).elf $(PROJECT).bin $(PROJECT).debug.txt

all : $(TARGETS)

ARCHFLAGS:=-march=rv32im_zicsr -mabi=ilp32

PREFIX:=/home/tholin/riscv/bin/riscv32-unknown-elf-
CFLAGS:=-I.

CFLAGS+=-fno-stack-protector
CFLAGS+=-static-libgcc -fdata-sections -ffunction-sections
CFLAGS+=-g -O2 $(ARCHFLAGS) -static -ffreestanding
LDFLAGS:= -T flatfile.lds -nostdlib -Wl,--gc-sections -lgcc

$(PROJECT).elf : $(OBJECTS)
	$(PREFIX)as $(ARCHFLAGS) -mno-relax -o start.o start.S
	$(PREFIX)gcc -o $@ $(OBJECTS) start.o $(CFLAGS) $(LDFLAGS)

$(PROJECT).debug.txt : $(PROJECT).elf
	$(PREFIX)objdump -t $^ > $@
	$(PREFIX)objdump -S $^ >> $@

$(PROJECT).bin : $(PROJECT).elf
	$(PREFIX)objcopy $^ -O binary $@
	
%.o: %.c
	$(PREFIX)gcc $(CFLAGS) -c -o $@ $<

clean :
	rm -rf $(TARGETS)
	rm -rf $(OBJECTS)
	rm -rf start.o
