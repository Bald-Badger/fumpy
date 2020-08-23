module dff(
	input 	d,
	input 	clk,
	input 	rst_n,
	output 	q
);

	reg		state;
	assign q = state;
	
	always_ff @ (posedge clk or negedge rst_n)
		if (!rst_n)
			state <= 1'b0;
		else 
			state <= d;

endmodule
