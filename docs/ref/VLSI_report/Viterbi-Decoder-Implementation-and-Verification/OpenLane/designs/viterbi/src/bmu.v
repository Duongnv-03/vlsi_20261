module bmu (
    input  wire [1:0] piso_data_i, // 2 bit lỗi từ PISO [cite: 85]
    
    // Các chi phí nhánh (Branch Metrics) [cite: 85-86]
    output wire [1:0] bm_s0_s0_o, // Exp: 00
    output wire [1:0] bm_s0_s2_o, // Exp: 11
    output wire [1:0] bm_s1_s0_o, // Exp: 11
    output wire [1:0] bm_s1_s2_o, // Exp: 00
    output wire [1:0] bm_s2_s1_o, // Exp: 10
    output wire [1:0] bm_s2_s3_o, // Exp: 01
    output wire [1:0] bm_s3_s1_o, // Exp: 01
    output wire [1:0] bm_s3_s3_o  // Exp: 10
);

    // Hàm tính Hamming Distance: Đếm số bit khác nhau
    function [1:0] hamming_dist;
        input [1:0] in_bits;
        input [1:0] exp_bits;
        begin
            hamming_dist = (in_bits[0] ^ exp_bits[0]) + (in_bits[1] ^ exp_bits[1]);
        end
    endfunction

    // Gán giá trị dựa trên bảng [cite: 82-83]
    assign bm_s0_s0_o = hamming_dist(piso_data_i, 2'b00);
    assign bm_s0_s2_o = hamming_dist(piso_data_i, 2'b11);
    
    assign bm_s1_s0_o = hamming_dist(piso_data_i, 2'b11);
    assign bm_s1_s2_o = hamming_dist(piso_data_i, 2'b00);
    
    assign bm_s2_s1_o = hamming_dist(piso_data_i, 2'b10);
    assign bm_s2_s3_o = hamming_dist(piso_data_i, 2'b01);
    
    assign bm_s3_s1_o = hamming_dist(piso_data_i, 2'b01);
    assign bm_s3_s3_o = hamming_dist(piso_data_i, 2'b10);

endmodule
