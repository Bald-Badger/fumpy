// update reg value for all counters

	// for four_byte_counter
	// for each data arrive, inc 4-byte counter
	always_ff @ (posedge clk or negedge rst_n) begin
		if (!rst_n)
			four_byte_counter <= 3'b0;
		// clear FP reg also clears counter
		else if (fp_reg_clr)
			four_byte_counter <= 2'b1;
		// inc counter every time new data arrive
		else if (uart_rx_done)
			four_byte_counter <= four_byte_counter + 2'b1;
		// when 4 byte of data received, reset to 1
		// four_byte_counter is 5 for only one cycle
		else if (four_byte_counter == 3'd5)
			four_byte_counter <= 3'd1;
		else
			four_byte_counter <= four_byte_counter;
	end
	
	// for matrix a width counter
	// when hit full then switch ram to write into
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			a_width_counter <= `NULL_8B;
		else if (a_width_counter_rst)
			a_width_counter <= `NULL_8B;
		else if (a_width_counter_inc)
			a_width_counter <= a_width_counter + 1;
		else if (a_width_counter == w_height)
			a_width_counter <= `NULL_8B;
		else
			a_width_counter <= a_width_counter;
	end
	
	
	// matrix a segment counter
	// when full then A writing is finished
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			a_seg_counter <= `NULL_8B;
		else if (a_seg_counter_rst)
			a_seg_counter <= `NULL_8B;
		else if (a_seg_counter_inc)
			a_seg_counter <= a_seg_counter + 1;
		else 
			a_seg_counter <= a_seg_counter;
	end
	
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			w_seg_counter <= `NULL_8B;
		else if (init_matrix_w_param)
			w_seg_counter <= `NULL_8B;
		else if (w_seg_counter_inc)
			w_seg_counter <= w_seg_counter + 1;
		else
			w_seg_counter <= w_seg_counter;
	end
	
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			w_height_counter <= `NULL_8B;
		else if (init_matrix_w_param)
			w_height_counter <= `NULL_8B;
		else if (w_height_counter_rst)
			w_height_counter <= `NULL_8B;
		else if (w_height_counter_inc)
			w_height_counter <= w_height_counter + 1;
		else 
			w_height_counter <= w_height_counter;
	end
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			fp_byte_counter <= 3'b0;
		else if (fp_byte_counter_rst)
			fp_byte_counter <= 3'b0;
		else if (uart_tx_done) // only assert for one cycle so no problem
			fp_byte_counter <= fp_byte_counter + 3'b1;
		else if (fp_byte_counter == 3'd4) // count to 4
			fp_byte_counter <= 3'b0;
		else
			fp_byte_counter <= fp_byte_counter;
	end
