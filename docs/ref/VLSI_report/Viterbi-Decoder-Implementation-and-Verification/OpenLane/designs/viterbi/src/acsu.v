module acsu (
    // Inputs từ BMU [cite: 123-124]
    input wire [1:0] bm_s0_s0_i, bm_s0_s2_i,
    input wire [1:0] bm_s1_s0_i, bm_s1_s2_i,
    input wire [1:0] bm_s2_s1_i, bm_s2_s3_i,
    input wire [1:0] bm_s3_s1_i, bm_s3_s3_i,

    // Inputs từ PMU (Chi phí cũ) [cite: 124]
    input wire [7:0] pm_s0_i, pm_s1_i, pm_s2_i, pm_s3_i,

    // Outputs [cite: 124]
    output reg [3:0] dec_bits_o, // 4 bit quyết định (bit 0 cho S0, bit 1 cho S1...)
    output reg [7:0] pm_s0_o, pm_s1_o, pm_s2_o, pm_s3_o // Chi phí mới
);

    reg [7:0] path0_cand0, path0_cand1;
    reg [7:0] path1_cand0, path1_cand1;
    reg [7:0] path2_cand0, path2_cand1;
    reg [7:0] path3_cand0, path3_cand1;

    always @(*) begin
        // --- Tính toán cho State 0 ---
        // Đến S0 có thể từ S0 hoặc S1
        path0_cand0 = pm_s0_i + bm_s0_s0_i; // Từ S0
        path0_cand1 = pm_s1_i + bm_s1_s0_i; // Từ S1
        
        if (path0_cand0 <= path0_cand1) begin
            pm_s0_o = path0_cand0;
            dec_bits_o[0] = 1'b0; // Chọn nhánh trên (từ S0)
        end else begin
            pm_s0_o = path0_cand1;
            dec_bits_o[0] = 1'b1; // Chọn nhánh dưới (từ S1)
        end

        // --- Tính toán cho State 1 ---
        // Đến S1 có thể từ S2 hoặc S3
        path1_cand0 = pm_s2_i + bm_s2_s1_i; // Từ S2
        path1_cand1 = pm_s3_i + bm_s3_s1_i; // Từ S3

        if (path1_cand0 <= path1_cand1) begin
            pm_s1_o = path1_cand0;
            dec_bits_o[1] = 1'b0; // Từ S2
        end else begin
            pm_s1_o = path1_cand1;
            dec_bits_o[1] = 1'b1; // Từ S3
        end

        // --- Tính toán cho State 2 ---
        // Đến S2 có thể từ S0 hoặc S1
        path2_cand0 = pm_s0_i + bm_s0_s2_i; // Từ S0
        path2_cand1 = pm_s1_i + bm_s1_s2_i; // Từ S1

        if (path2_cand0 <= path2_cand1) begin
            pm_s2_o = path2_cand0;
            dec_bits_o[2] = 1'b0; // Từ S0
        end else begin
            pm_s2_o = path2_cand1;
            dec_bits_o[2] = 1'b1; // Từ S1
        end

        // --- Tính toán cho State 3 ---
        // Đến S3 có thể từ S2 hoặc S3
        path3_cand0 = pm_s2_i + bm_s2_s3_i; // Từ S2
        path3_cand1 = pm_s3_i + bm_s3_s3_i; // Từ S3

        if (path3_cand0 <= path3_cand1) begin
            pm_s3_o = path3_cand0;
            dec_bits_o[3] = 1'b0; // Từ S2
        end else begin
            pm_s3_o = path3_cand1;
            dec_bits_o[3] = 1'b1; // Từ S3
        end
    end

endmodule
