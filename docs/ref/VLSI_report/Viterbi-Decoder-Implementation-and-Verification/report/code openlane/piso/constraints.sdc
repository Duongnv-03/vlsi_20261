# ==============================================================================
# File: constraints.sdc (TIMING OPTIMIZED)
# ==============================================================================

# 1. Clock Definition
create_clock -name clk -period 12.5 [get_ports clk]
# Giam uncertainty xuong 0.15 neu clock jitter thuc te tot hon, giup gianh them margin cho Setup
set_clock_uncertainty 0.1 [get_clocks clk]

# 2. Reset
set_false_path -from [get_ports rst_n]

# 3. IO Constraints
# Input delay 20% chu ky la tieu chuan
set_input_delay 2.0 -clock clk [all_inputs]
set_input_transition 0.2 [all_inputs]

# Output delay 20% chu ky
set_output_delay 2.0 -clock clk [all_outputs]
# Load nhe (50fF) de tranh loi Slew tai Output
set_load 0.05 [all_outputs]

# 4. System Limits
# ------------------------------------------------------------------------------
# Noi long Fanout len 10 de giam tac nghen mach va giam buffering
set_max_fanout 6 [current_design]

# Chuan Sky130
set_max_transition 1.5 [current_design]
set_max_capacitance 0.2 [current_design]

# 5. Driving Cell
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_4 [all_inputs]
