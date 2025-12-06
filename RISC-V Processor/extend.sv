/*
 * Module that sign-extends a value.
 */
module extend(	input  logic [31:7] instr,
				input  logic [1:0]  imm_src,
				output logic [31:0] imm_ext);
              
	always_comb
		case (imm_src)
			2'b00: // I-type
				imm_ext = {{20{instr[31]}}, instr[31:20]};
			2'b01: // S-type (stores)
				imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
			2'b10: // B-type (branches)
				imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
			2'b11: // J-type (jal)
				imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
			default: // undefined
				imm_ext = 32'bx;
		endcase

endmodule
