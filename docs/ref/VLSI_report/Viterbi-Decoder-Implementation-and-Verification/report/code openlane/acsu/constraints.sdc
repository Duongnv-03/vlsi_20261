# 1. Tao Virtual Clock (Khong gan vao chan nao ca)
# De tool co moc thoi gian ma tinh toan delay
create_clock -name vclk -period 12.5

# 2. Reset (Xoa dong nay vi khong co chan rst_n)
# set_false_path -from [get_ports rst_n]

# 3. IO Constraints (Tham chieu theo vclk)
# Input delay (Tu BMU/PMU ban sang)
set_input_delay 2.0 -clock vclk [all_inputs]
set_input_transition 0.2 [all_inputs]

# Output delay (Ban sang TBU/PMU)
set_output_delay 2.0 -clock vclk [all_outputs]
set_load 0.05 [all_outputs]

# 4. System Limits
set_max_fanout 6 [current_design]
set_max_transition 1.5 [current_design]
set_max_capacitance 0.2 [current_design]

# 5. Driving Cell
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_4 [all_inputs]