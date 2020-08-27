`include "../param.vh"

module systolic_arr_ctrl (
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
	
	output logic [`C-1:0] ram_c_addr[`N-1:0][`N-1:0],
	
	output logic ram_c_wren[`N-1:0][`N-1:0],
	
	output logic ram_a0_rden,
	output logic ram_a1_rden,
	output logic ram_w0_rden,
	output logic ram_w1_rden,
	
	// MAC ctrl signal
	output logic[`N-1:0][`N-1:0] en_mult_all,
	output logic[`N-1:0][`N-1:0] clr_mult_all,
	output logic[`N-1:0][`N-1:0] en_accum_all,
	output logic[`N-1:0][`N-1:0] clr_accum_all,
	output logic[`N-1:0][`N-1:0] accum_start_all
);

	`include "systolic_arr_ctrl_wire_define.sv"
	`include "systolic_arr_ctrl_counter_update.sv"
	`include "systolic_arr_ctrl_fsm_body.sv"
	`include "systolic_arr_ctrl_ram_ctrl.sv"
	
endmodule
