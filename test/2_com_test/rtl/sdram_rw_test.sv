// write a array of byte to ram then read out
// passed at 2M baudrate

module sdram_rw_test(
    input         	clk,                      //FPGA外部时钟，50M
    input         	rst_n,                    //按键复位，低电平有效
    //SDRAM 芯片接口
    output       	sdram_clk,                //SDRAM 芯片时钟
    output       	sdram_cke,                //SDRAM 时钟有效
    output       	sdram_cs_n,               //SDRAM 片选
    output      	sdram_ras_n,              //SDRAM 行有效
    output      	sdram_cas_n,              //SDRAM 列有效
    output      	sdram_we_n,               //SDRAM 写有效
    output [ 1:0]	sdram_ba,                 //SDRAM Bank地址
    output [12:0]	sdram_addr,               //SDRAM 行/列地址
    inout  [15:0] 	sdram_data,               //SDRAM 数据
    output [ 1:0] 	sdram_dqm,                //SDRAM 数据掩码
	
    //LED
    output logic    [5:0]     sel,		          // 数码管位选
    output logic    [7:0]     seg_led,              // 数码管段选
	
	//UART
	input 			RX,
	output 			TX,
	output			RX_debug, TX_debug
    );
    
//wire define
wire        clk_50m;                        //SDRAM 读写测试时钟
wire        clk_100m;                       //SDRAM 控制器时钟
wire        clk_100m_shift;                 //相位偏移时钟
     
logic        wr_en;                          //SDRAM 写端口:写使能
logic [15:0] wr_data;                        //SDRAM 写端口:写入的数据
logic        rd_en;                          //SDRAM 读端口:读使能
logic [15:0] rd_data;                        //SDRAM 读端口:读出的数据
wire         sdram_init_done;                //SDRAM 初始化完成信号

wire        locked;                         //PLL输出有效标志
wire        sys_rst_n;                      //系统复位信号
wire        error_flag;                     //读写测试错误标志

wire 		tx_done;
wire		rx_done, rx_done_raw;


//logic define

reg[7:0]	rx_data;
logic[7:0]	tx_data;
logic 		send_data;
logic		load_tx_data;		// load data from mem to uart

reg[7:0]	number_total;		//total number of incoming data
reg[7:0]	number_counter;		//count the remaining data from RX

reg			set_number_total;
reg			set_number_counter;	// read from number_total
reg			init_number_counter;// read from rx_data
reg			dec_number_counter; // decrement counter

reg[3:0]	rx_tx_counter;		// count 16 cycles after writing last data
reg			dec_rx_tx_counter;	// dec counter


//parameter define
parameter  CLK_FREQ = 50000000;
parameter  UART_BPS = 2000000;

localparam START_CODE = 8'h39;

//*****************************************************
//**                    main code
//***************************************************** 

//待PLL输出稳定之后，停止系统复位
assign sys_rst_n = rst_n & locked;

assign TX_debug = TX;
assign RX_debug = RX;

//例化PLL, 产生各模块所需要的时钟
pll_clk u_pll_clk(
    .inclk0             (clk),
    .areset             (~rst_n),
    
    .c0                 (clk_50m),
    .c1                 (clk_100m),
    .c2                 (clk_100m_shift),
    .locked             (locked)
    );


typedef enum reg[3:0] {
	IDLE, START,
	RECEIVE, WR,
	WR_RD_WAIT,
	TRANSMIT, RD1, RD2, SEND
} state_t;

state_t state, nxt_state;


