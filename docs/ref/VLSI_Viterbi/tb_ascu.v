// ascu_tb.v - Testbench cho Add-Compare-Select Unit
`timescale 1ns / 1ps

module ascu_tb;

// Khai báo tín hiệu Testbench
reg [1:0] bm_s0_s0_i, bm_s0_s2_i, bm_s1_s0_i, bm_s1_s2_i;
reg [1:0] bm_s2_s1_i, bm_s2_s3_i, bm_s3_s1_i, bm_s3_s3_i;
reg [7:0] pm_s0_i, pm_s1_i, pm_s2_i, pm_s3_i;

wire [3:0] dec_bits_o;
wire [7:0] pm_s0_o, pm_s1_o, pm_s2_o, pm_s3_o;

// Khối ACSU được kiểm tra (UUT)
ascu uut (
    .bm_s0_s0_i(bm_s0_s0_i), .bm_s0_s2_i(bm_s0_s2_i),
    .bm_s1_s0_i(bm_s1_s0_i), .bm_s1_s2_i(bm_s1_s2_i),
    .bm_s2_s1_i(bm_s2_s1_i), .bm_s2_s3_i(bm_s2_s3_i),
    .bm_s3_s1_i(bm_s3_s1_i), .bm_s3_s3_i(bm_s3_s3_i),
    
    .pm_s0_i(pm_s0_i), .pm_s1_i(pm_s1_i),
    .pm_s2_i(pm_s2_i), .pm_s3_i(pm_s3_i),
    
    .dec_bits_o(dec_bits_o),
    .pm_s0_o(pm_s0_o), .pm_s1_o(pm_s1_o),
    .pm_s2_o(pm_s2_o), .pm_s3_o(pm_s3_o)
);

// Khởi tạo và Tạo xung đầu vào
initial begin
    // Khởi tạo ban đầu
    $display("--- Bắt đầu kiểm tra ACSU ---");
    pm_s0_i = 8'd0; 
    pm_s1_i = 8'd10; 
    pm_s2_i = 8'd20; 
    pm_s3_i = 8'd30;
    
    // Đặt BM cho trường hợp 1: Dữ liệu nhận được rất giống S0->S0, S2->S1, S0->S2, S2->S3
    // Tức là BM nhỏ cho các đường 0->0, 2->1, 0->2, 2->3
    bm_s0_s0_i = 2'd0; // S0->S0: Tốt
    bm_s1_s0_i = 2'd2; // S1->S0: Xấu
    
    bm_s2_s1_i = 2'd0; // S2->S1: Tốt
    bm_s3_s1_i = 2'd2; // S3->S1: Xấu
    
    bm_s0_s2_i = 2'd0; // S0->S2: Tốt
    bm_s1_s2_i = 2'd2; // S1->S2: Xấu
    
    bm_s2_s3_i = 2'd0; // S2->S3: Tốt
    bm_s3_s3_i = 2'd2; // S3->S3: Xấu

    #10;
    $display("Thời gian=%0t | Trường hợp 1: Chọn đường PM nhỏ", $time);

    // KIỂM TRA S0:
    // PM_00 = PM_S0_i (0) + BM_S0_S0_i (0) = 0
    // PM_10 = PM_S1_i (10) + BM_S1_S0_i (2) = 12
    // PM_S0_o = 0. Dec_bit[0] = 0 (chọn S0)
    $display("S0: PM_00=%d | PM_10=%d | PM_S0_o=%d (Kỳ vọng 0) | Dec_bit[0]=%b (Kỳ vọng 0)", 
              pm_s0_i + bm_s0_s0_i, pm_s1_i + bm_s1_s0_i, pm_s0_o, dec_bits_o[0]);

    // KIỂM TRA S1:
    // PM_21 = PM_S2_i (20) + BM_S2_S1_i (0) = 20
    // PM_31 = PM_S3_i (30) + BM_S3_S1_i (2) = 32
    // PM_S1_o = 20. Dec_bit[1] = 0 (chọn S2)
    $display("S1: PM_21=%d | PM_31=%d | PM_S1_o=%d (Kỳ vọng 20) | Dec_bit[1]=%b (Kỳ vọng 0)", 
              pm_s2_i + bm_s2_s1_i, pm_s3_i + bm_s3_s1_i, pm_s1_o, dec_bits_o[1]);
              
    // KIỂM TRA S2:
    // PM_02 = PM_S0_i (0) + BM_S0_S2_i (0) = 0
    // PM_12 = PM_S1_i (10) + BM_S1_S2_i (2) = 12
    // PM_S2_o = 0. Dec_bit[2] = 0 (chọn S0)
    $display("S2: PM_02=%d | PM_12=%d | PM_S2_o=%d (Kỳ vọng 0) | Dec_bit[2]=%b (Kỳ vọng 0)", 
              pm_s0_i + bm_s0_s2_i, pm_s1_i + bm_s1_s2_i, pm_s2_o, dec_bits_o[2]);
              
    // KIỂM TRA S3:
    // PM_23 = PM_S2_i (20) + BM_S2_S3_i (0) = 20
    // PM_33 = PM_S3_i (30) + BM_S3_S3_i (2) = 32
    // PM_S3_o = 20. Dec_bit[3] = 0 (chọn S2)
    $display("S3: PM_23=%d | PM_33=%d | PM_S3_o=%d (Kỳ vọng 20) | Dec_bit[3]=%b (Kỳ vọng 0)", 
              pm_s2_i + bm_s2_s3_i, pm_s3_i + bm_s3_s3_i, pm_s3_o, dec_bits_o[3]);
    
    // --- Trường hợp 2: Chọn đường PM lớn ---
    #10;
    pm_s0_i = 8'd50; 
    pm_s1_i = 8'd5; // PM_S1 cũ nhỏ hơn PM_S0 cũ
    
    // Đặt BM: S0->S0 tốt (0), S1->S0 xấu (2)
    bm_s0_s0_i = 2'd0; 
    bm_s1_s0_i = 2'd2; 

    #10;
    $display("\nThời gian=%0t | Trường hợp 2: Chọn đường PM lớn hơn (S1->S0)", $time);
    
    // KIỂM TRA S0:
    // PM_00 = PM_S0_i (50) + BM_S0_S0_i (0) = 50
    // PM_10 = PM_S1_i (5) + BM_S1_S0_i (2) = 7 <--- ĐƯỢC CHỌN
    // PM_S0_o = 7. Dec_bit[0] = 1 (chọn S1)
    $display("S0: PM_00=%d | PM_10=%d | PM_S0_o=%d (Kỳ vọng 7) | Dec_bit[0]=%b (Kỳ vọng 1)", 
              pm_s0_i + bm_s0_s0_i, pm_s1_i + bm_s1_s0_i, pm_s0_o, dec_bits_o[0]);

    $display("\n--- Kết thúc kiểm tra ACSU ---");
    $finish;
end

endmodule
