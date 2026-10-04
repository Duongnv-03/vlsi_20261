// ascu.v - Add-Compare-Select Unit
// Thực hiện bước đệ quy chính của thuật toán Viterbi

module ascu (
    // Đầu vào Chi phí Nhánh (Branch Metric) từ BMU
    input [1:0] bm_s0_s0_i,
    input [1:0] bm_s0_s2_i,
    input [1:0] bm_s1_s0_i,
    input [1:0] bm_s1_s2_i,
    input [1:0] bm_s2_s1_i,
    input [1:0] bm_s2_s3_i,
    input [1:0] bm_s3_s1_i,
    input [1:0] bm_s3_s3_i,
    
    // Đầu vào Tổng Chi phí (Path Metric) cũ từ PMU
    input [7:0] pm_s0_i,
    input [7:0] pm_s1_i,
    input [7:0] pm_s2_i,
    input [7:0] pm_s3_i,
    
    // Đầu ra Bit Quyết định (Decision Bit) cho PMU
    output [3:0] dec_bits_o,
    
    // Đầu ra Tổng Chi phí (Path Metric) MỚI cho PMU
    output [7:0] pm_s0_o,
    output [7:0] pm_s1_o,
    output [7:0] pm_s2_o,
    output [7:0] pm_s3_o
);

// Khai báo dây (wire) trung gian cho các phép cộng (Add)
// Kết quả cộng (BM + PM cũ) có thể lên tới 8 bit + 2 bit, nên dùng 9 bit để an toàn
wire [8:0] pm_00, pm_10; // Chi phí đường đến S0
wire [8:0] pm_21, pm_31; // Chi phí đường đến S1
wire [8:0] pm_02, pm_12; // Chi phí đường đến S2
wire [8:0] pm_23, pm_33; // Chi phí đường đến S3

// --- 1. Phép Cộng (ADD) ---
// Tính Chi phí đường dẫn cho tất cả các chuyển đổi có thể có
// Lưu ý: Mở rộng bm_..._i từ 2 bit lên 9 bit bằng 0 để phép cộng chính xác
assign pm_00 = {7'b0, bm_s0_s0_i} + pm_s0_i; 
assign pm_10 = {7'b0, bm_s1_s0_i} + pm_s1_i;

assign pm_21 = {7'b0, bm_s2_s1_i} + pm_s2_i;
assign pm_31 = {7'b0, bm_s3_s1_i} + pm_s3_i;

assign pm_02 = {7'b0, bm_s0_s2_i} + pm_s0_i;
assign pm_12 = {7'b0, bm_s1_s2_i} + pm_s1_i;

assign pm_23 = {7'b0, bm_s2_s3_i} + pm_s2_i;
assign pm_33 = {7'b0, bm_s3_s3_i} + pm_s3_i;


// --- 2. Phép So sánh và Chọn (COMPARE & SELECT) ---
// Đồng thời xác định PM mới và Bit Quyết định (Decision Bit)
// Bit Quyết định: 0 nếu PM_A được chọn, 1 nếu PM_B được chọn (quy ước có thể tùy chỉnh)

// Cập nhật S0 (Từ S0 hoặc S1)
assign pm_s0_o  = (pm_00 <= pm_10) ? pm_00[7:0] : pm_10[7:0];
assign dec_bits_o[0] = (pm_00 <= pm_10) ? 1'b0 : 1'b1; // 0 nếu chọn từ S0, 1 nếu chọn từ S1

// Cập nhật S1 (Từ S2 hoặc S3)
assign pm_s1_o  = (pm_21 <= pm_31) ? pm_21[7:0] : pm_31[7:0];
assign dec_bits_o[1] = (pm_21 <= pm_31) ? 1'b0 : 1'b1; // 0 nếu chọn từ S2, 1 nếu chọn từ S3

// Cập nhật S2 (Từ S0 hoặc S1)
assign pm_s2_o  = (pm_02 <= pm_12) ? pm_02[7:0] : pm_12[7:0];
assign dec_bits_o[2] = (pm_02 <= pm_12) ? 1'b0 : 1'b1; // 0 nếu chọn từ S0, 1 nếu chọn từ S1

// Cập nhật S3 (Từ S2 hoặc S3)
assign pm_s3_o  = (pm_23 <= pm_33) ? pm_23[7:0] : pm_33[7:0];
assign dec_bits_o[3] = (pm_23 <= pm_33) ? 1'b0 : 1'b1; // 0 nếu chọn từ S2, 1 nếu chọn từ S3

endmodule
