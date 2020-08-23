	// define top layer states
	typedef enum[3:0] reg {
		// First steps
		IDLE, PHRASE,
		// matrix mul
		CMD_MUL,
		// store height and width of Matrix A and W
		// note the the value stored is half of actual size
		STR_A_H, STR_A_W,	
		STR_W_H, STR_W_W,
		ACK1,
		MATRIX_1_RCV,
		ACK2,
		MATRIX_2_RCV,
		ACK3
		CALC
		MATRIX_3_SND	
	} state_t;
	state_t state, nxt_state;