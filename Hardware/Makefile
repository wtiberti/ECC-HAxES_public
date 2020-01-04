TESTBEDS=$(shell ls|grep 'tb_.*\.vhd')
VCDS=$(TESTBEDS:.vhd=.vcd)

all: $(VCDS)
	

tb_%.vcd: %.vhd tb_%.vhd
	echo "Analyzing component $*"
	ghdl -a --std=08 $*.vhd
	echo "Analyzing testbench tb_$*"
	ghdl -a --std=08 tb_$*.vhd
	#echo "Running testbench tb_$*"
	#ghdl -r --std=08 tb_$* --stop-time=500us --vcd=$@

.PHONY: clean
clean:
	rm -f *.vcd *.cf
