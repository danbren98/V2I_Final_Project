create_clock -name SYS_CLK -period 40.000 [get_ports SYS_CLK]
create_clock -name SCLK_NORTH -period 50.000 [get_ports SCLK_NORTH]
create_clock -name SCLK_SOUTH -period 50.000 [get_ports SCLK_SOUTH]
create_clock -name SCLK_EAST -period 50.000 [get_ports SCLK_EAST]
create_clock -name SCLK_WEST -period 50.000 [get_ports SCLK_WEST]
derive_pll_clocks
derive_clock_uncertainty

set_false_path -from [get_ports {SYS_RSTN}]

set_false_path -to [get_ports {TRAFFIC_LIGHT_RED_*}]
set_false_path -to [get_ports {TRAFFIC_LIGHT_YELLOW_*}]
set_false_path -to [get_ports {TRAFFIC_LIGHT_GREEN_*}]
set_false_path -to [get_ports {USER_LEDS[0]}]
set_false_path -to [get_ports {USER_LEDS[1]}]
set_false_path -to [get_ports {USER_LEDS[2]}]
set_false_path -to [get_ports {USER_LEDS[3]}]

set_false_path -from {spi_interface:WiFi_*_Inst|spi_slave:spi_slave_inst|rxbuffer[*]} -to {spi_interface:WiFi_*_Inst|spi_slave:spi_slave_inst|user_data_rx[*]}


set_false_path -from {spi_interface:WiFi_*_Inst|spi_slave:spi_slave_inst|rxbuffer[*]} -to {sld_signaltap:auto_signaltap_0|acq_trigger_in_reg[*]}
set_false_path -from {spi_interface:WiFi_*_Inst|spi_slave:spi_slave_inst|rxbuffer[*]} -to {sld_signaltap:auto_signaltap_0|acq_data_in_reg[*]}
set_false_path -from {main_controller:main_controller_ist|*_cars_num[*]} -to {sld_signaltap:auto_signaltap_0|acq_trigger_in_reg[*]}
set_false_path -from {main_controller:main_controller_ist|*_cars_num[*]} -to {sld_signaltap:auto_signaltap_0|acq_data_in_reg[*]}