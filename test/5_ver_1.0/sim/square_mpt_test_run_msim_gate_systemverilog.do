transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

if ![file isdirectory vhdl_libs] {
	file mkdir vhdl_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {c:/intelfpga/18.1/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/cycloneive_ver
vmap cycloneive_ver ./verilog_libs/cycloneive_ver
vlog -vlog01compat -work cycloneive_ver {c:/intelfpga/18.1/quartus/eda/sim_lib/cycloneive_atoms.v}

if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -sv -work work +incdir+. {square_mpt_test_8_1200mv_85c_slow.svo}

vlog -sv -work work +incdir+C:/Users/Shuai/OneDrive\ -\ UW-Madison/fumpy/test/5_ver_1.0/par/../sim/tb {C:/Users/Shuai/OneDrive - UW-Madison/fumpy/test/5_ver_1.0/par/../sim/tb/top_tb.sv}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  top_tb

add wave *
view structure
view signals
run -all
