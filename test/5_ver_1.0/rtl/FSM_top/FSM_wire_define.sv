// major wire/reg/logic defines
// and some immdeiate assignments

// parameters
	reg[7:0]	a_height, a_width;
	reg[7:0] 	w_height, w_width;
	
// states
	// define top layer states
	typedef enum reg[4:0] {
		// First steps
		IDLE, PHRASE,
		// matrix mul
		CMD_MUL,
		// store height and width of Matrix A and W
		// note the the value stored is half of actual size
		STR_A_H, STR_A_W,	
		STR_W_H, STR_W_W,
		ACK1,
		MATRIX_1_RCV_INIT,
		MATRIX_1_RCV,
		ACK2,
		MATRIX_2_RCV_INIT,
		MATRIX_2_RCV,
		ACK3,
		CALC,
		MATRIX_3_SND	
	} state_t;
	
	state_t state, nxt_state;
	
	// sub-FSM states
	// FSM for receiving first matrix
	// define state machine for reveiving first matrix
	typedef enum logic[2:0] {
		IDLE_RCV1,
		RCV1_RAM0,
		RCV1_RAM1
	} state_t_rcv1;
	
	state_t_rcv1 state_rcv1, nxt_state_rcv1;
	
	// FSM for receiving second matrix
	// define state machine for reveiving second matrix
	typedef enum logic[2:0] {
		IDLE_RCV2,
		RCV2_RAM0,
		RCV2_RAM1
	} state_t_rcv2;
	state_t_rcv2 state_rcv2, nxt_state_rcv2;
	
	
	// FSM for sending third matrix
	typedef enum logic[2:0] {
		IDLE_SND,
		SND_R0,
		SND_R1,
		SND_R2,
		SND_R3
	} state_t_snd;
	state_t_snd state_snd, nxt_state_snd;
	
	
	// select from ack or result
	logic uart_send_data_rcv;
	// for timing
	logic uart_send_data_rsp_raw; 	// from FSM
	logic uart_send_data_rsp_r1;	// delay one cycle from raw
	logic uart_send_data_rsp_r2;	// delay one cycle from raw
	logic uart_send_data_rsp_r3;	// delay one cycle from raw
	logic uart_send_data_rsp;		// delay one cycle from raw
	dff_1b uart_data_sed_reg1 (
		.d(uart_send_data_rsp_raw),
		.clk(clk),
		.rst_n(rst_n),
		.q(uart_send_data_rsp_r1)
	);
	dff_1b uart_data_sed_reg2 (
		.d(uart_send_data_rsp_r1),
		.clk(clk),
		.rst_n(rst_n),
		.q(uart_send_data_rsp_r2)
	);
	dff_1b uart_data_sed_reg3 (
		.d(uart_send_data_rsp_r2),
		.clk(clk),
		.rst_n(rst_n),
		.q(uart_send_data_rsp_r3)
	);
	dff_1b uart_data_sed_reg4 (
		.d(uart_send_data_rsp_r3),
		.clk(clk),
		.rst_n(rst_n),
		.q(uart_send_data_rsp)
	);
	assign uart_send_data = (uart_send_data_rcv || (uart_send_data_rsp && (state_snd != IDLE_SND)));
	
// load from UART to reg
	reg 		a_height_load, a_width_load;
	reg 		w_height_load, w_width_load;

// load from reg to UART
	reg 		uart_tx_data_load_ack1,
				uart_tx_data_load_ack2,
				uart_tx_data_load_ack3;

// load from RAM to uart
	logic uart_tx_data_load_ram;
	assign uart_tx_data_load_ram = (state_snd != IDLE_SND);

// reg stores FP data
// every 4 byte is packed in a FP reg
	reg[31:0] fp_reg;	
	reg fp_reg_clr;
	
	// bug when changing parameter N
	// up for 1 cycle when data in fp reg is vali
	logic fp_ready;
	
