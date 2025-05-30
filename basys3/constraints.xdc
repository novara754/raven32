# 100MHz Clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports i_clk]
create_clock -add -name sys_clk -period 10 -waveform {0 5}  [get_ports i_clk]

# UART
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports { o_tx }]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
