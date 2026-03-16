.PHONY: clean simulate quartus synth upload gen_asm

VFLAGS = -O3 --x-assign fast --x-initial fast --noassert
SDL_CFLAGS = `sdl2-config --cflags`
SDL_LDFLAGS = `sdl2-config --libs`

help:
	$(info make help    - show this message(default))
	$(info make clean   - delete synth folder)
	$(info make quartus - open project in Quartus Prime)
	$(info make synth   - synthesize project in Quartus)
	$(info make upload  - upload project to the FPGA board)
	@true

# ------------------------------------------------------------------------------
# Generation and project creation
# ------------------------------------------------------------------------------

gen-asm:
    #  nc                              - Copyright notice will not be displayed
    #  a                               - assembly only, do not simulate
    #  ae<n>                           - terminate RARS with integer exit code if an assemble error occurs
    #  dump .text HexText program.hex  - dump segment .text to program.hex file in HexText format
	java -jar ./scripts/rars1_6.jar nc a ae1 dump .text HexText ./rtl/program.hex ./rtl/program.s

rars: ./scripts/rars1_6.jar
	java -jar ./scripts/rars1_6.jar &

# ------------------------------------------------------------------------------
# Simulation
# ------------------------------------------------------------------------------

SIM_OUT_DIR := "./sim/icarus/output_files"

$(SIM_OUT_DIR):
	rm -rf $(SIM_OUT_DIR)
	mkdir $(SIM_OUT_DIR)

sim-build: $(SIM_OUT_DIR)
	iverilog -g2012 -o $(SIM_OUT_DIR)/sim.out -I ./rtl -I include/basics-graphics-music/labs/common \
		include/basics-graphics-music/labs/common/*sv ./rtl/*.sv ./rtl/core/*.sv \
		./sim/icarus/tb.sv # >> $(SIM_OUT_DIR)/log.txt 2>&1

sim-run: sim-build gen-asm
	vvp $(SIM_OUT_DIR)/sim.out # >> $(SIM_OUT_DIR)/log.txt 2>&1

sim-clean:
	rm -rf ./sim/icarus/output_files/

# ------------------------------------------------------------------------------
# Synthesis
# ------------------------------------------------------------------------------

CABLE_NAME   ?= "USB-Blaster"
PROJECT_DIR  ?= ./synth/fpga/de10_lite
PROJECT_NAME ?= "board_specific"

QUARTUS     := cd $(PROJECT_DIR) && quartus
QUARTUS_SH  := cd $(PROJECT_DIR) && quartus_sh
QUARTUS_PGM := cd $(PROJECT_DIR) && quartus_pgm

# when we run quartus bins from WSL it can be installed on host W10
# it this case we have to add .exe to the executed binary name
ifdef WSL_DISTRO_NAME
 ifeq (, $(shell which $(QUARTUS)))
  QUARTUS     := $(QUARTUS).exe
  QUARTUS_SH  := $(QUARTUS_SH).exe
  QUARTUS_PGM := $(QUARTUS_PGM).exe
 endif
endif

# make open
#  cd project && quartus <projectname> &
#     cd project            - go to project folder 
#	  &&                    - if previous command was successfull
#     quartus <projectname> - open <projectname> in quartus 
#     &                     - run previous command in shell background
quartus:
	$(QUARTUS) $(PROJECT_NAME) &

# make build
#  cd project && quartus_sh --flow compile <projectname>
#     cd project                              - go to project folder 
#     &&                                      - if previous command was successfull
#     quartus_sh --flow compile <projectname> - run quartus shell & perform basic compilation 
#                                               of <projectname> project
synth:
	$(QUARTUS_SH) --no_banner --flow compile $(PROJECT_NAME)
	make upload

# make load
#  cd project && quartus_pgm -c "USB-Blaster" -m JTAG -o "p;<projectname>.sof"
#     cd project               - go to project folder 
#	  &&                       - if previous command was successfull
#     quartus_pgm              - launch quartus programmer
#     -c "USB-Blaster"         - connect to "USB-Blaster" cable
#     -m JTAG                  - in JTAG programming mode
#     -o "p;<projectname>.sof" - program (configure) FPGA with <projectname>.sof file
upload:
	$(QUARTUS_PGM) --no_banner -c $(CABLE_NAME) -m JTAG -o "p;output_files/$(PROJECT_NAME).sof"
