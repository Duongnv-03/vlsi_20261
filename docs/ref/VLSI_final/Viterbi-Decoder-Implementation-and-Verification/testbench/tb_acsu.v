// tb_acsu.v - Testbench cho Add-Compare-Select Unit
`timescale 1ns / 1ps
`include "../design/acsu.v"

module tb_acsu;

// Khai báo tín hi?u Testbench
reg [1:0] bm_s0_s0_i, bm_s0_s2_i, bm_s1_s0_i, bm_s1_s2_i;
reg [1:0] bm_s2_s1_i, bm_s2_s3_i, bm_s3_s1_i, bm_s3_s3_i;
reg [7:0] pm_s0_i, pm_s1_i, pm_s2_i, pm_s3_i;

wire [3:0] dec_bits_o;
wire [7:0] pm_s0_o, pm_s1_o, pm_s2_o, pm_s3_o;

// Kh?i ACSU ???c ki?m tra (UUT)
acsu uut (
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

// Kh?i t?o và T?o xung ??u vào
initial begin
    // Kh?i t?o ban ??u
    $display("--- Bat dau kiem tra ACSU ---");
    pm_s0_i = 8'd0; 
    pm_s1_i = 8'd10; 
    pm_s2_i = 8'd20; 
    pm_s3_i = 8'd30;
    
    // ??t BM cho tr??ng h?p 1: D? li?u nh?n ???c r?t gi?ng S0->S0, S2->S1, S0->S2, S2->S3
    // T?c là BM nh? cho các ???ng 0->0, 2->1, 0->2, 2->3
    bm_s0_s0_i = 2'd0; // S0->S0: T?t
    bm_s1_s0_i = 2'd2; // S1->S0: X?u
    
    bm_s2_s1_i = 2'd0; // S2->S1: T?t
    bm_s3_s1_i = 2'd2; // S3->S1: X?u
    
    bm_s0_s2_i = 2'd0; // S0->S2: T?t
    bm_s1_s2_i = 2'd2; // S1->S2: X?u
    
    bm_s2_s3_i = 2'd0; // S2->S3: T?t
    bm_s3_s3_i = 2'd2; // S3->S3: X?u

    #10;
    $display("Thoi gian=%0t | Truong hop 1: Chon duong PM nho", $time);

    // KI?M TRA S0:
    // PM_00 = PM_S0_i (0) + BM_S0_S0_i (0) = 0
    // PM_10 = PM_S1_i (10) + BM_S1_S0_i (2) = 12
    // PM_S0_o = 0. Dec_bit[0] = 0 (chon S0)
    $display("S0: PM_00=%d | PM_10=%d | PM_S0_o=%d (Ky vong 0) | Dec_bit[0]=%b (Ky vong 0)", 
              pm_s0_i + bm_s0_s0_i, pm_s1_i + bm_s1_s0_i, pm_s0_o, dec_bits_o[0]);

    // KI?M TRA S1:
    // PM_21 = PM_S2_i (20) + BM_S2_S1_i (0) = 20
    // PM_31 = PM_S3_i (30) + BM_S3_S1_i (2) = 32
    // PM_S1_o = 20. Dec_bit[1] = 0 (chon S2)
    $display("S1: PM_21=%d | PM_31=%d | PM_S1_o=%d (Ky vong 20) | Dec_bit[1]=%b (Ky vong 0)", 
              pm_s2_i + bm_s2_s1_i, pm_s3_i + bm_s3_s1_i, pm_s1_o, dec_bits_o[1]);
              
    // KI?M TRA S2:
    // PM_02 = PM_S0_i (0) + BM_S0_S2_i (0) = 0
    // PM_12 = PM_S1_i (10) + BM_S1_S2_i (2) = 12
    // PM_S2_o = 0. Dec_bit[2] = 0 (chon S0)
    $display("S2: PM_02=%d | PM_12=%d | PM_S2_o=%d (Ky vong 0) | Dec_bit[2]=%b (Ky vong 0)", 
              pm_s0_i + bm_s0_s2_i, pm_s1_i + bm_s1_s2_i, pm_s2_o, dec_bits_o[2]);
              
    // KI?M TRA S3:20
    // PM_23 = PM_S2_i (20) + BM_S2_S3_i (0) = 20
    // PM_33 = PM_S3_i (30) + BM_S3_S3_i (2) = 32
    // PM_S3_o = 20. Dec_bit[3] = 0 (chon S2)
    $display("S3: PM_23=%d | PM_33=%d | PM_S3_o=%d (Ky vong 20) | Dec_bit[3]=%b (Ky vong 0)", 
              pm_s2_i + bm_s2_s3_i, pm_s3_i + bm_s3_s3_i, pm_s3_o, dec_bits_o[3]);
    
    // --- Tr??ng h?p 2: Chon duong PM lon ---
    #10;
    pm_s0_i = 8'd50; 
    pm_s1_i = 8'd5; // PM_S1 c? nh? h?n PM_S0 c?
    
    // ??t BM: S0->S0 t?t (0), S1->S0 x?u (2)
    bm_s0_s0_i = 2'd0; 
    bm_s1_s0_i = 2'd2; 

    #10;
    $display("\nThoi gian=%0t | Truong hop 2: Chon duong PM lon hon (S1->S0)", $time);
    
    // KI?M TRA S0:
    // PM_00 = PM_S0_i (50) + BM_S0_S0_i (0) = 50
    // PM_10 = PM_S1_i (5) + BM_S1_S0_i (2) = 7 <--- ???C CH?N
    // PM_S0_o = 7. Dec_bit[0] = 1 (chon S1)
    $display("S0: PM_00=%d | PM_10=%d | PM_S0_o=%d (Ky vong 7) | Dec_bit[0]=%b (Ky vong 1)", 
              pm_s0_i + bm_s0_s0_i, pm_s1_i + bm_s1_s0_i, pm_s0_o, dec_bits_o[0]);

    $display("\n--- Ket thuc kiem tra ACSU ---");
    $finish;
end

endmodule
