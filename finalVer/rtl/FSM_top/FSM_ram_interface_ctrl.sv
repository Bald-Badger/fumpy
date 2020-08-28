// common value
	assign ram_a_select =	(state_rcv1 == RCV1_RAM0) ? `RAM_A0 :
							(state_rcv1 == RCV1_RAM1) ? `RAM_A1 :
							`RAM_A_DISABLE;
							
	assign ram_w_select =	(state_rcv2 == RCV2_RAM0) ? `RAM_W0 :
							(state_rcv2 == RCV2_RAM1) ? `RAM_W1 :
							`RAM_W_DISABLE;
							
// data interface
	assign fp_data = fp_reg;
	// used 5 insted of 4 to avoid overflow
	assign fp_ready = (four_byte_counter == 3'd5);
	

// write enable
	// matrix a0
	// write to a0 when a fp is ready
	// and choosing a0
	// and in matrix-writing stage
	assign ram_a0_wren = (ram_a_select == `RAM_A0) && fp_ready;
	
	// matrix a1
	assign ram_a1_wren = (ram_a_select == `RAM_A1) && fp_ready;
	
	// matrix w0
	assign ram_w0_wren = (ram_w_select == `RAM_W0) && fp_ready;
	
	// matrix w1
	assign ram_w1_wren = (ram_w_select == `RAM_W1) && fp_ready;
// read enable

// address

	// matrix A addr updater
	// TODO
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			ram_a0_addr <= `NULL_8B;
			ram_a1_addr <= `NULL_8B;
		end else if (init_matrix_a_param) begin;
			ram_a0_addr <= (a_width - 1);
			ram_a1_addr <= (a_width - 1);
		// when switching from ram0 to ram1, increment ptr by 2*a_width
		end else if ((state_rcv1 == RCV1_RAM0) && (nxt_state_rcv1 == RCV1_RAM1)) begin
			ram_a0_addr <= (ram_a0_addr + (a_width << 1));
			ram_a1_addr <= ram_a1_addr;
		// when switching from ram1 to ramo, increment ptr by 2*a_width
		end else if ((state_rcv1 == RCV1_RAM1) && (nxt_state_rcv1 == RCV1_RAM0)) begin
			ram_a0_addr <= ram_a0_addr;
			ram_a1_addr <= (ram_a1_addr + (a_width << 1));
		end else if (fp_ready) begin
			if (state_rcv1 == RCV1_RAM0) begin
				ram_a0_addr <= ram_a0_addr - 1;
				ram_a1_addr <= ram_a1_addr;
			end else if (state_rcv1 == RCV1_RAM1) begin
				ram_a0_addr <= ram_a0_addr;
				ram_a1_addr <= ram_a1_addr - 1;
			// base case
			end else begin
				ram_a0_addr <= ram_a0_addr;
				ram_a1_addr <= ram_a1_addr;
			end
		end else begin
				ram_a0_addr <= ram_a0_addr;
				ram_a1_addr <= ram_a1_addr;
		end
	end
	
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			ram_w0_addr <= `NULL_8B;
			ram_w1_addr <= `NULL_8B; 
			w_height_counter_rst = 1'b0;
		end else if (init_matrix_w_param) begin
			ram_w0_addr <= (w_height - 1);
			ram_w1_addr <= (w_height - 1);
			w_height_counter_rst = 1'b0;
		end else if (ram_w_update_ok) begin 
			if (w_height_counter == (w_width >> 1)) begin
				ram_w0_addr <= (w_height - w_seg_counter - 1);
				ram_w1_addr <= (w_height - w_seg_counter - 1);
				w_height_counter_rst = 1'b1;
			end else begin
				ram_w0_addr <= ram_w0_addr + w_height;
				ram_w1_addr <= ram_w1_addr + w_height;
				w_height_counter_rst = 1'b0;
			end
		end else begin
			ram_w0_addr <= ram_w0_addr;
			ram_w1_addr <= ram_w1_addr;
			w_height_counter_rst = 1'b0;
		end
	end
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			ram_c_addr <= 0;
		else if ((state_snd == SND_R3) && (nxt_state_snd == SND_R0))
			ram_c_addr <= (ram_c_addr + 1);
		else 
			ram_c_addr <= ram_c_addr;
	end
	
	