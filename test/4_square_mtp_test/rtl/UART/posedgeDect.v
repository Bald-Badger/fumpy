/*
	posedge detector, golden in sync condition
*/

module posedgeDect (
	input clk, rst_n,
	input in,
	output out
);

reg dff1, dff2;

always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		dff1 <= 1'b0;
		dff2 <= 1'b0;
	end else begin
		dff1 <= in;
		dff2 <= dff1;
	end
end

assign out = dff1 & (!dff2);

endmodule