// all counters & counter controller

	// count every four byte arrive
	// note I used 3-bit counter insted of 2-bit 
	// is to avoid writing the '0th' FP in memory
	// when counter have value of 0 after reset
	// using 3bit can let me only write to mem
	//	when counter = 4 insted of 0 
	reg[2:0] four_byte_counter;
	
	// matrix A counters
		// count from 0 to a_width, when count to end, 
		// change state and ram writing into
		// to ensure data alignment for matrix mulp
		reg[7:0] a_width_counter;
		reg a_width_counter_rst;
		logic a_width_counter_inc;
		assign a_width_counter_inc = (ram_a0_wren || ram_a1_wren);
		
		// count the number of data seg
		// left to write to memory
		// !!! total seg count = height(a)/2 !!!
		// when hit end, means all data for
		// a finished storing in memory
		reg[7:0] a_seg_counter;
		reg a_seg_counter_rst;
		reg a_seg_counter_inc;

	
	// matrix W counters
		// varible to get around bug insted of fixing it
		wire ram_w_update_ok;
		reg ram_w_update_ok_reg_1,ram_w_update_ok_reg_2;
		wire ram_w_update_ok_wire_1;
		assign ram_w_update_ok_wire_1 = ram_w_update_ok_reg_1;
		assign ram_w_update_ok = ram_w_update_ok_reg_2;
		always_ff @(posedge clk or negedge rst_n) begin
			if (!rst_n) begin
				ram_w_update_ok_reg_1 <= 1'b0;
				ram_w_update_ok_reg_2 <= 1'b0;
			end else begin
				ram_w_update_ok_reg_1 <= (fp_ready && (nxt_state_rcv2 == RCV2_RAM0));
				ram_w_update_ok_reg_2 <= ram_w_update_ok_wire_1;
			end
		end
		
		reg[7:0] w_height_counter;
		logic w_height_counter_rst;
		/*
		assign w_height_counter_rst =	ram_w_update_ok && 
										(w_height_counter == (w_width >> 1));
		*/
		logic w_height_counter_inc;

		// increment height counter
		// updated in FSM
		reg[7:0] w_seg_counter;	
		reg w_seg_counter_rst;
		logic w_seg_counter_inc;

		// get around bug
		// parameter bug exist
		// rewrite
		/*
		assign	w_seg_counter_inc = (w_height_counter == ((w_width >> 1) - 1)) &&
				(w_height_counter_inc);
		*/
		// expensive !!!, get around bug
		assign w_seg_counter_inc =	w_height_counter_inc &&
									(ram_w0_addr >= w_height * ((w_width >> 1) - 1));
			

			
	// matrix C counters
		reg[2:0] fp_byte_counter;
		logic fp_byte_counter_rst;
	
// sub-FSM begin/end indicators
	reg matrix_a_rcv_start; // MATRIX_1_RCV state
	reg matrix_w_rcv_start; // MATRIX_2_RCV state
	reg matrix_3_snd_start; // MATRIX_3_SND state
	
	reg matrix_a_rcv_done;
	reg matrix_w_rcv_done;

	reg matrix_3_snd_done;
	
	reg init_matrix_a_param;
	reg init_matrix_w_param;
	
// ram-related
	// select which slice of ram to write to
	// encountered quartus bug, de-parameter for now
	//wire[`W-1:0] ram_a_select;	
	wire[7:0] ram_a_select;
	wire[7:0] ram_w_select;
	
	wire[31:0] c_data; // one of the four input RAM data bus
	
	// inversed index to get around bug
	assign c_data =	(state_snd == SND_R0) ? ram_c_data[0][0] :
					(state_snd == SND_R1) ? ram_c_data[0][1] :
					(state_snd == SND_R2) ? ram_c_data[1][0] :
					(state_snd == SND_R3) ? ram_c_data[1][1] :
					32'b0;
	logic ram_c_rden; // updated in FSM
	assign ram_c_rden = (state_snd != IDLE_SND);
	assign ram_c_rden_all = {{{ram_c_rden},{ram_c_rden}},
							{{ram_c_rden},{ram_c_rden}}};	
							
// project-global state indicators
	assign data_load_done = ((state == ACK3)&&(nxt_state == CALC));
	assign fsm_working = ((state != IDLE)&&(state != CALC));
	assign data_response_done = ((state_snd == SND_R0) && (nxt_state_snd == IDLE_SND));
	
// project-global matrix size parameter
	assign a_seg_cnt = a_height[7:1];
	assign w_seg_cnt = w_width[7:1];
	assign seg_length = a_width;	// w_height also works

	