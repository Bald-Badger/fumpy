always_ff @(posedge clk or negedge rst_n)
	if (!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;

		
always_comb begin
	//default values
	nxt_state = IDLE;
	
	// ram signal
	seg_length_counter_inc = 1'b0;
	seg_length_counter_rst = 1'b0;
	read_mem = 1'b0;
	
	// MAC signal
	en_mult = 1'b0;
	clr_mult = 1'b0;
	en_accum = 1'b0;
	clr_accum = 1'b0;
	accum_start = 1'b0;
	
	stall_counter_rst = 1'b0;
	stall_counter_inc = 1'b0;
	
	
	calc_done = 1'b0;
	
	case (state)
		IDLE: begin
			if (data_load_done) begin
				nxt_state = CALC;
				accum_start = 1'b1;	// bug?
			end else begin
				nxt_state = IDLE;
			end
		end
		
		CALC: begin
			en_mult = 1'b1;
			en_accum = 1'b1;
			if (a_seg_counter == a_seg_cnt) begin
				// everything finished
				nxt_state = IDLE;
				clr_mult = 1'b1;
				clr_accum = 1'b1;
				calc_done = 1'b1;
			end else if (seg_length_counter == seg_length) begin
				// ptr has pointed to the end of strip
				nxt_state = STALL;
				seg_length_counter_rst = 1'b1; // reset addr
			end else begin
				nxt_state = CALC;
				seg_length_counter_inc = 1'b1; // increment addr
				read_mem = 1'b1;
			end
		end
		
		STALL: begin
			en_mult = 1'b1;
			en_accum = 1'b1;
			if (stall_counter == stall_count_target) begin
				nxt_state = STR;
				stall_counter_rst = 1'b1;				
			end	else begin
				nxt_state = STALL;
				stall_counter_inc = 1'b1;
			end
		end
		
		STR: begin
			nxt_state = TIDY;
			clr_mult = 1'b1;
			clr_accum = 1'b1;
		end
		
		TIDY: begin
			nxt_state = CALC;
			accum_start = 1'b1; // bug?
		end
		
	endcase
	
end