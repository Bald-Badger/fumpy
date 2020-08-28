create_clock -period "200MHz" [get_ports osc_clk] 
derive_pll_clocks
derive_clock_uncertainty