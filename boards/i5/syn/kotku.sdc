create_clock -period 40.000000 -name clk_in [get_nets {clk_25_}]
#create_clock -period 8.000000 -name clk_125MHz [get_nets {tmds_clk}]
#create_clock -period 10.000000 -name clk_100MHz [get_nets {sdram_clk_}]
#create_clock -period 40.000000 -name clk_25MHz [get_nets {vga_clk}]
#create_clock -period 80.000000 -name clk_12_5MHz [get_nets {clk}]

#create_generated_clock -name clk_125MHz -source [get_nets {clk_25_}] -multiply_by 5 [get_nets {tmds_clk}]
#create_generated_clock -name clk_100MHz -source [get_nets {clk_25_}] -multiply_by 4 [get_nets {sdram_clk_}]
#create_generated_clock -name clk_25MHz -source [get_nets {sdram_clk_}] -divide_by 4 [get_nets {vga_clk}]

#create_generated_clock -name clk_75MHz -source [get_nets {clk_25_}] -multiply_by 3 [get_nets {sdram_clk_}]
#create_generated_clock -name clk_25MHz -source [get_nets {sdram_clk_}] -divide_by 3 [get_nets {vga_clk}]

create_generated_clock -name clk_50MHz   -source [get_nets {clk_25_}] -multiply_by 2 [get_nets {sdram_clk_}]
create_generated_clock -name clk_50MHz_2 -source [get_nets {clk_25_}] -multiply_by 2 [get_nets {sdram_clk}]
create_generated_clock -name clk_25MHz   -source [get_nets {clk_25_}] -multiply_by 1 [get_nets {vga_clk}]

create_generated_clock -name clk_12_5MHz -source [get_nets {clk_25_}] -divide_by 2 [get_nets {clk}]

#derive_pll_clocks -create_base_clocks
#derive_clock_uncertainty
