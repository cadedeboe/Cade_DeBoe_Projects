/*
 * File: imem.sv
 *
 * Module for an asynchronous read, synchronous write memory module.
 * The contents of memory is initialized from imem.dat, which should
 * contain RISC-V instructions in HEX format (one per line).
 *
 * @note This is NOT synthesizable. Only use this for simulation.
 */
module imem(input  logic [5:0]  addr,
            output logic [31:0] read_data);

	logic [31:0] RAM [0:63];

	initial
	begin
		string imem_filename;

		// if the imem filename wasn't set on the command line, use a default
		// value (imem.dat)
		if (!$value$plusargs("IMEM_FILE=%s", imem_filename))
			imem_filename = "imem.dat";

		$display("imem_filename = %s", imem_filename);

		$readmemh(imem_filename, RAM); // load memory contents from file
	end

	assign read_data = RAM[addr]; // word aligned
endmodule
