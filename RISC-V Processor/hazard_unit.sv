/*
 * Hazard detection/correction module.
 *
 * @note: The starting code logic comes from Section 7.5.3 of the textbook.
 *
 * Author: Sat Garcia (sat@sandiego.edu)
 */
 module hazard_unit( input logic [4:0]	rs1_d, rs2_d,
					input logic [4:0]	rs1_x, rs2_x, rd_x, rs2_m,
					input logic [1:0]	result_src_x,
					input logic 	    pc_src_x,
					input logic [4:0]	rd_m, rd_w,
					input				reg_write_m, reg_write_w,
			 		input logic              dmem_write_m, dmem_write_d,
					input logic [1:0]       result_src_w,
					output logic		stall_f, stall_d,
					output logic		flush_d, flush_x,
					output logic            forward_m,
					output logic [1:0]  forward_a_x, forward_b_x);

	logic lw_stall;

	always_comb
	begin
		// Forwarding signals for instruction in the execute stage.
		if (rs1_x != 0 & reg_write_m & rs1_x == rd_m) forward_a_x = 2'b10;
		else if (rs1_x != 0 & reg_write_w & rs1_x == rd_w) forward_a_x = 2'b01;
		else forward_a_x = 2'b00;

		if (rs2_x != 0 & reg_write_m & rs2_x == rd_m) forward_b_x = 2'b10;
		else if (rs2_x != 0 & rs2_x == rd_w & reg_write_w) forward_b_x = 2'b01;
		else forward_b_x = 2'b00;

		// Forwarding signals for instruction in the memory stage.
		

		// TODO: You'll need to fill this in for the second part of the
		// project.
		if (dmem_write_m & (result_src_w == 2'b01) & (rs2_m == rd_w)) forward_m = 1'b1;
		else forward_m = 1'b0;
		
		// Determine if we need to stall because of a data or control hazard
		lw_stall = ~dmem_write_d & result_src_x[0] & ((rs1_d == rd_x) | (rs2_d == rd_x));
		stall_f = lw_stall;
		stall_d = lw_stall;

		flush_d = pc_src_x;
		flush_x = lw_stall | pc_src_x;
	end

endmodule
