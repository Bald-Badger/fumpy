// load data from uart to registors
// or other war around

// a_height loader


always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		a_height <= `NULL_8B;
	else if (a_height_load)
		a_height <= uart_rx_data;
	else
		a_height <= a_height;
end

// a_width loader
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		a_width <= `NULL_8B;
	else if (a_width_load)
		a_width <= uart_rx_data;
	else
		a_width <= a_width;
end

// w_height loader
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		w_height <= `NULL_8B;
	else if (w_height_load)
		w_height <= uart_rx_data;
	else
		w_height <= w_height;
end

// w_width loader
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		w_width <= `NULL_8B;
	else if (w_width_load)
		w_width <= uart_rx_data;
	else
		w_width <= w_width;
end

// uart_tx_data_loader
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		uart_tx_data <= `NULL_8B;
	else if (uart_tx_data_load_ack1)
		uart_tx_data <= `ACKNOWLEDGE_1;
	else if (uart_tx_data_load_ack2)
		uart_tx_data <= `ACKNOWLEDGE_2;
	else if (uart_tx_data_load_ack3)
		uart_tx_data <= `ACKNOWLEDGE_3;
	else if (uart_tx_data_load_ram) begin
		if (fp_byte_counter == 3'd0) begin
			uart_tx_data <= c_data[31:24];
		end else if (fp_byte_counter == 3'd1) begin
			uart_tx_data <= c_data[23:16];
		end else if (fp_byte_counter == 3'd2) begin
			uart_tx_data <= c_data[15:8];
		end else if (fp_byte_counter == 3'd3) begin
			uart_tx_data <= c_data[7:0];
		end else begin
			uart_tx_data <= 8'b0;
		end
	end else
		uart_tx_data <= uart_tx_data;
end

// update reg for each byte come in
always_ff @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		fp_reg <= `NULL_FP;
	end else if (fp_reg_clr) begin
		fp_reg <= `NULL_FP;
	end else if (uart_rx_done) begin
		if (`UART_ORDER == 1'b1) begin
			fp_reg <= {fp_reg[23:0], uart_rx_data};
		end else if (`UART_ORDER == 1'b0) begin
			fp_reg <= {uart_rx_data, fp_reg[31:8]};
		end else begin
			fp_reg <= fp_reg;
		end
	end else begin
		fp_reg <= fp_reg;
	end
end