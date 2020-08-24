// top module of core
`include "param.vh"

module square_mpt_test (
	//global input
	input osc_clk,				// clk from oscillator
	input but_rst_n,			// reset signal from push button				
	
	// UART
	input  RX,					// UART RX
	output TX,					// UART RX
	output RX_debug, TX_debug,	// for logic analyzer debug
	
	// Seg LED for debug
	output  reg  [5:0]  seg_dig_sel,	// seg display digit sel
    output  reg  [7:0]  seg_led_sel		// seg display segment sel
);

	parameter CLK_FREQ = `SYS_CLK_FREQ;
	parameter UART_BPS = `SYS_UART_BPS;
	
	// global define
	wire clk;					// clk signal out of PLL
								// used to adjust for max freq
	wire rst_n;					// reset signal after PLL stable
	wire locked;				// 1 if PLL is stable
	assign rst_n = but_rst_n & locked;	// reset signal after PLL stable
	logic [3:0] debug_val;		// debug value fed in led seg
	assign TX_debug = TX;
	assign RX_debug = RX;

	// UART define
	wire 		uart_tx_done;
	wire		uart_rx_done, uart_rx_done_raw;
	wire		uart_send_data;
	reg[7:0]	uart_rx_data;
	logic[7:0]	uart_tx_data;

	wire [31:0] fp_data;

	// RAM wire define
	wire [7:0] ram_w0_addr, ram_w1_addr;	// address wire
	wire [7:0] ram_a0_addr, ram_a1_addr;
	wire [10:0] ram_c_addr[`N-1:0][`N-1:0];


	wire [31:0] ram_w0_data_out, ram_w1_data_out;
	wire [31:0] ram_a0_data_out, ram_a1_data_out;	// data out
	wire [31:0] ram_c_data_out[`N-1:0][`N-1:0];

	wire ram_w0_rden, ram_w1_rden;
	wire ram_a0_rden, ram_a1_rden;	// read enable
	wire ram_c_rden[`N-1:0][`N-1:0];

	wire ram_w0_wren, ram_w1_wren;
	wire ram_a0_wren, ram_a1_wren;	// write enable
	wire ram_c_wren[`N-1:0][`N-1:0];
	
	// data wire define
	wire[31:0]	a_in	[`N-1:0];			// a input
	wire[31:0]	w_in	[`N-1:0];			// b (weight) input
	wire[31:0] 	c_out	[`N-1:0][`N-1:0];	// result output from MAC
	
	// MAC ctrl wire define
	wire[`N-1:0][`N-1:0] en_mult;
	wire[`N-1:0][`N-1:0] clr_mult;
	wire[`N-1:0][`N-1:0] en_accum;
	wire[`N-1:0][`N-1:0] clr_accum;

	// PLL module
	pll myPLL (
		.areset (~but_rst_n),
		.inclk0 (osc_clk),
		.c0 (clk),
		.locked (locked)
	);


	seg_led_static seg_display (
		.clk (clk),
		.rst_n (rst_n),
		.sel (seg_dig_sel),
		.seg_led (seg_led_sel),
		.num (debug_val)
	);


	//UART module
	uart #(
		.CLK_FREQ(CLK_FREQ),
		.UART_BPS(UART_BPS)
	)
	myUART (
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

	// 地址目前用FSM的，到时候需要在FSM和arr——ctrl之间切换！！！！！！！
	// bug point 
	// ram for W0 (left column for systolic arr weight matrix)
	RAM_32b_256	ram_w0 (
		.address (ram_w0_addr),
		.data (fp_data),
		.inclock (clk),
		.rden (ram_w0_rden),
		.wren (ram_w0_wren),
		.q (ram_w0_data_out)
	);

	// ram for W1 (right column for systolic arr weight matrix)
	RAM_32b_256	ram_w1 (
		.address (ram_w1_addr),
		.data (fp_data),
		.inclock (clk),
		.rden (ram_w1_rden),
		.wren (ram_w1_wren),
		.q (ram_w1_data_out)
	);

	// ram for A0 (top row for systolic arr data matrix)
	RAM_32b_256	ram_a0 (
		.address (ram_a0_addr),
		.data (fp_data),
		.inclock (clk),
		.rden (ram_a0_rden),
		.wren (ram_a0_wren),
		.q (ram_a0_data_out)
	);

	// ram for A1 (button row for systolic arr data matrix)
	RAM_32b_256	ram_a1 (
		.address (ram_a1_addr),
		.data (fp_data),
		.inclock (clk),
		.rden (ram_a1_rden),
		.wren (ram_a1_wren),
		.q (ram_a1_data_out)
	);


	FSM fsm_core (
	// global input
	.clk			(clk),
	.rst_n			(rst_n),
	
	// signal input
	.uart_tx_done	(uart_tx_done),
	.uart_rx_done	(uart_rx_done),
	.uart_rx_data	(uart_rx_data),
	
	// signal output
	.ram_w0_addr	(ram_w0_addr),
	.ram_w1_addr	(ram_w1_addr),
	.ram_a0_addr	(ram_a0_addr),
	.ram_a1_addr	(ram_a1_addr),
	
	.ram_w0_rden	(ram_w0_rden),
	.ram_w1_rden	(ram_w1_rden),
	.ram_a0_rden	(ram_a0_rden),
	.ram_a1_rden	(ram_a1_rden),
	
	.ram_w0_wren	(ram_w0_wren),
	.ram_w1_wren	(ram_w1_wren),
	.ram_a0_wren	(ram_a0_wren),
	.ram_a1_wren	(ram_a1_wren),
	
	.uart_tx_data	(uart_tx_data),
	.uart_send_data	(uart_send_data),
	
	// data output
	.fp_data		(fp_data),
	
	// others
	.state_val		(debug_val)
	);
	
	systolic_arr sys_arr (
		.clk		(clk),
		.rst_n		(rst_n),
		
		//data input
		.a_in_raw	(a_in),
		.w_in_raw	(w_in),
		
		// data output
		.c_out		(c_out),
		
		// ctrl input
		.en_mult	(en_mult),
		.clr_mult	(clr_mult),
		.en_accum	(en_accum),
		.clr_accum	(clr_accum)
	);
	
	RAM_32b_result c00 (
		.address(ram_c_addr[0][0]),
		.clock(clk),
		.data(c_out[0][0]),
		.rden(ram_c_rden[0][0]),
		.wren(ram_c_wren[0][0]),
		.q(ram_c_data_out[0][0])
	);
	
	RAM_32b_result c01 (
		.address(ram_c_addr[0][1]),
		.clock(clk),
		.data(c_out[0][1]),
		.rden(ram_c_rden[0][1]),
		.wren(ram_c_wren[0][1]),
		.q(ram_c_data_out[0][1])
	);
	
	RAM_32b_result c10 (
		.address(ram_c_addr[1][0]),
		.clock(clk),
		.data(c_out[1][0]),
		.rden(ram_c_rden[1][0]),
		.wren(ram_c_wren[1][0]),
		.q(ram_c_data_out[1][0])
	);
	
	RAM_32b_result c11 (
		.address(ram_c_addr[1][1]),
		.clock(clk),
		.data(c_out[1][1]),
		.rden(ram_c_rden[1][1]),
		.wren(ram_c_wren[1][1]),
		.q(ram_c_data_out[1][1])
	);

endmodule
