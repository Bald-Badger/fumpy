`include "../param.vh"

module systolic_arr_ctrl (
	// global input
	input clk,
	input rst_n,
	
	// input ram ctrl signal
	output logic [7:0] ram_w0_addr,
	output logic [7:0] ram_w1_addr,
	output logic [7:0] ram_a0_addr,
	output logic [7:0] ram_a1_addr,
	
	output wire ram_w0_rden,
	output wire ram_w1_rden,
	output wire ram_a0_rden,
	output wire ram_a1_rden,
	
	// output ram ctrl signal
	
	// MAC ctrl signal
	output wire[`N-1:0][`N-1:0] en_mult,
	output wire[`N-1:0][`N-1:0] clr_mult,
	output wire[`N-1:0][`N-1:0] en_accum,
	output wire[`N-1:0][`N-1:0] clr_accum
	
	
);


	typedef enum reg[4:0] {
		IDLE, CALC, STALL
	} state_t;
	
	state_t state, nxt_state;
	
	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
endmodule
