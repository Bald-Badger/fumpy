// RAM/MAC interface control
assign ram_a0_addr = a_seg_counter * seg_length + seg_length_counter;
assign ram_a1_addr = ram_a0_addr;

assign ram_w0_addr = w_seg_counter * seg_length + seg_length_counter;
assign ram_w1_addr = ram_w0_addr;

assign ram_a0_rden = read_mem;
assign ram_a1_rden = read_mem;
assign ram_w0_rden = read_mem;
assign ram_w1_rden = read_mem;


