/*
 * Module for a 2 input multiplexer.
 */
module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             sel, 
              output logic [WIDTH-1:0] y);

	assign y = sel ? d1 : d0; 
endmodule

/*
 * Module for a 3 input multiplexer.
 */
module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       sel, 
              output logic [WIDTH-1:0] y);

	assign y = sel[1] ? d2 : (sel[0] ? d1 : d0); 
endmodule
