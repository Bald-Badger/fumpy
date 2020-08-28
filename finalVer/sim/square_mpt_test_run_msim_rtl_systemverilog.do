transcript on
if ![file isdirectory square_mpt_test_iputf_libs] {
	file mkdir square_mpt_test_iputf_libs
}

vmap altera_ver C:/Users/Shuai/Desktop/5_ver_1.0/sim/verilog_libs/altera_ver
vmap lpm_ver C:/Users/Shuai/Desktop/5_ver_1.0/sim/verilog_libs/lpm_ver
vmap sgate_ver C:/Users/Shuai/Desktop/5_ver_1.0/sim/verilog_libs/sgate_ver
vmap altera_mf_ver C:/Users/Shuai/Desktop/5_ver_1.0/sim/verilog_libs/altera_mf_ver
vmap altera_lnsim_ver C:/Users/Shuai/Desktop/5_ver_1.0/sim/verilog_libs/altera_lnsim_ver
vmap cycloneive_ver C:/Users/Shuai/Desktop/5_ver_1.0/sim/verilog_libs/cycloneive_ver
vmap cycloneive C:/Users/Shuai/Desktop/5_ver_1.0/sim/vhdl_libs/cycloneive
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vcom "C:/Users/Shuai/Desktop/5_ver_1.0/rtl/FP/FP32_accum_sim/dspba_library_package.vhd"
vcom "C:/Users/Shuai/Desktop/5_ver_1.0/rtl/FP/FP32_accum_sim/dspba_library.vhd"        
vcom "C:/Users/Shuai/Desktop/5_ver_1.0/rtl/FP/FP32_accum_sim/FP32_accum.vhd"           

vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/UART {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/UART/uart_TX.v}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/UART {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/UART/uart_RX.v}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/UART {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/UART/posedgeDect.v}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/FP {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/FP/FP32_mult.v}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/RAM {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/RAM/RAM_32b_256.v}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PLL {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PLL/pll.v}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/RAM {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/RAM/RAM_32b_result.v}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/par/db {C:/Users/Shuai/Desktop/5_ver_1.0/par/db/pll_altpll.v}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/DFF {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/DFF/dff_1b.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/UART {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/UART/uart.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/Seg {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/Seg/seg_led_static.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE/mult.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE/MAC.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE/FPmult.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE/accum.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/DFF {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/DFF/dff_32b.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/square_mpt_test.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/FSM_top {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/FSM_top/FSM.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE/systolic_arr_ctrl.sv}
vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE {C:/Users/Shuai/Desktop/5_ver_1.0/rtl/PE/systolic_arr.sv}

vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/par/../sim/tb {C:/Users/Shuai/Desktop/5_ver_1.0/par/../sim/tb/top_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L cycloneive -L rtl_work -L work -voptargs="+acc"  top_tb

add wave *
view structure
view signals
run -all
