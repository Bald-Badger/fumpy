// RAM/MAC interface control
assign ram_a0_addr = a_seg_counter * seg_length + seg_length_counter;
assign ram_a1_addr = ram_a0_addr;

assign ram_w0_addr = w_seg_counter * seg_length + seg_length_counter;
assign ram_w1_addr = ram_w0_addr;

assign ram_a0_rden = read_mem;
assign ram_a1_rden = read_mem;
assign ram_w0_rden = read_mem;
assign ram_w1_rden = read_mem;

assign ram_c_wren_00 = (state == STR3); // get around bug, should be 1
assign ram_c_wren_01 = (state == STR2);
assign ram_c_wren_10 = (state == STR2);
assign ram_c_wren_11 = (state == STR1); // get around bug, should be 3

assign ram_c_wren =	{{{ram_c_wren_00},{ram_c_wren_01}},
					{{ram_c_wren_10},{ram_c_wren_11}}};


always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		ram_c_addr <= 0;
	else if (seg_inc)
		ram_c_addr <= (ram_c_addr + 1);
	else
		ram_c_addr <= ram_c_addr;
end
