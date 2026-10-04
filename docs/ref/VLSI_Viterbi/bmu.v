// bmu.v - Block Metric Unit
// Tính toán Chi phí Hamming (Branch Metric)
module bmu (
    input  [1:0] piso_data_i,    // Dữ liệu nhận được (2 bits)
    
    // Đầu ra Chi phí Hamming (2 bits)
    output [1:0] bm_s0_s0_o,
    output [1:0] bm_s0_s2_o,
    output [1:0] bm_s1_s0_o,
    output [1:0] bm_s1_s2_o,
    output [1:0] bm_s2_s1_o,
    output [1:0] bm_s2_s3_o,
    output [1:0] bm_s3_s1_o,
    output [1:0] bm_s3_s3_o
);

// --- Khai báo Codeword Dự kiến (Expected Codewords) ---
parameter C00 = 2'b00; // Expected Codeword cho S0 -> S0
parameter C02 = 2'b11; // Expected Codeword cho S0 -> S2
parameter C10 = 2'b11; // Expected Codeword cho S1 -> S0
parameter C12 = 2'b00; // Expected Codeword cho S1 -> S2
parameter C21 = 2'b10; // Expected Codeword cho S2 -> S1
parameter C23 = 2'b01; // Expected Codeword cho S2 -> S3
parameter C31 = 2'b01; // Expected Codeword cho S3 -> S1
parameter C33 = 2'b10; // Expected Codeword cho S3 -> S3

// --- Khai báo wire trung gian cho kết quả XOR (Hamming Distance) ---
// Mỗi wire có độ rộng 2 bit
wire [1:0] diff_s0_s0 = piso_data_i ^ C00;
wire [1:0] diff_s0_s2 = piso_data_i ^ C02;
wire [1:0] diff_s1_s0 = piso_data_i ^ C10;
wire [1:0] diff_s1_s2 = piso_data_i ^ C12;
wire [1:0] diff_s2_s1 = piso_data_i ^ C21;
wire [1:0] diff_s2_s3 = piso_data_i ^ C23;
wire [1:0] diff_s3_s1 = piso_data_i ^ C31;
wire [1:0] diff_s3_s3 = piso_data_i ^ C33;

// --- Hàm tính toán Chi phí Hamming (Hamming Weight) ---
// Sử dụng phép cộng các bit đơn, nhưng với biến trung gian, giúp trình biên dịch xử lý dễ hơn.

assign bm_s0_s0_o = diff_s0_s0[1] + diff_s0_s0[0];
assign bm_s0_s2_o = diff_s0_s2[1] + diff_s0_s2[0];

assign bm_s1_s0_o = diff_s1_s0[1] + diff_s1_s0[0];
assign bm_s1_s2_o = diff_s1_s2[1] + diff_s1_s2[0];

assign bm_s2_s1_o = diff_s2_s1[1] + diff_s2_s1[0];
assign bm_s2_s3_o = diff_s2_s3[1] + diff_s2_s3[0];

assign bm_s3_s1_o = diff_s3_s1[1] + diff_s3_s1[0];
assign bm_s3_s3_o = diff_s3_s3[1] + diff_s3_s3[0];

endmodule
