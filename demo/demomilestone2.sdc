# ============================================
# Timing Constraints for demomilestone2
# FPGA: Cyclone II EP2C35F672C6
# Clock: 50 MHz
# ============================================

# Define base clock
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

# Derive PLL clocks (if any)
derive_pll_clocks

# Derive clock uncertainty
derive_clock_uncertainty

# Input delays (referenced to CLOCK_50)
set_input_delay -clock CLOCK_50 -max 2.0 [get_ports {SW[*]}]
set_input_delay -clock CLOCK_50 -min 1.0 [get_ports {SW[*]}]

# Output delays (referenced to CLOCK_50)
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {LEDR[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {LEDG[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {HEX0[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {HEX1[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {HEX2[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {HEX3[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {HEX4[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {HEX5[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {HEX6[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {HEX7[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {LCD_DATA[*]}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {LCD_RW}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {LCD_RS}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {LCD_EN}]
set_output_delay -clock CLOCK_50 -max 2.0 [get_ports {LCD_ON}]

# Set false paths for asynchronous inputs (if needed)
# set_false_path -from [get_ports {SW[17]}] -to *

# Set multicycle paths (if needed for slower operations)
# set_multicycle_path -from [get_registers {*lsu*}] -to [get_registers {*regfile*}] -setup 2
# set_multicycle_path -from [get_registers {*lsu*}] -to [get_registers {*regfile*}] -hold 1