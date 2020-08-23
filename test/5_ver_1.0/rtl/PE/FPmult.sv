module FPmult (
	input 			rst,
	input 			en,
	input 			clk,
	input	[31:0] 	a_in,
	input	[31:0] 	b_in,
	output	[31:0] 	result
);

FP32_mult	FP32_mult_inst (
	.aclr 	( rst ),
	.clk_en ( en ),
	.clock 	( clk ),
	.dataa 	( a_in ),
	.datab 	( b_in ),
	.result ( result )
	);

endmodule
