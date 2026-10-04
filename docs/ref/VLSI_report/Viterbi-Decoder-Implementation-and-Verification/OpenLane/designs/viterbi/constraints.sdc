# ==============================================================================
# SDC Constraints for Viterbi Decoder
# Clock Frequency: 50 MHz (Period = 20 ns)
# ==============================================================================

# --- Clock Definition ---
create_clock -name clk -period 20.0 [get_ports {clk}]

# --- Clock Uncertainty ---
set_clock_uncertainty 0.25 [get_clocks clk]

# --- Clock Transition ---
set_clock_transition 0.15 [get_clocks clk]

# --- Input Delay ---
# Assume inputs arrive 2ns after clock edge
set_input_delay 2.0 -clock clk [all_inputs]

# --- Output Delay ---
# Assume outputs need to be stable 2ns before next clock edge
set_output_delay 2.0 -clock clk [all_outputs]

# --- Exclude clock from input delay ---
set_input_delay 0 -clock clk [get_ports clk]

# --- Reset is asynchronous but synchronized internally ---
# Active-low reset
set_false_path -from [get_ports rst_n]

# --- Max Transition ---
set_max_transition 0.5 [current_design]

# --- Max Fanout ---
set_max_fanout 10 [current_design]
