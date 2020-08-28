// 7-seg debug led indicating current state
assign state_val =	(state == IDLE) 		? 4'h0 :
					(state == PHRASE) 		? 4'h1 :
					(state == STR_A_H) 		? 4'h2 :
					(state == STR_A_W) 		? 4'h3 :
					(state == STR_W_H) 		? 4'h4 :
					(state == STR_W_W) 		? 4'h5 :
					(state == MATRIX_1_RCV) ? 4'h6 :
					(state == MATRIX_2_RCV) ? 4'h7 :
					(state == ACK3) 		? 4'h8 :
					(state == CALC)			? 4'h9 :
					(state == MATRIX_3_SND) ? 4'hA :
					//(state == ) 			? 4'hB :
					//(state == ) 			? 4'hC :
					//(state == ) 			? 4'hD :
					//(state == ) 			? 4'hE :
											  4'hF ;
