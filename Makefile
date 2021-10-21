CFLAGS := -Wall
VFLAGS := --cc --exe --build --trace -Wno-INITIALDLY -Wno-WIDTH -Wno-UNUSED
VFILES := $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp

veri: vga_controller.cpp vga_controller.v $(VFILES)
	verilator $(CFLAGS) $(VFLAGS) $^

# Project setup
PROJ      = vga-gpu
DEVICE    = 5k
FOOTPRINT = sg48
YOSYS_OPTS= -noautowire # Generate errors if wires were implicitly created
FREQ ?= 35

# Files
FILES = top.v

.PHONY: all clean burn

all:
	# synthesize using Yosys
	yosys -ql top.log  -p 'synth_ice40 -json top.json' top.sv
	# Place and route using arachne
	nextpnr-ice40 --up5k --package sg48 --freq $(FREQ) --json top.json --pcf pinmap.pcf --asc top.asc -v --seed 1234567 --no-print-critical-path-source
	icetime -c $(FREQ) -d up5k -mtr top.rpt top.asc
	# Convert to bitstream using IcePack
	icepack top.asc top.bin

prog_flash: all
	icesprog top.bin

clean:
	rm *.asc *.rpt *.json *.log *.bin
