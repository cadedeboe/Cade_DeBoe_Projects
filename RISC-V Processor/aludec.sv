/*
 * aludec.sv
 *
 * Authors: David and Sarah Harris
 * Updated By: Sat Garcia
 *
 * Module that computes ALU control signals.
 */
module aludec(input  logic       op_b5,
              input  logic [2:0] funct3,
              input  logic       funct7_b5,
              input  logic [1:0] alu_op,
              output logic [2:0] alu_ctrl);

	logic r_type_sub;

	assign r_type_sub = funct7_b5 & op_b5; // TRUE for R-type subtract

	always_comb
		case(alu_op)
			2'b00: alu_ctrl = 3'b010;  // addition
			2'b01: alu_ctrl = 3'b110;  // subtraction
			default: // R-type or I-type ALU
				case(funct3)
					3'b000:
						if (r_type_sub)
							alu_ctrl = 3'b110; // sub
						else
							alu_ctrl = 3'b010; // add, addi
					3'b010: alu_ctrl = 3'b111; // slt, slti
					3'b110: alu_ctrl = 3'b001; // or, ori
					3'b111: alu_ctrl = 3'b000; // and, andi
					default: alu_ctrl = 3'bxxx; // ???
				endcase
		endcase
endmodule
