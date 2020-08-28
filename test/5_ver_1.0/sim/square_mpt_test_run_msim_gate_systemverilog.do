transcript on
vmap altera_ver C:/Users/Shuai/Desktop/5_ver_1.0/sim/verilog_libs/altera_ver
vmap cycloneive_ver C:/Users/Shuai/Desktop/5_ver_1.0/sim/verilog_libs/cycloneive_ver
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -sv -work work +incdir+. {square_mpt_test_8_1200mv_85c_slow.vo}

vlog -sv -work work +incdir+C:/Users/Shuai/Desktop/5_ver_1.0/par/../sim/tb {C:/Users/Shuai/Desktop/5_ver_1.0/par/../sim/tb/top_tb.sv}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  top_tb

add wave *
view structure
view signals
run -all
