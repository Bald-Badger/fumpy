`include "../param.vh"

module systolic_arr_ctrl (
	// global I/O
	input clk,
	input rst_n,
	
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
	
	output wire ram_a0_rden,
	output wire ram_a1_rden,
	output wire ram_w0_rden,
	output wire ram_w1_rden,
	
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
			
	always_comb begin
		//default values
		nxt_state = IDLE;
		
		case (state)
			IDLE: begin
				if (data_load_done) begin
					nxt_state = CALC;
				end else begin
					nxt_state = IDLE;
				end
			end
			
			CALC: begin
				
			end
			
			STALL: begin
			
			end
		endcase
	end
	
endmodule
