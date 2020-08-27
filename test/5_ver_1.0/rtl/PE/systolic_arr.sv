`include "../param.vh"
module systolic_arr (

	//global input 
	input clk,
	input rst_n,
	
	//data input 
	input wire[31:0]	a_in_raw	[`N-1:0],		// a input
	input wire[31:0]	w_in_raw	[`N-1:0],		// b (weight) input
	//data output 
	output wire[31:0] 	c_out		[`N-1:0][`N-1:0],	// result output

	
	//ctrl input
	input wire[`N-1:0][`N-1:0] en_mult,
	input wire[`N-1:0][`N-1:0] clr_mult,
	input wire[`N-1:0][`N-1:0] en_accum,
	input wire[`N-1:0][`N-1:0] clr_accum,
	input wire[`N-1:0][`N-1:0] accum_start
);

	//wire define
	// delayed input for a and w is necessary for systolic arr
	wire [31:0] a_in [`N-1:0]; // delayed input for a
	wire [31:0] w_in [`N-1:0]; // delayed input for w
	wire [31:0] a 	[`N-1:0][`N-1:0]; // propagation for a
	wire [31:0] w 	[`N-1:0][`N-1:0]; // propagation for w
	
	assign a_in[0] = a_in_raw[0];
	assign w_in[0] = w_in_raw[0];
	
	// delay the input of a1 and w1 by one cycle
	// this is the key for systolic array alignment
	dff_32b a1DelayReg_1 (
		.clk(clk),
		.rst_n(rst_n),
		.d(a_in_raw[1]),
		.q(a_in[1])
	);
	
	dff_32b w1DelayReg_1 (
		.clk(clk),
		.rst_n(rst_n),
		.d(w_in_raw[1]),
		.q(w_in[1])
	);
	
	
//init NxN mult-accum array
	MAC MAC_00 (
		.clk		(clk),
		.rst_n		(rst_n),
		.a_in		(a_in[0]),
		.b_in		(w_in[0]),
		.result_MAC	(c_out[0][0]),
		.a_out		(a[0][0]),
		.b_out		(w[0][0]),
		.en_mult	(en_mult[0][0]),
		.clr_mult	(clr_mult[0][0]),
		.en_accum	(en_accum[0][0]),
		.clr_accum	(clr_accum[0][0]),
		.accum_start(accum_start[0][0])
	);
	
	MAC MAC_01 (
		.clk		(clk),
		.rst_n		(rst_n),
		.a_in		(a[0][0]),
		.b_in		(w_in[1]),
		.result_MAC	(c_out[0][1]),
		.a_out		(a[0][1]),
		.b_out		(w[0][1]),
		.en_mult	(en_mult[0][1]),
		.clr_mult	(clr_mult[0][1]),
		.en_accum	(en_accum[0][1]),
		.clr_accum	(clr_accum[0][1]),
		.accum_start(accum_start[0][1])
	);
		
	MAC MAC_10 (
		.clk		(clk),
		.rst_n		(rst_n),
		.a_in		(a_in[1]),
		.b_in		(w[0][0]),
		.result_MAC	(c_out[1][0]),
		.a_out		(a[1][0]),
		.b_out		(w[1][0]),
		.en_mult	(en_mult[1][0]),
		.clr_mult	(clr_mult[1][0]),
		.en_accum	(en_accum[1][0]),
		.clr_accum	(clr_accum[1][0]),
		.accum_start(accum_start[1][0])
	);
	
	MAC MAC_11 (
		.clk		(clk),
		.rst_n		(rst_n),
		.a_in		(a[1][0]),
		.b_in		(w[0][1]),
		.result_MAC	(c_out[1][1]),
		.a_out		(a[1][1]),
		.b_out		(w[1][1]),
		.en_mult	(en_mult[1][1]),
		.clr_mult	(clr_mult[1][1]),
		.en_accum	(en_accum[1][1]),
		.clr_accum	(clr_accum[1][1]),
		.accum_start(accum_start[1][1])
	);
		
endmodule
