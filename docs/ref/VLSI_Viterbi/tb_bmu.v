// bmu_tb.v - Testbench cho Block Metric Unit
`timescale 1ns / 1ps

module bmu_tb;

// Khai báo tín hiệu Testbench
reg  [1:0] piso_data_i;

wire [1:0] bm_s0_s0_o;
wire [1:0] bm_s0_s2_o;
wire [1:0] bm_s1_s0_o;
wire [1:0] bm_s1_s2_o;
wire [1:0] bm_s2_s1_o;
wire [1:0] bm_s2_s3_o;
wire [1:0] bm_s3_s1_o;
wire [1:0] bm_s3_s3_o;

// Khối BMU được kiểm tra (Unit Under Test - UUT)
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

// Khởi tạo và Tạo xung đầu vào
initial begin
    // Khởi tạo ban đầu
    piso_data_i = 2'b00;
    $display("--- Bắt đầu kiểm tra BMU ---");
    #10;

    // --- Kiểm tra Trường hợp 1: Input = 00 ---
    // Kỳ vọng: Chi phí = 0 cho C=00, Chi phí = 2 cho C=11
    piso_data_i = 2'b00;
    #10;
    $display("Thời gian=%0t | Input=00", $time);
    $display("S0->S0 (C=00) Chi phí: %d (Kỳ vọng 0)", bm_s0_s0_o);
    $display("S0->S2 (C=11) Chi phí: %d (Kỳ vọng 2)", bm_s0_s2_o);
    $display("S1->S2 (C=00) Chi phí: %d (Kỳ vọng 0)", bm_s1_s2_o);
    $display("S1->S0 (C=11) Chi phí: %d (Kỳ vọng 2)", bm_s1_s0_o);
    
    // --- Kiểm tra Trường hợp 2: Input = 11 ---
    // Kỳ vọng: Chi phí = 2 cho C=00, Chi phí = 0 cho C=11
    piso_data_i = 2'b11;
    #10;
    $display("\nThời gian=%0t | Input=11", $time);
    $display("S0->S0 (C=00) Chi phí: %d (Kỳ vọng 2)", bm_s0_s0_o);
    $display("S0->S2 (C=11) Chi phí: %d (Kỳ vọng 0)", bm_s0_s2_o);
    $display("S1->S2 (C=00) Chi phí: %d (Kỳ vọng 2)", bm_s1_s2_o);
    $display("S1->S0 (C=11) Chi phí: %d (Kỳ vọng 0)", bm_s1_s0_o);

    // --- Kiểm tra Trường hợp 3: Input = 10 ---
    // Kiểm tra các chuyển đổi khác: C=10, C=01
    piso_data_i = 2'b10;
    #10;
    $display("\nThời gian=%0t | Input=10", $time);
    $display("S2->S1 (C=10) Chi phí: %d (Kỳ vọng 0)", bm_s2_s1_o); // 10 ^ 10 = 00 -> 0
    $display("S2->S3 (C=01) Chi phí: %d (Kỳ vọng 2)", bm_s2_s3_o); // 10 ^ 01 = 11 -> 2
    $display("S3->S1 (C=01) Chi phí: %d (Kỳ vọng 2)", bm_s3_s1_o); // 10 ^ 01 = 11 -> 2
    $display("S3->S3 (C=10) Chi phí: %d (Kỳ vọng 0)", bm_s3_s3_o); // 10 ^ 10 = 00 -> 0

    // --- Kiểm tra Trường hợp 4: Input = 01 ---
    piso_data_i = 2'b01;
    #10;
    $display("\nThời gian=%0t | Input=01", $time);
    $display("S2->S1 (C=10) Chi phí: %d (Kỳ vọng 2)", bm_s2_s1_o); // 01 ^ 10 = 11 -> 2
    $display("S2->S3 (C=01) Chi phí: %d (Kỳ vọng 0)", bm_s2_s3_o); // 01 ^ 01 = 00 -> 0
    $display("S3->S1 (C=01) Chi phí: %d (Kỳ vọng 0)", bm_s3_s1_o); // 01 ^ 01 = 00 -> 0
    $display("S3->S3 (C=10) Chi phí: %d (Kỳ vọng 2)", bm_s3_s3_o); // 01 ^ 10 = 11 -> 2

    $display("\n--- Kết thúc kiểm tra BMU ---");
    $finish;
end

endmodule
