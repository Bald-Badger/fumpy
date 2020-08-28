// top module of core
`include "param.vh"

module fumpy_top (
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
	
	// UART parameters
	parameter CLK_FREQ = `SYS_CLK_FREQ;
	parameter UART_BPS = `SYS_UART_BPS;
	
	// matrix size parameters
	logic [6:0] a_seg_cnt;		// a_heigt / N (N = 2 in this case)
	logic [6:0] w_seg_cnt;		// w_width / N (N = 2 in this case)
	logic [7:0] seg_length;		// = a_width = w_height
	
	// global state contol wire
	logic data_load_done;	// data done loading from FSM to RAM A/W
	logic calc_done;		// systolic arr done calc
	logic data_response_done;// data done sending from FSM to upper
	
	logic fsm_working, arr_ctrl_working;
	
	// global define
	wire clk;					// clk signal out of PLL
								// used to adjust for max freq
	wire rst_n;					// reset signal after PLL stable
	wire locked;				// 1 if PLL is stable
	assign rst_n = (but_rst_n & locked) && (!data_response_done);	// reset signal after PLL stable
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
	
	// RAM wire defines
	// top addr wire (before mux)
	wire [7:0] ram_w0_addr, ram_w1_addr;
	wire [7:0] ram_a0_addr, ram_a1_addr;
	wire [`C-1:0] ram_c_addr;
	
	// from FSM module
	wire [7:0] ram_w0_addr_fsm, ram_w1_addr_fsm;
	wire [7:0] ram_a0_addr_fsm, ram_a1_addr_fsm;
	wire [`C-1:0] ram_c_addr_fsm;
	
	// from systolic arr conrtol
	wire [7:0] ram_w0_addr_arr, ram_w1_addr_arr;
	wire [7:0] ram_a0_addr_arr, ram_a1_addr_arr;
	wire [`C-1:0] ram_c_addr_arr;
	
	// mux addr based on working state
	assign ram_w0_addr =	(fsm_working) ? ram_w0_addr_fsm :
							(arr_ctrl_working) ? ram_w0_addr_arr :
							0;
							
	assign ram_w1_addr =	(fsm_working) ? ram_w1_addr_fsm :
							(arr_ctrl_working) ? ram_w1_addr_arr :
							0;
							
	assign ram_a0_addr =	(fsm_working) ? ram_a0_addr_fsm :
							(arr_ctrl_working) ? ram_a0_addr_arr :
							0;
							
	assign ram_a1_addr =	(fsm_working) ? ram_a1_addr_fsm :
							(arr_ctrl_working) ? ram_a1_addr_arr :
							0;
							
	assign ram_c_addr  = 	(fsm_working) ? ram_c_addr_fsm :
							(arr_ctrl_working) ? ram_c_addr_arr :
							ram_c_addr_fsm;	// default to FSM read
	
	// RAM data wire input 
	wire[31:0]	ram_a_data_in	[`N-1:0];			// a input
	wire[31:0]	ram_w_data_in	[`N-1:0];			// b (weight) input
	wire[31:0] 	ram_c_data_in	[`N-1:0][`N-1:0];	// result output from MAC
	
	// RAM data wire out 
	wire[31:0]	ram_a_data_out	[`N-1:0];			// a input
	wire[31:0]	ram_w_data_out	[`N-1:0];			// b (weight) input
	wire[31:0] 	ram_c_data_out	[`N-1:0][`N-1:0];
	
	wire data_valid;				// data in sys_arr is valid
	// W/R enable
	wire ram_w0_rden, ram_w1_rden;
	wire ram_a0_rden, ram_a1_rden;	// read enable
	wire [`N-1:0][`N-1:0] ram_c_rden;

	wire ram_w0_wren, ram_w1_wren;
	wire ram_a0_wren, ram_a1_wren;	// write enable
	wire [`N-1:0][`N-1:0] ram_c_wren;
	
	// MAC ctrl wire define
	wire[`N-1:0][`N-1:0] en_mult;
	wire[`N-1:0][`N-1:0] clr_mult;
	wire[`N-1:0][`N-1:0] en_accum;
	wire[`N-1:0][`N-1:0] clr_accum;
	wire[`N-1:0][`N-1:0] accum_start;
	
	// PLL module
	pll myPLL (
		.areset (~but_rst_n),
		.inclk0 (osc_clk),
		.c0 	(clk),
		.locked (locked)
	);
	
	
	// seg led for debug purpose
	seg_led_static seg_display (
		.clk 		(clk),
		.rst_n 		(rst_n),
		.sel 		(seg_dig_sel),
		.seg_led	(seg_led_sel),
		.num 		(debug_val)
	);
	
	
	//UART module
	uart #(
		.CLK_FREQ(CLK_FREQ),
		.UART_BPS(UART_BPS)
	)
	myUART (
		//inputs
		.clk		(clk),
		.rst_n		(rst_n),
		.RX			(RX),
		.send_data	(uart_send_data),
		.tx_data	(uart_tx_data),
		
		//outputs
		.TX			(TX),
		.rx_done	(uart_rx_done_raw),
		.tx_done	(uart_tx_done),
		.rx_data	(uart_rx_data)
	);
	
	//output rx_done only one cycle
	posedgeDect uart_rx_posedgeDect (
		.clk	(clk),
		.rst_n	(rst_n),
		.in		(uart_rx_done_raw),
		.out	(uart_rx_done)
	);
	
	
	RAM_32b_256	ram_a0 (
		.address 	(ram_a0_addr),
		.data 		(fp_data),
		.inclock 	(clk),
		.rden 		(ram_a0_rden),
		.wren 		(ram_a0_wren),
		.q 			(ram_a_data_out[0])
	);
	
	RAM_32b_256	ram_a1 (
		.address 	(ram_a1_addr),
		.data 		(fp_data),
		.inclock 	(clk),
		.rden 		(ram_a1_rden),
		.wren 		(ram_a1_wren),
		.q 			(ram_a_data_out[1])
	);
	
	RAM_32b_256	ram_w0 (
		.address	(ram_w0_addr),
		.data 		(fp_data),
		.inclock 	(clk),
		.rden 		(ram_w0_rden),
		.wren 		(ram_w0_wren),
		.q 			(ram_w_data_out[0])
	);
	
	RAM_32b_256	ram_w1 (
		.address 	(ram_w1_addr),
		.data 		(fp_data),
		.inclock 	(clk),
		.rden 		(ram_w1_rden),
		.wren 		(ram_w1_wren),
		.q 			(ram_w_data_out[1])
	);
	
	
	/*
	FSM module is in chage of:
	1. loading from PC to RAM A/W
	2. loading from RAM C to PC
	*/
	FSM fsm_core (
		// global input
		.clk			(clk),
		.rst_n			(rst_n),
		
		// global state indicator
		.data_load_done (data_load_done),
		.fsm_working	(fsm_working),
		.calc_done		(calc_done),
		.data_response_done(data_response_done),
		
		// signal input
		.uart_tx_done	(uart_tx_done),
		.uart_rx_done	(uart_rx_done),
		.uart_rx_data	(uart_rx_data),
		
		// signal output
		.ram_w0_addr	(ram_w0_addr_fsm),
		.ram_w1_addr	(ram_w1_addr_fsm),
		.ram_a0_addr	(ram_a0_addr_fsm),
		.ram_a1_addr	(ram_a1_addr_fsm),
		
		.ram_c_addr		(ram_c_addr_fsm),
		.ram_c_rden_all	(ram_c_rden),
		
		.ram_w0_wren	(ram_w0_wren),
		.ram_w1_wren	(ram_w1_wren),
		.ram_a0_wren	(ram_a0_wren),
		.ram_a1_wren	(ram_a1_wren),
		
		.uart_tx_data	(uart_tx_data),
		.uart_send_data	(uart_send_data),
		
		// data I/O
		.fp_data		(fp_data),
		.ram_c_data		(ram_c_data_out),
		
		// debug val
		.state_val		(debug_val),
		
		.a_seg_cnt		(a_seg_cnt),
		.w_seg_cnt		(w_seg_cnt),
		.seg_length		(seg_length)
	);
	
	
	systolic_arr sys_arr (
		.clk		(clk),
		.rst_n		(rst_n),
		
		//data input
		.a_in_raw	(ram_a_data_out),
		.w_in_raw	(ram_w_data_out),
		.data_valid (data_valid),
		
		// data output
		.c_out		(ram_c_data_in),
		
		// ctrl input
		.en_mult	(en_mult),
		.clr_mult	(clr_mult),
		.en_accum	(en_accum),
		.clr_accum	(clr_accum),
		.accum_start(accum_start)
	);
	
	
	systolic_arr_ctrl sys_arr_ctrl (
		// global I/O
		.clk			(clk),
		.rst_n			(rst_n),
		
		// parameters
		.a_seg_cnt		(a_seg_cnt),
		.w_seg_cnt		(w_seg_cnt),
		.seg_length		(seg_length),
		
		// project-global state indicator
		.data_load_done	(data_load_done),
		.calc_done		(calc_done),
		.arr_ctrl_working(arr_ctrl_working),
		
		// RAM
		.ram_a0_addr	(ram_a0_addr_arr),
		.ram_a1_addr	(ram_a1_addr_arr),
		.ram_w0_addr	(ram_w0_addr_arr),
		.ram_w1_addr	(ram_w1_addr_arr),
		
		.ram_c_addr		(ram_c_addr_arr),
		
		.ram_c_wren		(ram_c_wren),
		
		.ram_a0_rden	(ram_a0_rden),
		.ram_a1_rden	(ram_a1_rden),
		.ram_w0_rden	(ram_w0_rden),
		.ram_w1_rden	(ram_w1_rden),
		
		.data_valid		(data_valid),
		.en_mult_all	(en_mult),
		.clr_mult_all	(clr_mult),
		.en_accum_all	(en_accum),
		.clr_accum_all	(clr_accum),
		.accum_start_all(accum_start)
	);
	
	RAM_32b_result c00 (
		.address	(ram_c_addr),
		.clock		(clk),
		.data		(ram_c_data_in[0][0]),
		.rden		(ram_c_rden[0][0]),
		.wren		(ram_c_wren[0][0]),
		.q			(ram_c_data_out[0][0])
	);
	
	RAM_32b_result c01 (
		.address	(ram_c_addr),
		.clock		(clk),
		.data		(ram_c_data_in[0][1]),
		.rden		(ram_c_rden[0][1]),
		.wren		(ram_c_wren[0][1]),
		.q			(ram_c_data_out[0][1])
	);
	
	RAM_32b_result c10 (
		.address	(ram_c_addr),
		.clock		(clk),
		.data		(ram_c_data_in[1][0]),
		.rden		(ram_c_rden[1][0]),
		.wren		(ram_c_wren[1][0]),
		.q			(ram_c_data_out[1][0])
	);
	
	RAM_32b_result c11 (
		.address	(ram_c_addr),
		.clock		(clk),
		.data		(ram_c_data_in[1][1]),
		.rden		(ram_c_rden[1][1]),
		.wren		(ram_c_wren[1][1]),
		.q			(ram_c_data_out[1][1])
	);

endmodule