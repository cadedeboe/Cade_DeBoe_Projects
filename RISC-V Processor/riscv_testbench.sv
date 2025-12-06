/*
 * riscv_testbench.sv
 *
 * Author: David Harris (Updated by Sat Garcia)
 *
 * Testbench for RISC-V processor.
 */

module testbench;

	logic        clk;
	logic        reset;

	logic [31:0] write_data, data_addr;
	logic        mem_write;

	// instantiate device to be tested
	top dut(.clk, .reset, .dmem_write_data(write_data), 
			.dmem_addr(data_addr), .dmem_write(mem_write));
	  
	// initialize test
	initial
	begin
		@(negedge clk);
		reset <= 1; 
		@(negedge clk);
		reset <= 0;
	end

	// generate clock to sequence tests
	initial
		forever
		begin
			clk <= 0; #5; clk <= 1; #5;
		end

	// check that 25 gets written to address 100
	always@(negedge clk)
	begin

		$display("pc = %h, instr = %h, srca_x = %h, srcb_x = %h, alu_result_x = %h",
					dut.pc,
					dut.instr, 
					dut.core.dp.srca_x,
					dut.core.dp.srcb_x,
					dut.core.dp.alu_result_x);

		if(mem_write) begin
			if(data_addr === 100 & write_data === 25)
			 begin
				$display("Simulation succeeded!");
				$stop;
			 end
			else if (data_addr !== 96)
			 begin
				$display("Simulation failed! Incorrect result: %d (should be 25)", write_data);
				$stop;
			 end
		end
	end
endmodule
