// bmu_tb.v - Testbench cho Block Metric Unit
`timescale 1ns / 1ps
`include "../design/bmu.v"

module tb_bmu;

// Khai báo tín hi?u Testbench
reg  [1:0] piso_data_i;

wire [1:0] bm_s0_s0_o;
wire [1:0] bm_s0_s2_o;
wire [1:0] bm_s1_s0_o;
wire [1:0] bm_s1_s2_o;
wire [1:0] bm_s2_s1_o;
wire [1:0] bm_s2_s3_o;
wire [1:0] bm_s3_s1_o;
wire [1:0] bm_s3_s3_o;

// Kh?i BMU ???c ki?m tra (Unit Under Test - UUT)
bmu uut (
    .piso_data_i(piso_data_i),
    .bm_s0_s0_o(bm_s0_s0_o),
    .bm_s0_s2_o(bm_s0_s2_o),
    .bm_s1_s0_o(bm_s1_s0_o),
    .bm_s1_s2_o(bm_s1_s2_o),
    .bm_s2_s1_o(bm_s2_s1_o),
    .bm_s2_s3_o(bm_s2_s3_o),
    .bm_s3_s1_o(bm_s3_s1_o),
    .bm_s3_s3_o(bm_s3_s3_o)
);

// Kh?i t?o và T?o xung ??u vào
initial begin
    // Kh?i t?o ban ??u
    piso_data_i = 2'b00;
    $display("--- Bat dau kiem tra BMU ---");
    #10;

    // --- Kiem tra Truong hop 1: Input = 00 ---
    // Ky vong: Chi phi = 0 cho C=00, Chi phi = 2 cho C=11
    piso_data_i = 2'b00;
    #10;
    $display("Thoi gian=%0t | Input=00", $time);
    $display("S0->S0 (C=00) Chi phi: %d (Ky vong 0)", bm_s0_s0_o);
    $display("S0->S2 (C=11) Chi phi: %d (Ky vong 2)", bm_s0_s2_o);
    $display("S1->S2 (C=00) Chi phi: %d (Ky vong 0)", bm_s1_s2_o);
    $display("S1->S0 (C=11) Chi phi: %d (Ky vong 2)", bm_s1_s0_o);
    
    // --- Kiem tra Truong hop 2: Input = 11 ---
    // Ky vong: Chi phi = 2 cho C=00, Chi phi = 0 cho C=11
    piso_data_i = 2'b11;
    #10;
    $display("\nThoi gian=%0t | Input=11", $time);
    $display("S0->S0 (C=00) Chi phi: %d (Ky vong 2)", bm_s0_s0_o);
    $display("S0->S2 (C=11) Chi phi: %d (Ky vong 0)", bm_s0_s2_o);
    $display("S1->S2 (C=00) Chi phi: %d (Ky vong 2)", bm_s1_s2_o);
    $display("S1->S0 (C=11) Chi phi: %d (Ky vong 0)", bm_s1_s0_o);

    // --- Kiem tra Truong hop 3: Input = 10 ---
    // Kiem tra cac chuyen doi khac: C=10, C=01
    piso_data_i = 2'b10;
    #10;
    $display("\nThoi gian=%0t | Input=10", $time);
    $display("S2->S1 (C=10) Chi phi: %d (Ky vong 0)", bm_s2_s1_o); // 10 ^ 10 = 00 -> 0
    $display("S2->S3 (C=01) Chi phi: %d (Ky vong 2)", bm_s2_s3_o); // 10 ^ 01 = 11 -> 2
    $display("S3->S1 (C=01) Chi phi: %d (Ky vong 2)", bm_s3_s1_o); // 10 ^ 01 = 11 -> 2
    $display("S3->S3 (C=10) Chi phi: %d (Ky vong 0)", bm_s3_s3_o); // 10 ^ 10 = 00 -> 0

    // --- Kiem tra Truong hop 4: Input = 01 ---
    piso_data_i = 2'b01;
    #10;
    $display("\nThoi gian=%0t | Input=01", $time);
    $display("S2->S1 (C=10) Chi phi: %d (Ky vong 2)", bm_s2_s1_o); // 01 ^ 10 = 11 -> 2
    $display("S2->S3 (C=01) Chi phi: %d (Ky vong 0)", bm_s2_s3_o); // 01 ^ 01 = 00 -> 0
    $display("S3->S1 (C=01) Chi phi: %d (Ky vong 0)", bm_s3_s1_o); // 01 ^ 01 = 00 -> 0
    $display("S3->S3 (C=10) Chi phi: %d (Ky vong 2)", bm_s3_s3_o); // 01 ^ 10 = 11 -> 2

    $display("\n--- Ket thuc kiem tra BMU ---");
    $finish;
end

endmodule