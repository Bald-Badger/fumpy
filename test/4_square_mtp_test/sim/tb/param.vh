`ifndef _param_vh_
`define _param_vh_

// communication
`define SYS_CLK_FREQ 	50000000	// clock frequency after PLL
`define SYS_UART_BPS 	115200 		// UART baud rate

// scale factor
`define N				2			// systolic arr width
`define W				$clog2(N)	// log2(N)

// constants
`define NULL_8B			8'b0
`define NULL_FP			32'b0

`define RAM_A0			8'b0
`define RAM_A1			8'b1
`define RAM_A_DISABLE	8'hFF
`define RAM_W0			8'b0
`define RAM_W1			8'b1
`define RAM_W_DISABLE	8'hFF

// Command: calc type
`define MATRIX_MULT		8'h11

// Command: MOSI cmd
`define START			8'h31

// Command: MISO good ack
`define ACKNOWLEDGE_0	8'h40
`define ACKNOWLEDGE_1	8'h41
`define ACKNOWLEDGE_2	8'h42
`define ACKNOWLEDGE_3	8'h43
`define ACKNOWLEDGE_4	8'h44
`define ACKNOWLEDGE_5	8'h45
`define ACKNOWLEDGE_6	8'h46
`define ACKNOWLEDGE_7	8'h47
`define ACKNOWLEDGE_8	8'h48
`define ACKNOWLEDGE_9	8'h49
`define ACKNOWLEDGE_A	8'h4A
`define ACKNOWLEDGE_B	8'h4B
`define ACKNOWLEDGE_C	8'h4C
`define ACKNOWLEDGE_D	8'h4D
`define ACKNOWLEDGE_E	8'h4E
`define ACKNOWLEDGE_F	8'h4F

//Command: MISO bad ack
`define ACKNOWLEDGE_ERR_0	8'h40
`define ACKNOWLEDGE_ERR_1	8'h41
`define ACKNOWLEDGE_ERR_2	8'h42
`define ACKNOWLEDGE_ERR_3	8'h43
`define ACKNOWLEDGE_ERR_4	8'h44
`define ACKNOWLEDGE_ERR_5	8'h45
`define ACKNOWLEDGE_ERR_6	8'h46
`define ACKNOWLEDGE_ERR_7	8'h47
`define ACKNOWLEDGE_ERR_8	8'h48
`define ACKNOWLEDGE_ERR_9	8'h49
`define ACKNOWLEDGE_ERR_A	8'h4A
`define ACKNOWLEDGE_ERR_B	8'h4B
`define ACKNOWLEDGE_ERR_C	8'h4C
`define ACKNOWLEDGE_ERR_D	8'h4D
`define ACKNOWLEDGE_ERR_E	8'h4E
`define ACKNOWLEDGE_ERR_F	8'h4F

//Command: MISO others
`define FINISH		8'h61

`endif
