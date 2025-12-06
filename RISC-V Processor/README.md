# RISC-V Processor

A 32-bit pipelined RISC-V processor implementation in SystemVerilog. This project implements a complete processor core with hazard detection, forwarding, and support for a subset of the RISC-V instruction set.

## Overview

This processor implements a 5-stage pipelined architecture:
- **Fetch (F)**: Fetches instructions from instruction memory
- **Decode (D)**: Decodes instructions and reads register file
- **Execute (X)**: Performs ALU operations and branch comparisons
- **Memory (M)**: Accesses data memory for load/store operations
- **Writeback (W)**: Writes results back to register file

## Features

- **Pipelined Architecture**: 5-stage pipeline for improved performance
- **Hazard Detection**: Stalls pipeline when data hazards are detected
- **Forwarding**: Forwarding unit to resolve data hazards without stalling
- **Instruction Support**:
  - R-type instructions (ADD, SUB, AND, OR, XOR, SLT, etc.)
  - I-type ALU instructions (ADDI, ANDI, ORI, XORI, SLTI, etc.)
  - Load instructions (LW)
  - Store instructions (SW)
  - Branch instructions (BEQ)
  - Jump instructions (JAL)

## Project Structure

### Core Modules

- `riscv_core.sv` - Top-level processor core module
- `core_datapath.sv` - Implements the processor datapath
- `core_controller.sv` - Implements control logic and hazard unit
- `hazard_unit.sv` - Detects hazards and generates control signals
- `maindec.sv` - Main instruction decoder
- `aludec.sv` - ALU control decoder
- `regfile.sv` - Register file (32 registers)
- `alu.sv` - Arithmetic Logic Unit
- `adder.sv` - Adder module for PC calculation
- `extend.sv` - Immediate value extension unit
- `muxes.sv` - Multiplexer modules
- `flip_flops.sv` - Pipeline register modules

### Memory Modules

- `imem.sv` - Instruction memory
- `dmem.sv` - Data memory

### Test Infrastructure

- `system.sv` - Top-level system module (core + memories)
- `riscv_testbench.sv` - Testbench for simulation
- `unit_tests/` - Directory containing unit test files
  - `unit1.asm` through `unit7.asm` - Assembly test programs
  - `unit1.dat` through `unit7.dat` - Expected memory data

### Build Files

- `Makefile` - Build configuration for Quartus synthesis
- `comp300_p09.qpf` - Quartus project file
- `comp300_p09.qsf` - Quartus settings file
- `run_tb.do` - ModelSim/Questa simulation script
- `run_unit_test.do` - Unit test simulation script

## Requirements

- **Quartus Prime** (for synthesis)
  - Target device: Cyclone IV E (EP4CE22F17C6)
- **ModelSim** or **Questa Sim** (for simulation)
- **SystemVerilog** support

## Building

### Synthesis

To synthesize the processor using Quartus:

```bash
make
```

This will generate synthesis reports in the `output_files/` directory.

### Clean Build Artifacts

```bash
make clean
```

## Simulation

### Running the Testbench

Use ModelSim/Questa Sim with the provided TCL script:

```bash
vsim -do run_tb.do
```

### Running Unit Tests

To run individual unit tests:

```bash
vsim -do run_unit_test.do
```

## Architecture Details

### Pipeline Stages

1. **Fetch**: Reads instruction from instruction memory at PC address
2. **Decode**: Decodes instruction, reads register file, generates control signals
3. **Execute**: Performs ALU operations, evaluates branch conditions
4. **Memory**: Accesses data memory for load/store operations
5. **Writeback**: Writes ALU result or memory data back to register file

### Hazard Handling

The processor includes a comprehensive hazard unit that:
- Detects data hazards between pipeline stages
- Implements forwarding to resolve most data hazards
- Stalls the pipeline when forwarding cannot resolve hazards
- Handles load-use hazards with pipeline stalls
- Flushes pipeline stages on branch/jump taken

### Forwarding Paths

- Forward from Memory stage to Execute stage
- Forward from Writeback stage to Execute stage
- Forward store data from Memory stage

## Instruction Format Support

The processor supports the following RISC-V instruction formats:

- **R-type**: Register-register operations (ADD, SUB, AND, OR, XOR, SLT)
- **I-type**: Immediate ALU operations and loads (ADDI, ANDI, ORI, XORI, SLTI, LW)
- **S-type**: Store instructions (SW)
- **B-type**: Branch instructions (BEQ)
- **J-type**: Jump instructions (JAL)

## Testing

The project includes multiple unit tests located in the `unit_tests/` directory. Each test verifies different aspects of the processor:

- Unit 1: Basic arithmetic operations
- Unit 2: Load/store operations
- Unit 3a/3b: Branch instructions
- Unit 4: Jump instructions
- Unit 5: Complex instruction sequences
- Unit 6: Additional test cases
- Unit 7: Comprehensive processor test

## Authors

- Based on work by David and Sarah Harris
- Updated by Sat Garcia
- Project: COMP300 P09

## License

This project appears to be an academic assignment. Please refer to your course guidelines for usage and distribution policies.

## Notes

- The instruction memory (`imem`) uses a simplified addressing scheme (PC[7:2])
- The processor implements a subset of the RISC-V ISA
- Pipeline registers use flip-flops with reset capability
- The design targets an FPGA (Cyclone IV E) but can be simulated in any SystemVerilog simulator

