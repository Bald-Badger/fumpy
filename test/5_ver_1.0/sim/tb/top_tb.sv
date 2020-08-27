`timescale 1ns / 1ns
`include "../../rtl/param.vh"
module top_tb();

// wire define
logic clk;
logic rst_n;
logic RX, TX;

// UART define
logic 		uart_tx_done;
logic		uart_rx_done, uart_rx_done_raw;
logic		uart_send_data;
reg[7:0]	uart_rx_data;
logic[7:0]	uart_tx_data;

shortreal	myFP;
logic[31:0] tempFP;


square_mpt_test top (
	.osc_clk 	(clk),
	.but_rst_n 	(rst_n),
	.RX			(TX),
	.TX			(RX)
);


//UART module
uart #(
	.CLK_FREQ(`SYS_CLK_FREQ),
	.UART_BPS(`SYS_UART_BPS)
)
myUART_up (
	//inputs
	.clk(clk),
	.rst_n(rst_n),
	.RX(RX),
	.send_data(uart_send_data),
	.tx_data(uart_tx_data),
	
	//outputs
	.TX(TX),
	.rx_done(uart_rx_done_raw),
	.tx_done(uart_tx_done),
	.rx_data(uart_rx_data)
);

//output rx_done only one cycle
posedgeDect uart_rx_posedgeDect (
	.clk(clk),
	.rst_n(rst_n),
	.in(uart_rx_done_raw),
	.out(uart_rx_done)
);


initial begin
rst_n = 1;
clk = 1;
uart_send_data = 0;
uart_tx_data = 0;
myFP = 0;
tempFP = 0;

init();
//send_byte(`START);
send_byte(`MATRIX_MULT);
send_byte(8'd2);	// a_height
send_byte(8'd2);	// a_width
send_byte(8'd2);	// h_height
send_byte(8'd2);	// h_width
wait_ack();			// wait fo nr ACK dat

// send FP, fp1
myFP = 1.0e0;
send_fp(myFP);
myFP = 2.0e0;
send_fp(myFP);
myFP = 3.0e0;
send_fp(myFP);
myFP = 4.0e0;
send_fp(myFP);


// send FP2
myFP = 5.0e0;
send_fp(myFP);
myFP = 6.0e0;
send_fp(myFP);
myFP = 7.0e0;
send_fp(myFP);
myFP = 8.0e0;
send_fp(myFP);

/*
myFP = 5.0e0;
send_fp(myFP);
myFP = 6.0e0;
send_fp(myFP);
myFP = 7.0e0;
send_fp(myFP);
myFP = 8.0e0;
send_fp(myFP);
*/
/*
myFP = 9.0e0;
send_fp(myFP);
myFP = 10.0e0;
send_fp(myFP);
myFP = 11.0e0;
send_fp(myFP);
myFP = 12.0e0;
send_fp(myFP);
myFP = 13.0e0;
send_fp(myFP);
myFP = 14.0e0;
send_fp(myFP);
myFP = 15.0e0;
send_fp(myFP);
myFP = 16.0e0;
send_fp(myFP);
*/

/*
myFP = 17.0e0;
send_fp(myFP);
myFP = 18.0e0;
send_fp(myFP);
myFP = 19.0e0;
send_fp(myFP);
myFP = 20.0e0;
send_fp(myFP);
myFP = 21.0e0;
send_fp(myFP);
myFP = 22.0e0;
send_fp(myFP);
myFP = 23.0e0;
send_fp(myFP);
myFP = 24.0e0;
send_fp(myFP);
*/

// wait a while
repeat (10000) @(posedge clk);
$stop();
end


task init;
begin
	repeat (100) @(posedge clk);
	@ (negedge clk);
	rst_n = 0;
	@ (negedge clk);
	rst_n = 1;
	repeat (100) @(posedge clk);
end
endtask

task send_byte;
	input logic[7:0] byte_data;
begin
	uart_tx_data = byte_data;
	@(posedge clk);
	uart_send_data = 1; 
	@(posedge clk);
	uart_send_data = 0;
	@(posedge uart_tx_done);
	repeat (2) @(posedge clk);
end
endtask

task send_fp;
	input shortreal fp_data;
begin
	tempFP = $shortrealtobits(fp_data);
	send_byte (tempFP[31:24]);
	send_byte (tempFP[23:16]);
	send_byte (tempFP[15:8]);
	send_byte (tempFP[7:0]);
end
endtask

task wait_ack;
begin
	@(posedge uart_rx_done);
	repeat (2) @(posedge clk);
end
endtask


always #5 begin
	clk = ~clk;
end

endmodule