
#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {clk_27} -period 37.037 -waveform { 0.000 18.500 } [get_ports {CLOCK_27[0]}]
create_clock -name {SPI_SCK}  -period 41.666 -waveform { 20.8 41.666 } [get_ports {SPI_SCK}]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks

#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -max 6.4 [get_ports SDRAM_DQ[*]]
set_input_delay -clock [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -min 3.2 [get_ports SDRAM_DQ[*]]

#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -max 1.5 [get_ports {SDRAM_D* SDRAM_A* SDRAM_BA* SDRAM_n* SDRAM_CKE}]
set_output_delay -clock [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -min -0.8 [get_ports {SDRAM_D* SDRAM_A* SDRAM_BA* SDRAM_n* SDRAM_CKE}]
set_output_delay -clock [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -max 1.5 [get_ports {SDRAM_CLK}]
set_output_delay -clock [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -min -0.8 [get_ports {SDRAM_CLK}]

set_output_delay -clock [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -max 0 [get_ports {VGA_*}]
set_output_delay -clock [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -min -5 [get_ports {VGA_*}]

#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -asynchronous -group [get_clocks {SPI_SCK}] -group [get_clocks {pll|altpll_component|auto_generated|pll1|clk[*]}]

#**************************************************************
# Set False Path
#**************************************************************
set_false_path -to [get_ports {UART_TX}]
set_false_path -to [get_ports {AUDIO_L}]
set_false_path -to [get_ports {AUDIO_R}]
set_false_path -to [get_ports {LED}]




