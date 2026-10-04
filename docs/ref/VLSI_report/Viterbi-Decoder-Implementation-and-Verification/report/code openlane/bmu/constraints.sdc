# --- constraints_bmu.sdc ---

# 1. KHÔNG tạo clock trên port (vì không có port clk)
# Thay vào đó tạo Virtual Clock để tính delay input/output
create_clock -name vclk -period 12.5

# 2. Input/Output Delay dựa trên Virtual Clock
# Input delay (từ PISO bắn sang)
set_input_delay 2.0 -clock vclk [all_inputs]

# Output delay (bắn sang ACSU)
set_output_delay 2.0 -clock vclk [all_outputs]

# 3. Load & Transition (Giữ nguyên)
set_load 0.05 [all_outputs]
set_max_transition 1.5 [current_design]
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_4 [all_inputs]