create_clock -name clk -period 5 [get_ports clk]
set_input_delay 1 [get_ports *]
set_output_delay 1 [get_ports *]
