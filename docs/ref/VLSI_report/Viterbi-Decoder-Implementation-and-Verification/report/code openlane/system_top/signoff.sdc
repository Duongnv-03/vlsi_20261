# File: signoff.sdc (Đã sửa lỗi tương thích OpenROAD)

# --- 1. ĐỊNH NGHĨA CLOCK ---
set clk_input_name "clk"
create_clock [get_ports $clk_input_name] -name clk -period 12.5

set_propagated_clock [all_clocks]
set_clock_uncertainty 0.1 [get_clocks clk]
set_clock_transition 0.15 [get_clocks clk]

# --- 2. QUY TẮC MÔI TRƯỜNG ---
set_max_transition 1.5 [current_design]
set_max_fanout 16 [current_design]

set_timing_derate -early 0.95
set_timing_derate -late 1.05

# --- 3. INPUT / OUTPUT ---
set_load 0.19 [all_outputs]

# SỬA LỖI Ở ĐÂY: Thay vì remove_from_collection, ta liệt kê trực tiếp
# Các input cần delay: reset, valid, data (trừ clk)
set input_ports [get_ports {rst_n dvalid_i data_i[*]}]

set_input_delay -max 4.00 -clock [get_clocks clk] $input_ports
set_input_delay -min 1.00 -clock [get_clocks clk] $input_ports

# Output vẫn giữ nguyên
set_output_delay -max 4.00 -clock [get_clocks clk] [all_outputs]
set_output_delay -min 1.00 -clock [get_clocks clk] [all_outputs]