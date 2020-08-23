module edgeTB ();

logic clk, in, outPos, outNeg, rst_n;

posedgeDect pd (
	.clk(clk),
	.rst_n(rst_n),
	.in (in),
	.out (outPos)
);

negedgeDect nd (
	.clk(clk),
	.rst_n(rst_n),
	.in (in),
	.out (outNeg)
);

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	in = 1'b0;
	#10
	rst_n = 1'b1;
	#10;
	#50
	in = 1'b1;
	#50
	in = 1'b0;
	#50
	$stop();

end

always #5 clk = ~clk;

endmodule