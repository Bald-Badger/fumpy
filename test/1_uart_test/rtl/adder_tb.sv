`timescale 1 ns/ 1 ns

module adder_tb ();

logic clk, rst_n, TX, RX;

parameter  CLK_FREQ = 10000000;
parameter  UART_BPS = 256000;

logic tx_done, rx_done;
logic send_data;
logic[7:0] rx_data;
logic[7:0] tx_data;

uart #(
	.CLK_FREQ(CLK_FREQ),
	.UART_BPS(UART_BPS)
)
myUART (
	//inputs
	.clk(clk),
	.rst_n(rst_n),
	.RX(RX),
	.send_data(send_data),
	.tx_data(tx_data),
	
	//outputs
	.TX(TX),
	.rx_done(rx_done),
	.tx_done(tx_done),
	.rx_data(rx_data)
);

adder #(
	.CLK_FREQ(CLK_FREQ),
	.UART_BPS(UART_BPS)
) myAdder (
	.TX(RX),
	.RX(TX),
	.clk(clk),
	.rst_n(rst_n)
);

always #5 clk = ~clk;

initial begin
	init();
	send(8'h40);
	@(posedge tx_done);
	#100;
	send(8'h40);
	@(posedge tx_done);
	#100;
	send(8'h00);
	@(posedge tx_done);
	#100;
	send(8'h00);
	@(posedge tx_done);
	#100;
	send(8'h40);
	@(posedge tx_done);
	#100;
	send(8'h80);
	@(posedge tx_done);
	#100;
	send(8'h00);
	@(posedge tx_done);
	#100;
	send(8'h00);
	@(posedge tx_done);
	@(posedge rx_done);
	@(posedge rx_done);
	@(posedge rx_done);
	@(posedge rx_done);
	#100;
	#1000;
	$stop();
end



task init; 
begin
	clk = 1'b0;
	rst_n = 1'b0;
	send_data = 1'b0;
	tx_data = 8'b0;
	#10;
	rst_n = 1'b1;
	#10;
end
endtask

task send; 
	input[7:0] data;
begin
	tx_data = data;
	send_data = 1'b1;
	#10;
	send_data = 1'b0;
end
endtask

endmodule

