/*
	// global I/O
	input logic clk,
	input logic rst_n,
	
	// parameters
	input logic [6:0] a_seg_cnt, // a_heigt / N (N = 2 in this case)
	input logic [6:0] w_seg_cnt, // w_width / N (N = 2 in this case)
	input logic	[7:0] seg_length, // = a_width = w_height
	
	// project-global state indicator
	input logic data_load_done,
	
	output logic calc_done,
	output logic arr_ctrl_working,
	
	output logic [7:0] ram_a0_addr,
	output logic [7:0] ram_a1_addr,
	output logic [7:0] ram_w0_addr,
	output logic [7:0] ram_w1_addr,
	
	output logic [10:0] ram_c_addr[`N-1:0][`N-1:0],
	
	output logic ram_c_wren[`N-1:0][`N-1:0],
	
	output logic ram_a0_rden,
	output logic ram_a1_rden,
	output logic ram_w0_rden,
	output logic ram_w1_rden,
	
	// MAC ctrl signal
	output logic[`N-1:0][`N-1:0] en_mult_all,
	output logic[`N-1:0][`N-1:0] clr_mult_all,
	output logic[`N-1:0][`N-1:0] en_accum_all,
	output logic[`N-1:0][`N-1:0] clr_accum_all
*/
// counter wires
// A "seg" is a strip of data
reg[7:0] a_seg_counter, w_seg_counter;
logic a_seg_counter_rst, a_seg_counter_inc;
logic w_seg_counter_rst, w_seg_counter_inc;
reg seg_inc;	// indicate one seg completed calc

reg[7:0] seg_length_counter;
logic seg_length_counter_rst, seg_length_counter_inc;

reg[7:0] stall_counter;
logic stall_counter_rst, stall_counter_inc;

localparam stall_count_target = `ADDER_DELAY + `MULT_DELAY - 2;

reg read_mem;	// reading from mem A and mem W

// delay read_mem signal by one cycle, 
// because data need one cycle to be read
dff_1b read_delay_dff(
	.d(read_mem),
	.clk(clk),
	.rst_n(rst_n),
	.q(data_valid)
);

// FSM related
typedef enum reg[4:0] {
	IDLE,	// do nothing
	CALC, 	// load data in MAC
	STALL,	// wait MAC to finish
	STR1,	// store result to mem, 1st diagonal line
	STR2,	// store result to mem, 2nd diagonal line
	STR3,	// store result to mem, 3rd diagonal line
	TIDY1,	// reset accum,
	TIDY2	// begin accum, should cause bug bucause input is 0
} state_t;

state_t state, nxt_state;

// global output
assign arr_ctrl_working = (state != IDLE);

// MAC - related
logic en_mult, clr_mult;
logic en_accum, clr_accum;
logic accum_start;
assign en_mult_all = {{{en_mult},{en_mult}},{{en_mult},{en_mult}}};
assign clr_mult_all = {{{clr_mult},{clr_mult}},{{clr_mult},{clr_mult}}};
assign en_accum_all = {{{en_accum},{en_accum}},{{en_accum},{en_accum}}};
assign clr_accum_all = {{{clr_accum},{clr_accum}},{{clr_accum},{clr_accum}}};
assign accum_start_all = {{{accum_start},{accum_start}},{{accum_start},{accum_start}}};

logic ram_c_wren_00, ram_c_wren_01, ram_c_wren_10, ram_c_wren_11;