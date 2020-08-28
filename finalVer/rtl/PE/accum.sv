module accum (
	input clk,				// clk signal
	input rst_n,			// global reset
	input en,				// enable accum
	input clr,				// clear data in reg and adder
	input [31:0] data_in,	// FP input
	input accum_start,		// high for 1 cycle 
							// together with first bit to accum		
	output [31:0] data_out	// FP output
	
);

	FP32_accum accum_base (
		.clk	(clk),
		.areset (!rst_n || clr),	// Asynchronous active-high reset
		.x		(data_in),	// Data input port
		
		/*
	Boolean port which signals the beginning of a new data set to be
	accumulated. This should go high together with the first element in the
	new data set and should go low the next cycle. The data sets may be of
	variable length and a new data set may be started at any time. The
	accumulation result for an input will be available after the reported
	latency.
		*/
		.n		(accum_start), 
		.en		(en),
		.r		(data_out)
	);
	
endmodule
