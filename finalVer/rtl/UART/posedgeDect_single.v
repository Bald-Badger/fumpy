/*
	posedge detector, golden in sync condition
	1 clk delay if sync
*/

module posedgeDect_single (
	input clk, rst_n,
	input in,
	output out
);

reg dff1;

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		dff1 <= 1'b0;
	end else begin
		dff1 <= in;
	end
end

assign out = in & (!dff1);

endmodule