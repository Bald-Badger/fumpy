module mult (
	input 			rst_n,
	input			clr,
	input 			en,
	input 			clk,
	input	[31:0] 	a_in,
	input	[31:0] 	b_in,
	output	[31:0] 	result
);

FPmult FPmult_inst (
	.rst	(rst_n || !clr),
	.en		(en),
	.clk	(clk),
	.a_in	(a_in),
	.b_in	(b_in),
	.result	(result)
);

endmodule
