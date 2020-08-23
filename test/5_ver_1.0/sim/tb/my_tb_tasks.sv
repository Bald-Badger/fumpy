/* auto-fill
wire 		uart_tx_done;
wire		uart_rx_done, uart_rx_done_raw;
wire		uart_send_data;
reg[7:0]	uart_rx_data;
logic[7:0]	uart_tx_data;
*/

/*
task ;
begin

end
endtask
*/

task init;
begin
	repeat (2) @(posedge clk);
	@ (negedge clk);
	rst_n = 0;
	@ (negedge clk);
	rst_n = 1;
	repeat (2) @(posedge clk);
end
endtask

task send_byte();
	input logic[7:0] byte_data;
	uart_tx_data = byte_data;
	@(posedge clk);
	uart_tx_data = 1;
	@(posedge clk);
	uart_tx_data = 0;
	@(posedge uart_tx_done);
begin
	
end
endtask
