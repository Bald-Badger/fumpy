set_global_assignment -entity "FP32_accum" -library "lib_FP32_accum" -name IP_TOOL_NAME "altera_fp_acc_custom"
set_global_assignment -entity "FP32_accum" -library "lib_FP32_accum" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "FP32_accum" -library "lib_FP32_accum" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FP32_accum" -name SPD_FILE [file join $::quartus(sip_path) "FP32_accum.spd"]

set_global_assignment -library "lib_FP32_accum" -name MISC_FILE [file join $::quartus(sip_path) "FP32_accum_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_FP32_accum" -name MISC_FILE [file join $::quartus(sip_path) "FP32_accum_sim/dspba_library.vhd"]
set_global_assignment -library "lib_FP32_accum" -name MISC_FILE [file join $::quartus(sip_path) "FP32_accum_sim/FP32_accum.vhd"]
