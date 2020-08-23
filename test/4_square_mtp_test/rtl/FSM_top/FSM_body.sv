	// Infer state flop next
	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	
	// FSM for top layer
	always_comb begin
		// Default assignments
		nxt_state 				= IDLE;
		
		a_height_load 			= 1'b0;
		a_width_load 			= 1'b0;
		w_height_load 			= 1'b0;
		w_width_load			= 1'b0;
		
		uart_tx_data_load_ack1	= 1'b0;
		uart_tx_data_load_ack2 	= 1'b0;
		uart_tx_data_load_ack3 	= 1'b0;
		
		uart_send_data 			= 1'b0;
		
		matrix_a_rcv_start 		= 1'b0;
		matrix_w_rcv_start 		= 1'b0;
		calc_start 				= 1'b0;
		matrix_3_snd_start 		= 1'b0;
		
		fp_reg_clr				= 1'b0;
		
		case (state)
		
			IDLE: begin
				if (uart_rx_done) begin;
					nxt_state = PHRASE;
				end else begin
					nxt_state = IDLE;
				end
			end
			
			PHRASE: begin
				if (uart_rx_data == `MATRIX_MULT) begin
					nxt_state = CMD_MUL;
				end else begin
					nxt_state = IDLE;
				end
			end
			
			// as rx done, a_height data is available
			CMD_MUL: begin
				if (uart_rx_done) begin
					nxt_state = STR_A_H;
					a_height_load = 1'b1;
				end else begin
					nxt_state = CMD_MUL;
				end
			end
			
			// as rx done, a_width data is available
			STR_A_H: begin
				if (uart_rx_done) begin
					nxt_state = STR_A_W;
					a_width_load = 1'b1;
				end else begin
					nxt_state = STR_A_H;
				end
			end
			
			// as rx done, w_height data is available
			STR_A_W: begin
				if (uart_rx_done) begin
					nxt_state = STR_W_H;
					w_height_load = 1'b1;
				end else begin
					nxt_state = STR_A_W;
				end
			end
			
			// as rx done, w_width data is available
			STR_W_H: begin
				if (uart_rx_done) begin
					nxt_state = STR_W_W;
					w_width_load = 1'b1;
				end else begin
					nxt_state = STR_W_H;
				end
			end
			
			// W_width already loaded in the first cycle in this stage
			// at this time, send back ack signal
			STR_W_W: begin
				nxt_state = ACK1;
				uart_tx_data_load_ack1 = 1'b1;
				uart_send_data = 1'b1;
			end
			
			ACK1: begin
				if (uart_tx_done) begin
					nxt_state = MATRIX_1_RCV_INIT;
					// also clear the reg that store 4 byte of FP
					fp_reg_clr = 1'b1;
				end else begin
					nxt_state = ACK1;
				end
			end
			
			// trigger the sub-FSM init its value
			// based on the UART command input
			MATRIX_1_RCV_INIT: begin
				nxt_state = MATRIX_1_RCV;
				matrix_a_rcv_start = 1'b1;
			end
			
			// wait for first matrix done transmit
			MATRIX_1_RCV: begin
				if (matrix_a_rcv_done) begin
					nxt_state = ACK2;
					uart_tx_data_load_ack2 = 1'b1;
					uart_send_data = 1'b1;
				end else begin
					nxt_state = MATRIX_1_RCV;
				end
			end
			
			ACK2: begin
				if (uart_tx_done) begin
					nxt_state = MATRIX_2_RCV_INIT;
					fp_reg_clr = 1'b1;
				end else begin
					nxt_state = ACK2;
				end
			end
					
			// trigger the sub-FSM init its value
			// based on the UART command input
			MATRIX_2_RCV_INIT: begin
				nxt_state = MATRIX_2_RCV;
				matrix_w_rcv_start = 1'b1;
			end
			
			// wait for second matrix done transmit
			MATRIX_2_RCV: begin
				if (matrix_w_rcv_done) begin
					nxt_state = ACK3;
					uart_tx_data_load_ack3 = 1'b1;
					uart_send_data = 1'b1;
				end else begin
					nxt_state = MATRIX_2_RCV;
				end
			end
			
			ACK3: begin
				if (uart_tx_done) begin
					nxt_state = CALC;
				end else begin
					nxt_state = ACK3;
				end
			end
			
			CALC: begin
				if (calc_done) begin
					nxt_state = MATRIX_3_SND;
				end else begin
					nxt_state = CALC;
				end
			end
			
			MATRIX_3_SND: begin
				if (matrix_3_snd_done) begin
					nxt_state = IDLE;
				end else begin
					nxt_state = MATRIX_3_SND;
				end
			end
			
			default: begin
				nxt_state = IDLE;
			end
		endcase
	end
	

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			state_rcv1 <= IDLE_RCV1;
		else
			state_rcv1 <= nxt_state_rcv1;
	
	// FSM body
	always_comb begin
		// default values
		nxt_state_rcv1 = IDLE_RCV1;
		matrix_a_rcv_done = 1'b0;
		init_matrix_a_param = 1'b0;
		
		a_width_counter_rst = 1'b0;
		//a_width_counter_inc = 1'b0; updated in elsewhere
		a_seg_counter_inc = 1'b0;
		a_seg_counter_rst = 1'b0;
		
		case (state_rcv1)
			IDLE_RCV1 : begin
				if (matrix_a_rcv_start) begin
					nxt_state_rcv1 = RCV1_RAM0;
				end else begin
					nxt_state_rcv1 = IDLE_RCV1;
					init_matrix_a_param = 1'b1;
				end
			end
			
			RCV1_RAM0 : begin

				// if we finished loading current segment
				// then load to other 'bank' for alignment
				// and clear counter
				if (a_width_counter == a_width) begin
					nxt_state_rcv1 = RCV1_RAM1;
					a_width_counter_rst = 1'b1;
					a_seg_counter_inc = 1'b1;
				end else begin
					nxt_state_rcv1 = RCV1_RAM0;
				end
			end
			
			// will encounter bug if change parameter N
			RCV1_RAM1 : begin
				// if we finished loading current segment
				if (a_width_counter == a_width) begin
					// if we transmitted seg count = height(a)/N
					// (which in this case, N = 2, so discard last dig for /2)
					// then go to idle, and report finish to main FSM
					if (a_seg_counter == a_height[7:1]) begin
						nxt_state_rcv1 = IDLE_RCV1;
						matrix_a_rcv_done = 1'b1;
						a_seg_counter_rst = 1'b1;
					// haven`t finish TXing, go back to other bank for alignment
					end else begin	
						nxt_state_rcv1 = RCV1_RAM0;
						a_width_counter_rst = 1'b1;
					end
				end else begin
					nxt_state_rcv1 = RCV1_RAM1;
				end
			end
			
			default: begin
				nxt_state_rcv1 = IDLE_RCV1;
			end
		endcase
	end
	
	/////////////////////////////////////////////

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			state_rcv2 <= IDLE_RCV2;
		else
			state_rcv2 <= nxt_state_rcv2;
	
	always_comb begin
		// default values
		nxt_state_rcv2 = IDLE_RCV2;
		init_matrix_w_param = 1'b0;
		matrix_w_rcv_done = 1'b0;
		w_height_counter_inc = 1'b0;
		
		case (state_rcv2)
			IDLE_RCV2: begin
				if (matrix_w_rcv_start) begin
					nxt_state_rcv2 = RCV2_RAM0;
					init_matrix_w_param = 1'b1;
				end else begin
					nxt_state_rcv2 = IDLE_RCV2;
				end
			end
			
			RCV2_RAM0: begin
				if (w_seg_counter == w_height) begin
					nxt_state_rcv2 = IDLE_RCV2;
					matrix_w_rcv_done = 1'b1;
				end else if (fp_ready) begin
					nxt_state_rcv2 = RCV2_RAM1;
				end else begin
					nxt_state_rcv2 = RCV2_RAM0;
				end
			end
			
			// will encounter bug if change parameter N
			RCV2_RAM1: begin
				//if (w_seg_counter == (w_width >> 1)) begin
				//	nxt_state_rcv2 = IDLE_RCV2;
				//	matrix_w_rcv_done = 1'b1;
				//  end else 
				if (fp_ready) begin
					nxt_state_rcv2 = RCV2_RAM0;
					w_height_counter_inc = 1'b1;
				end else begin
					nxt_state_rcv2 = RCV2_RAM1;
				end
			end
			
			default: begin
				nxt_state_rcv2 = IDLE_RCV2;
			end
		endcase
	end	
