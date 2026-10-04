`include "bmu.v"
`include "acsu.v"
`include "pmu.v"
`include "tbu.v"

module viterbi_core (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [1:0] piso_data_i,
    input  wire       valid_i,
    output wire       core_data_o,
    output wire       core_valid_o
);

    // Internal Wires
    wire [1:0] bm_s0_s0, bm_s0_s2, bm_s1_s0, bm_s1_s2;
    wire [1:0] bm_s2_s1, bm_s2_s3, bm_s3_s1, bm_s3_s3;

    wire [7:0] pm_new_s0, pm_new_s1, pm_new_s2, pm_new_s3;
    wire [3:0] dec_bits_new;
    wire [7:0] pm_curr_s0, pm_curr_s1, pm_curr_s2, pm_curr_s3;

    // 1. BMU
    bmu u_bmu (
        .piso_data_i(piso_data_i),
        .bm_s0_s0_o(bm_s0_s0), .bm_s0_s2_o(bm_s0_s2),
        .bm_s1_s0_o(bm_s1_s0), .bm_s1_s2_o(bm_s1_s2),
        .bm_s2_s1_o(bm_s2_s1), .bm_s2_s3_o(bm_s2_s3),
        .bm_s3_s1_o(bm_s3_s1), .bm_s3_s3_o(bm_s3_s3)
    );

    // 2. ACSU
    acsu u_acsu (
        .bm_s0_s0_i(bm_s0_s0), .bm_s0_s2_i(bm_s0_s2),
        .bm_s1_s0_i(bm_s1_s0), .bm_s1_s2_i(bm_s1_s2),
        .bm_s2_s1_i(bm_s2_s1), .bm_s2_s3_i(bm_s2_s3),
        .bm_s3_s1_i(bm_s3_s1), .bm_s3_s3_i(bm_s3_s3),
        .pm_s0_i(pm_curr_s0), .pm_s1_i(pm_curr_s1),
        .pm_s2_i(pm_curr_s2), .pm_s3_i(pm_curr_s3),
        .dec_bits_o(dec_bits_new),      // Gửi sang TBU
        .pm_s0_o(pm_new_s0), .pm_s1_o(pm_new_s1), // Gửi sang PMU và TBU
        .pm_s2_o(pm_new_s2), .pm_s3_o(pm_new_s3)
    );

    // 3. PMU (Chỉ lưu trữ Metric)
    pmu u_pmu (
        .clk(clk),
        .rst_n(rst_n),
        .valid_i(valid_i),
        .pm_new_s0_i(pm_new_s0), .pm_new_s1_i(pm_new_s1),
        .pm_new_s2_i(pm_new_s2), .pm_new_s3_i(pm_new_s3),
        .pm_current_s0_o(pm_curr_s0), .pm_current_s1_o(pm_curr_s1),
        .pm_current_s2_o(pm_curr_s2), .pm_current_s3_o(pm_curr_s3)
    );

    // 4. TBU (Register Exchange Logic - Tách biệt)
    tbu u_tbu (
        .clk(clk),
        .rst_n(rst_n),
        .valid_i(valid_i),
        .dec_bits_i(dec_bits_new),     // Nhận quyết định từ ACSU
        // Cũng nhận PM mới để biết đường nào tốt nhất
        .pm_new_s0_i(pm_new_s0), .pm_new_s1_i(pm_new_s1),
        .pm_new_s2_i(pm_new_s2), .pm_new_s3_i(pm_new_s3),
        .decoded_bit_o(core_data_o),
        .valid_o(core_valid_o)
    );

endmodule