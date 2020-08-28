module dff_32b(
	input 			clk,
	input 			rst_n,
	input	[31:0]	d,
	output 	[31:0]	q
);

	reg [31:0]	state;
	assign 	q = state;
	
	always_ff @ (posedge clk or negedge rst_n)
		if (!rst_n)
			state <= 32'b0;
		else 
			state <= d;

endmodule
