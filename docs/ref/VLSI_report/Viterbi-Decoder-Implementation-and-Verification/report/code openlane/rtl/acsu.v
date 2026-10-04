module acsu (
    // Inputs tu BMU
    input wire [1:0] bm_s0_s0_i, bm_s0_s2_i,
    input wire [1:0] bm_s1_s0_i, bm_s1_s2_i,
    input wire [1:0] bm_s2_s1_i, bm_s2_s3_i,
    input wire [1:0] bm_s3_s1_i, bm_s3_s3_i,

    // Inputs tu PMU (Chi phi cu)
    input wire [7:0] pm_s0_i, pm_s1_i, pm_s2_i, pm_s3_i,

    // Outputs
    output reg [3:0] dec_bits_o,
    output reg [7:0] pm_s0_o, pm_s1_o, pm_s2_o, pm_s3_o
);

    reg [7:0] path0_cand0, path0_cand1;
    reg [7:0] path1_cand0, path1_cand1;
    reg [7:0] path2_cand0, path2_cand1;
    reg [7:0] path3_cand0, path3_cand1;

    // Thay always @(*) bang danh sach nhay day du
    always @(bm_s0_s0_i, bm_s0_s2_i, bm_s1_s0_i, bm_s1_s0_i, 
             bm_s2_s1_i, bm_s2_s3_i, bm_s3_s1_i, bm_s3_s3_i,
             pm_s0_i, pm_s1_i, pm_s2_i, pm_s3_i,
             path0_cand0, path0_cand1, path1_cand0, path1_cand1,
             path2_cand0, path2_cand1, path3_cand0, path3_cand1) begin

               // --- Tinh toan cho State 0 ---
        path0_cand0 = pm_s0_i + bm_s0_s0_i;
        path0_cand1 = pm_s1_i + bm_s1_s0_i;
                // --- Tinh toan cho State 1 ---
        path1_cand0 = pm_s2_i + bm_s2_s1_i;
        path1_cand1 = pm_s3_i + bm_s3_s1_i;
                // --- Tinh toan cho State 2 ---
        path2_cand0 = pm_s0_i + bm_s0_s2_i;
        path2_cand1 = pm_s1_i + bm_s1_s2_i;
                // --- Tinh toan cho State 3 ---
        path3_cand0 = pm_s2_i + bm_s2_s3_i;
        path3_cand1 = pm_s3_i + bm_s3_s3_i;
        // Gan gia tri mac dinh (Tuong duong voi default trong case)
        // Dam bao dau ra luon xac dinh ngay ca khi logic if-else co so ho
        dec_bits_o = 4'b0000;
        pm_s0_o    = 8'hFF;
        pm_s1_o    = 8'hFF;
        pm_s2_o    = 8'hFF;
        pm_s3_o    = 8'hFF;
        

        if (path0_cand0 <= path0_cand1) begin
            pm_s0_o = path0_cand0;
            dec_bits_o[0] = 1'b0;
        end else begin
            pm_s0_o = path0_cand1;
            dec_bits_o[0] = 1'b1;
        end

        if (path1_cand0 <= path1_cand1) begin
            pm_s1_o = path1_cand0;
            dec_bits_o[1] = 1'b0;
        end else begin
            pm_s1_o = path1_cand1;
            dec_bits_o[1] = 1'b1;
        end

        if (path2_cand0 <= path2_cand1) begin
            pm_s2_o = path2_cand0;
            dec_bits_o[2] = 1'b0;
        end else begin
            pm_s2_o = path2_cand1;
            dec_bits_o[2] = 1'b1;
        end

        if (path3_cand0 <= path3_cand1) begin
            pm_s3_o = path3_cand0;
            dec_bits_o[3] = 1'b0;
        end else begin
            pm_s3_o = path3_cand1;
            dec_bits_o[3] = 1'b1;
        end
    end

endmodule
