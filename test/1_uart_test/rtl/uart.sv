module uart(
	input clk,
	input rst_n,
	input RX,
	input send_data,
	input[7:0] tx_data,
	
	output TX,
	output rx_done,
	output tx_done,
	output[7:0] rx_data
);

//parameter define
parameter  CLK_FREQ = 50000000;
parameter  UART_BPS = 115200;

uart_RX #(
	.CLK_FREQ(CLK_FREQ),
	.UART_BPS(UART_BPS)
)
myRX (
	.clk(clk),
	.rst_n(rst_n),
	.RX(RX),
	.uart_done(rx_done),
	.uart_data(rx_data)
);

uart_TX #(
	.CLK_FREQ(CLK_FREQ),
	.UART_BPS(UART_BPS)
)
myTX (
	.clk(clk),
	.rst_n(rst_n),
	.uart_en(send_data),
	.uart_din(tx_data),
	.TX(TX),
	.tx_done(tx_done)
);

endmodule
