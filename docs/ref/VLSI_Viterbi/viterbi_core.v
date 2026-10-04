/*
 * MODULE: viterbi_core
 * CHỨC NĂNG: chứa 4 khối (BMU, ACSU, PMU, TBU)
 * KIẾN TRÚC: RAM-based
 */
module viterbi_core #(
    parameter TBL      = 15,
    parameter PM_WIDTH = 8
)(
    input  wire           clk,
    input  wire           rst_n,
    input  wire           valid_i,  // valid_serial_o từ PISO
    input  wire [1:0]     data_core_i,   // data_serial_o từ PISO
    
    output wire           data_serial_o, // Gửi cho SIPO
    output wire           valid_serial_o // Gửi cho SIPO
);

    // =================================================================
    // 1. DÂY NỐI NỘI BỘ (Kết nối 4 khối)
    // =================================================================

    // BMU -> ACSU (8 chi phí)
    wire [1:0] w_bm_s0_s0;
    wire [1:0] w_bm_s0_s2;
    wire [1:0] w_bm_s1_s0;
    wire [1:0] w_bm_s1_s2;
    wire [1:0] w_bm_s2_s1;
    wire [1:0] w_bm_s2_s3;
    wire [1:0] w_bm_s3_s1;
    wire [1:0] w_bm_s3_s3;

    // ACSU -> PMU (Ghi)
    wire [3:0] w_dec_bits;
    wire [PM_WIDTH-1:0] w_pm_new_s0;
    wire [PM_WIDTH-1:0] w_pm_new_s1;
    wire [PM_WIDTH-1:0] w_pm_new_s2;
    wire [PM_WIDTH-1:0] w_pm_new_s3;

    // PMU -> ACSU (Đọc PM cũ)
    wire [PM_WIDTH-1:0] w_pm_current_s0;
    wire [PM_WIDTH-1:0] w_pm_current_s1;
    wire [PM_WIDTH-1:0] w_pm_current_s2;
    wire [PM_WIDTH-1:0] w_pm_current_s3;

    // TBU <-> PMU (Đọc Lịch sử)
    wire [$clog2(TBL)-1:0] w_pm_read_addr;
    wire [3:0]             w_pm_read_data;


    // =================================================================
    // 2. KẾT NỐI (INSTANTIATION) 4 KHỐI LÕI
    // =================================================================

    // --- KHỐI 1: BMU (Tổ hợp) ---
    bmu bmu_inst (
        .piso_data_i       (data_core_i), // 2-bit lỗi
        .bm_s0_s0_o    (w_bm_s0_s0),
        .bm_s0_s2_o    (w_bm_s0_s2),
        .bm_s1_s0_o    (w_bm_s1_s0),
        .bm_s1_s2_o    (w_bm_s1_s2),
        .bm_s2_s1_o    (w_bm_s2_s1),
        .bm_s2_s3_o    (w_bm_s2_s3),
        .bm_s3_s1_o    (w_bm_s3_s1),
        .bm_s3_s3_o    (w_bm_s3_s3)
    );

    // --- KHỐI 2: ACSU (Tổ hợp) ---
    ascu #(
        .PM_WIDTH         (PM_WIDTH)
    ) acsu_inst (
        // Đầu vào Chi phí (từ BMU)
        .bm_s0_s0_i       (w_bm_s0_s0),
        .bm_s0_s2_i       (w_bm_s0_s2),
        .bm_s1_s0_i       (w_bm_s1_s0),
        .bm_s1_s2_i       (w_bm_s1_s2),
        .bm_s2_s1_i       (w_bm_s2_s1),
        .bm_s2_s3_i       (w_bm_s2_s3),
        .bm_s3_s1_i       (w_bm_s3_s1),
        .bm_s3_s3_i       (w_bm_s3_s3),
        
        // Đầu vào PM Cũ (từ PMU)
        .pm_s0_i          (w_pm_current_s0),
        .pm_s1_i          (w_pm_current_s1),
        .pm_s2_i          (w_pm_current_s2),
        .pm_s3_i          (w_pm_current_s3),
        
        // Đầu ra (Gửi cho PMU)
        .dec_bits_o  (w_dec_bits),
        .pm_s0_o          (w_pm_new_s0),
        .pm_s1_o          (w_pm_new_s1),
        .pm_s2_o          (w_pm_new_s2),
        .pm_s3_o          (w_pm_new_s3)
    );

    // --- KHỐI 3: PMU (Tuần tự) ---
    pmu #(
        .TBL              (TBL),
        .PM_WIDTH         (PM_WIDTH)
    ) pmu_inst (
        .clk              (clk),
        .rst_n            (rst_n),
        .valid_i          (valid_i),    // Cờ "Ghi"
        
        // Đầu vào (Ghi từ ACSU)
        .dec_bits_i  (w_dec_bits),
        .pm_new_s0_i      (w_pm_new_s0),
        .pm_new_s1_i      (w_pm_new_s1),
        .pm_new_s2_i      (w_pm_new_s2),
        .pm_new_s3_i      (w_pm_new_s3),
        
        // Cổng Đọc Lịch sử (cho TBU)
        .read_addr_i      (w_pm_read_addr), // Địa chỉ TBU muốn đọc
        .read_data_o      (w_pm_read_data), // Dữ liệu lịch sử TBU nhận
        
        // Đầu ra PM Cũ (cho ACSU & TBU)
        .pm_current_s0_o  (w_pm_current_s0),
        .pm_current_s1_o  (w_pm_current_s1),
        .pm_current_s2_o  (w_pm_current_s2),
        .pm_current_s3_o  (w_pm_current_s3)
    );

    // --- KHỐI 4: TBU (Tuần tự) ---
    tbu #(
        .TBL              (TBL),
        .PM_WIDTH         (PM_WIDTH)
    ) tbu_inst (
        .clk              (clk),
        .rst_n            (rst_n),
        .valid_i          (valid_i),    // Cờ "bắt đầu chặng mới"
        
        // Đầu vào PM Hiện tại (từ PMU)
        .pm_current_s0_i  (w_pm_current_s0),
        .pm_current_s1_i  (w_pm_current_s1),
        .pm_current_s2_i  (w_pm_current_s2),
        .pm_current_s3_i  (w_pm_current_s3),
        
        // Cổng Đọc Lịch sử (từ PMU)
        .pm_read_data_i   (w_pm_read_data),
        .pm_read_addr_o   (w_pm_read_addr),
        
        // Đầu ra cuối cùng (gửi cho SIPO)
        .data_serial_o    (data_serial_o),
        .valid_serial_o   (valid_serial_o)
    );

endmodule