module accum (
	input clk,				// clk signal
	input rst_n,			// global reset
	input en,				// enable adder
	input clr,				// clear data in reg and adder
	input [31:0] data_in,	// FP input
	output [31:0] data_out	// FP output
	
);

	wire [31:0] result;		// calculation result from FPadd

	dff_32b data (
		.clk	(clk),
		.rst_n	(rst_n || !clr),
		.d		(result),
		.q		(data_out)
	);
	
	FPadd FPadd_inst (
		.rst	(!rst_n || clr),
		.en 	(en),
		.clk	(clk),
		.a_in	(data_in),
		.b_in	(data_out),
		.result	(result)
	);
	
endmodule