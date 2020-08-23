module ALU (
	input clk,
	input calc,
	input [31:0] a, 
	input [31:0] b,
	output [31:0] c,
	output done
);
	assign done = 1'b1;
	assign c = calc ? (a+b) : 0;
endmodule