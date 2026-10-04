# ==============================================================================
# File: constraints.sdc (OPTIMIZED VERSION)
# ==============================================================================

# 1. Clock Definition
# Định nghĩa clock 12.5ns (80MHz)
create_clock -name clk -period 12.5 [get_ports clk]
set_clock_uncertainty 0.25 [get_clocks clk]

# 2. Reset
# Coi reset là đường giả để tool không tốn công tối ưu timing cho nó
set_false_path -from [get_ports rst_n]

# 3. IO Constraints
# QUAN TRỌNG: Loại bỏ port 'clk' ra khỏi danh sách input delay để tránh Warning STA-0441
set input_ports [remove_from_collection [all_inputs] [get_ports clk]]

set_input_delay 2.0 -clock clk $input_ports
set_input_transition 0.2 $input_ports

set_output_delay 2.0 -clock clk [all_outputs]
set_load 0.05 [all_outputs]

# 4. System Limits
# Nới lỏng Fanout lên 10 để giảm số lượng buffer -> Giảm tắc nghẽn -> Dễ sửa Antenna hơn
set_max_fanout 10 [current_design]

# Giữ nguyên Transition và Cap vì thư viện Sky130 chịu được
set_max_transition 1.5 [current_design]
set_max_capacitance 0.2 [current_design]

# 5. Driving Cell
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_4 $input_ports