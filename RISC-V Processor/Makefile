FAMILY=Cyclone IV E
PART=EP4CE22F17C6
PROJECT_NAME=comp300_p09
CORE_FILES=adder.sv alu.sv aludec.sv core_controller.sv core_datapath.sv eq.sv extend.sv flip_flops.sv hazard_unit.sv maindec.sv muxes.sv regfile.sv riscv_core.sv

TARGETS=output_files/$(PROJECT_NAME).map.rpt

all: $(TARGETS)

# Rule to synthesize the risc_core module using Quartus
output_files/$(PROJECT_NAME).map.rpt: $(CORE_FILES)
	quartus_map $(PROJECT_NAME) $(addprefix --source=,$^) --family="$(FAMILY)" --part="$(PART)"

clean:
	@rm -f $(TARGETS)
