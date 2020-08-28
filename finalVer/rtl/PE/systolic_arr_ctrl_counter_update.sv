assign w_seg_counter_inc = seg_inc;
assign a_seg_counter_inc =	(w_seg_counter == w_seg_cnt)
							&& arr_ctrl_working;

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		a_seg_counter <= 0;
	else if (a_seg_counter_rst)
		a_seg_counter <= 0;
	else if (a_seg_counter_inc)
		a_seg_counter <= (a_seg_counter + 1);
	else if (a_seg_counter == a_seg_cnt)
		a_seg_counter <= a_seg_counter; // all finished, hold value
	else
		a_seg_counter <= a_seg_counter;
end


always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		w_seg_counter <= 0;
	else if (w_seg_counter_rst)
		w_seg_counter <= 0;
	else if (w_seg_counter_inc)
		w_seg_counter <= (w_seg_counter + 1);
	else if (w_seg_counter == w_seg_cnt)
		w_seg_counter <= 0;
	else
		w_seg_counter <= w_seg_counter;
end


always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		seg_length_counter <= 0;
	else if (seg_length_counter_rst)
		seg_length_counter <= 0;
	else if (seg_length_counter_inc)
		seg_length_counter <= (seg_length_counter + 1);
	else if (seg_length_counter == seg_length)
		seg_length_counter <= 0;
	else 
		seg_length_counter <= seg_length_counter;
end


always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		stall_counter <= 0;
	else if (stall_counter_rst)
		stall_counter <= 0;
	else if (stall_counter_inc)
		stall_counter <= (stall_counter + 1);
	else if (stall_counter == stall_count_target)
		stall_counter <= 0;
	else 
		stall_counter <= 0;
end
