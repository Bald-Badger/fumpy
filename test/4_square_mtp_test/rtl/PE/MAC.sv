// multiply-and-accumulation module

module MAC (
	// global input
	input clk,
	input rst_n,
	input [31:0] a_in,
	input [31:0] b_in,
	
	// global output
	output [31:0] result_MAC,
	output [31:0] a_out,
	output [31:0] b_out,
	// mult IO
	input en_mult,
	input clr_mult,
	
	// accum IO
	input en_accum,
	input clr_accum
);

	// wire define
	wire[31:0] mult_result;

	mult mult_inst (
		.rst_n	(rst_n),
		.clr	(clr_mult),
		.en 	(en_mult),
		.clk 	(clk),
		.a_in 	(a_in),
		.b_in 	(b_in),
		.result (mult_result)
	);
	
	accum accum_inst (
		.clk	(clk),
		.rst_n	(rst_n),
		.en		(en_accum),
		.clr	(clr_accum),
		.data_in(mult_result),
		.data_out (result_MAC)
	);
	
	// delayed FP data, propagate to next PE
	dff_32b a_data (
		.clk(clk),
		.rst_n(rst_n),
		.d(a_in),
		.q(a_out)
	);
	
	dff_32b b_data (
		.clk(clk),
		.rst_n(rst_n),
		.d(b_in),
		.q(b_out)
	);

endmodule