always_ff @ (posedge clk or negedge rst_n)
  if (!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;


// set the total number of 8-bit data will RX/TX
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		number_total <= 8'b0;
	end else if (set_number_total) begin
		number_total <= rx_data;
	end else if (init_number_counter) begin
		number_total <= number_total;
	end
end


// counte down
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		number_counter <= 8'b0;
	end else if (set_number_counter) begin
		number_counter <= number_total;
	end else if (init_number_counter) begin
		number_counter <= rx_data;
	end else if (dec_number_counter) begin
		number_counter <= (number_counter - 8'b1);	// possible underflow bug
	end else begin
		number_counter <= number_counter;
	end
end


//assign dec_rx_tx_counter = (state == WR_RD_WAIT);	
// count down
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rx_tx_counter <= 4'b1111;
	end else if (dec_rx_tx_counter) begin
		rx_tx_counter <= rx_tx_counter - 4'b1;
	end else begin
		rx_tx_counter <= rx_tx_counter;
	end
end


//load data from mem to uart
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		tx_data <= 8'b0;
	end else if (load_tx_data) begin
		tx_data <= rd_data[7:0];
	end else begin
		tx_data <= tx_data;
	end
end


//控制数码管位选信号（低电平有效），选中所有的数码管
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        sel <= 6'b111111;
    else
        sel <= 6'b000000;
end

//根据数码管显示的数值，控制段选信号
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        seg_led <= 8'b0;
    else begin
        case (state)
            IDLE :    seg_led <= 8'b1100_0000;		// 0
            START :    seg_led <= 8'b1111_1001; 	// 1
            RECEIVE :    seg_led <= 8'b1010_0100;	// 2
            WR :    seg_led <= 8'b1011_0000;		// 3
            WR_RD_WAIT :    seg_led <= 8'b1001_1001;// 4
            TRANSMIT :    seg_led <= 8'b1001_0010;	// 5
            RD1 :    seg_led <= 8'b1000_0010;		// 6
            RD2 :    seg_led <= 8'b1111_1000;		// 7
            SEND :    seg_led <= 8'b1000_0000;		// 8
            //4'h9 :    seg_led <= 8'b1001_0000;	// 9
            //4'ha :    seg_led <= 8'b1000_1000;	// a
            //4'hb :    seg_led <= 8'b1000_0011;	// b
            //4'hc :    seg_led <= 8'b1100_0110;	// c
            //4'hd :    seg_led <= 8'b1010_0001;	// d
            //4'he :    seg_led <= 8'b1000_0110;	// e
            //4'hf :    seg_led <= 8'b1000_1110;	// f
            default : seg_led <= 8'b1100_0000;		// 0
        endcase
    end
end


//UART module
uart #(
	.CLK_FREQ(CLK_FREQ),
	.UART_BPS(UART_BPS)
)
myUART (
	//inputs
	.clk(clk),
	.rst_n(rst_n),
	.RX(RX),
	.send_data(send_data),
	.tx_data(tx_data),
	
	//outputs
	.TX(TX),
	.rx_done(rx_done_raw),
	.tx_done(tx_done),
	.rx_data(rx_data)
);


//output rx_done only one cycle
posedgeDect pd1 (
	.clk(clk),
	.rst_n(rst_n),
	.in(rx_done_raw),
	.out(rx_done)
);


always_comb begin
	
	//////////////////////////////////////
    // Default assign all output of SM //
    ////////////////////////////////////
	nxt_state				= IDLE;			
	set_number_total		= 1'b0;
	init_number_counter		= 1'b0;
	set_number_counter		= 1'b0;
	dec_number_counter		= 1'b0;
	dec_rx_tx_counter		= 1'b0;
	wr_en					= 1'b0;
	wr_data					= 16'h0;
	rd_en					= 1'b0;
	send_data				= 1'b0;
	load_tx_data			= 1'b0;
	
	case (state)
		
		IDLE: begin 
			if (rx_done && (rx_data == START_CODE)) begin
				nxt_state = START;				// identify first input data
				// IDLE to start working normally
			end else begin
				nxt_state = IDLE;
				// staying in IDLE working normally
			end
		end
		
		START: begin
			if (rx_done) begin	
				nxt_state = RECEIVE;							
				set_number_total = 1'b1;		// number_total = 2nd input data
				init_number_counter = 1'b1;		// number counter = 2nd input data
			end else begin
				nxt_state = START;				
			end
		end		
		
		RECEIVE: begin
			if (rx_done) begin
				nxt_state = WR;
				wr_en = 1'b1;
				wr_data = {8'b0,rx_data};
			end else if (number_counter == 0) begin
				nxt_state = WR_RD_WAIT;
			end else begin
				nxt_state = RECEIVE;
			end
		end
		
		WR: begin
				nxt_state = RECEIVE;
				dec_number_counter = 1'b1;
		end
		
		WR_RD_WAIT: begin
			dec_rx_tx_counter = 1'b1; // count down 16 cycle
			if (rx_tx_counter == 4'b0) begin
				nxt_state = TRANSMIT;
				set_number_counter = 1'b1;
			end else begin
				nxt_state = WR_RD_WAIT;
			end
		end
		
		TRANSMIT: begin
			if (number_counter == 8'b0) begin
				nxt_state = IDLE;
			end else begin
				nxt_state = RD1;
				rd_en = 1'b1;
			end
		end
		
		RD1: begin	// load data from mem to reg
			nxt_state = RD2;
			load_tx_data = 1'b1;
		end
		
		RD2: begin  // send data from reg via uart
			nxt_state = SEND;
			send_data = 1'b1;
			dec_number_counter = 1'b1;
		end
		
		SEND: begin
			if (tx_done) begin
				nxt_state = TRANSMIT;
			end else begin
				nxt_state = SEND;
			end
		end
		
		default: begin
			nxt_state = IDLE;
		end
		
	endcase
	
end


//SDRAM 控制器顶层模块,封装成FIFO接口
//SDRAM 控制器地址组成: {bank_addr[1:0],row_addr[12:0],col_addr[8:0]}
sdram_top u_sdram_top(
	.ref_clk			(clk_100m),			//sdram	控制器参考时钟
	.out_clk			(clk_100m_shift),	//用于输出的相位偏移时钟
	.rst_n				(sys_rst_n),		//系统复位
    
    //用户写端口
	.wr_clk 			(clk_50m),		    //写端口FIFO: 写时钟
	.wr_en				(wr_en),			//写端口FIFO: 写使能
	.wr_data		    (wr_data),		    //写端口FIFO: 写数据
	.wr_min_addr		(24'd0),			//写SDRAM的起始地址
	.wr_max_addr		(24'd1024),		    //写SDRAM的结束地址
	.wr_len			    (10'd1),			//写SDRAM时的数据突发长度, uart is slow so use 1
	.wr_load			(~sys_rst_n),		//写端口复位: 复位写地址,清空写FIFO
   
    //用户读端口
	.rd_clk 			(clk_50m),			//读端口FIFO: 读时钟
    .rd_en				(rd_en),			//读端口FIFO: 读使能
	.rd_data	    	(rd_data),		    //读端口FIFO: 读数据
	.rd_min_addr		(24'd0),			//读SDRAM的起始地址
	.rd_max_addr		(24'd1024),	    	//读SDRAM的结束地址
	.rd_len 			(10'd512),			//从SDRAM中读数据时的突发长度
	.rd_load			(~sys_rst_n),		//读端口复位: 复位读地址,清空读FIFO
	   
     //用户控制端口  
	.sdram_read_valid	(1'b1),             //SDRAM 读使能
	.sdram_init_done	(sdram_init_done),	//SDRAM 初始化完成标志
   
	//SDRAM 芯片接口
	.sdram_clk			(sdram_clk),        //SDRAM 芯片时钟
	.sdram_cke			(sdram_cke),        //SDRAM 时钟有效
	.sdram_cs_n			(sdram_cs_n),       //SDRAM 片选
	.sdram_ras_n		(sdram_ras_n),      //SDRAM 行有效
	.sdram_cas_n		(sdram_cas_n),      //SDRAM 列有效
	.sdram_we_n			(sdram_we_n),       //SDRAM 写有效
	.sdram_ba			(sdram_ba),         //SDRAM Bank地址
	.sdram_addr			(sdram_addr),       //SDRAM 行/列地址
	.sdram_data			(sdram_data),       //SDRAM 数据
	.sdram_dqm			(sdram_dqm)         //SDRAM 数据掩码
    );

endmodule 
