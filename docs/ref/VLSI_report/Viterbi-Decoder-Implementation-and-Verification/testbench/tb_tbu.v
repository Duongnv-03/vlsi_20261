// tb_tbu.v - Testbench cho Traceback Unit
`timescale 1ns / 1ps
`include "../design/tbu.v"
`include "../design/pmu.v"

module tb_tbu;

// Khai báo tín hiệu Testbench
reg clk;
reg rst_n;
reg valid_i;

// Tín hiệu PMU (mô phỏng hoặc instantiate)
reg [3:0] dec_bits_pmu;  // Decision bits từ ACSU (ghi vào PMU)
reg [7:0] pm_new_s0, pm_new_s1, pm_new_s2, pm_new_s3;  // PM mới từ ACSU
reg pmu_valid_i;  // Cờ ghi vào PMU

// Tín hiệu TBU
wire [7:0] pm_current_s0, pm_current_s1, pm_current_s2, pm_current_s3;
wire [3:0] pm_read_data;  // Decision bits đọc từ PMU
wire [3:0] pm_read_addr;  // Địa chỉ đọc từ TBU
wire data_serial_o;
wire valid_serial_o;

// Instantiate PMU
pmu #(
    .TBL(15),
    .PM_WIDTH(8)
) pmu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_i(pmu_valid_i),
    .dec_bits_i(dec_bits_pmu),
    .pm_new_s0_i(pm_new_s0),
    .pm_new_s1_i(pm_new_s1),
    .pm_new_s2_i(pm_new_s2),
    .pm_new_s3_i(pm_new_s3),
    .read_addr_i(pm_read_addr),
    .read_data_o(pm_read_data),
    .pm_current_s0_o(pm_current_s0),
    .pm_current_s1_o(pm_current_s1),
    .pm_current_s2_o(pm_current_s2),
    .pm_current_s3_o(pm_current_s3)
);

// Khối TBU được kiểm tra (UUT)
tbu #(
    .TBL(15),
    .PM_WIDTH(8)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .valid_i(valid_i),
    .pm_current_s0_i(pm_current_s0),
    .pm_current_s1_i(pm_current_s1),
    .pm_current_s2_i(pm_current_s2),
    .pm_current_s3_i(pm_current_s3),
    .pm_read_data_i(pm_read_data),
    .pm_read_addr_o(pm_read_addr),
    .data_serial_o(data_serial_o),
    .valid_serial_o(valid_serial_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz (10ns period)
end

// Reset generation
initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
end

// Test stimulus
integer i;
reg [3:0] expected_dec_bits [0:14];  // Lưu decision bits để kiểm tra
reg [7:0] expected_output_bits [0:14];  // Lưu bit giải mã kỳ vọng

initial begin
    $display("========================================");
    $display("--- Bắt đầu kiểm tra TBU ---");
    $display("========================================\n");
    
    // Khởi tạo
    valid_i = 0;
    pmu_valid_i = 0;
    dec_bits_pmu = 4'b0;
    pm_new_s0 = 8'd0;
    pm_new_s1 = 8'd0;
    pm_new_s2 = 8'd0;
    pm_new_s3 = 8'd0;
    
    // Đợi reset xong
    wait(rst_n);
    #20;
    
    // ============================================
    // TEST CASE 1: Tìm trạng thái tốt nhất (S0 có PM nhỏ nhất)
    // ============================================
    $display("--- TEST CASE 1: Tìm trạng thái tốt nhất (S0) ---");
    
    // Thiết lập PM: S0 có PM nhỏ nhất
    pm_new_s0 = 8'd5;
    pm_new_s1 = 8'd10;
    pm_new_s2 = 8'd15;
    pm_new_s3 = 8'd20;
    dec_bits_pmu = 4'b0000;  // Không quan trọng cho test này
    pmu_valid_i = 1;
    #10;
    pmu_valid_i = 0;
    #10;
    
    // Kích hoạt TBU
    $display("Thời gian=%0t: Kích hoạt TBU với PM: S0=%d, S1=%d, S2=%d, S3=%d", 
             $time, pm_current_s0, pm_current_s1, pm_current_s2, pm_current_s3);
    valid_i = 1;
    #10;
    valid_i = 0;
    
    // Đợi TBU tìm trạng thái tốt nhất (1 clock cycle)
    #10;
    $display("Thời gian=%0t: TBU đã vào trạng thái FIND_BEST", $time);
    $display("  Kỳ vọng: Chọn S0 (PM=%d là nhỏ nhất)", pm_current_s0);
    
    // ============================================
    // TEST CASE 2: Traceback với decision history đã biết
    // ============================================
    $display("\n--- TEST CASE 2: Traceback với decision history ---");
    
    // Reset lại PMU và TBU
    rst_n = 0;
    #10;
    rst_n = 1;
    #20;
    
    // Tạo một chuỗi decision bits đã biết
    // Giả sử ta muốn traceback từ S0 với các decision bits:
    // TBL-1: dec_bits = 4'b0000 (tất cả chọn đường đầu tiên)
    // TBL-2: dec_bits = 4'b0000
    // ...
    // 0:     dec_bits = 4'b0000
    
    // Ghi TBL lần decision bits vào PMU
    for (i = 0; i < 15; i = i + 1) begin
        dec_bits_pmu = 4'b0000;  // Tất cả chọn đường đầu tiên
        expected_dec_bits[i] = 4'b0000;
        // Tính bit giải mã kỳ vọng:
        // Nếu traceback từ S0 với dec_bit[0]=0: từ S0->S0, bit=0
        expected_output_bits[i] = 1'b0;
        
        pm_new_s0 = 8'd0 + i;  // PM tăng dần
        pm_new_s1 = 8'd10 + i;
        pm_new_s2 = 8'd20 + i;
        pm_new_s3 = 8'd30 + i;
        
        pmu_valid_i = 1;
        #10;
        pmu_valid_i = 0;
        #10;
    end
    
    // Thiết lập PM cuối cùng: S0 có PM nhỏ nhất
    pm_new_s0 = 8'd0;
    pm_new_s1 = 8'd10;
    pm_new_s2 = 8'd20;
    pm_new_s3 = 8'd30;
    pmu_valid_i = 1;
    #10;
    pmu_valid_i = 0;
    #10;
    
    $display("Thời gian=%0t: Đã ghi %0d decision bits vào PMU", $time, 15);
    $display("  Decision bits: Tất cả = 4'b0000");
    $display("  PM cuối: S0=%d, S1=%d, S2=%d, S3=%d", 
             pm_current_s0, pm_current_s1, pm_current_s2, pm_current_s3);
    
    // Kích hoạt TBU
    valid_i = 1;
    #10;
    valid_i = 0;
    
    // Đợi TBU traceback TBL bước
    $display("\nBắt đầu traceback...");
    for (i = 0; i < 15; i = i + 1) begin
        wait(valid_serial_o);
        $display("  Clock %0d: data_serial_o=%b (Kỳ vọng %b) | addr=%0d", 
                 i, data_serial_o, expected_output_bits[14-i], pm_read_addr);
        #10;  // Đợi 1 clock cycle
    end
    
    // ============================================
    // TEST CASE 3: Traceback với decision bits khác nhau
    // ============================================
    $display("\n--- TEST CASE 3: Traceback với decision bits khác nhau ---");
    
    // Reset lại
    rst_n = 0;
    #10;
    rst_n = 1;
    #20;
    
    // Ghi decision bits với pattern khác nhau
    // Pattern: dec_bits = 4'b1010 (S0 chọn S1, S1 chọn S3, S2 chọn S1, S3 chọn S3)
    for (i = 0; i < 15; i = i + 1) begin
        dec_bits_pmu = 4'b1010;
        expected_dec_bits[i] = 4'b1010;
        // Tính bit giải mã:
        // Nếu traceback từ S0 với dec_bit[0]=1: từ S1->S0, bit=1
        // Nếu traceback từ S1 với dec_bit[1]=0: từ S2->S1, bit=0
        // Nếu traceback từ S2 với dec_bit[2]=1: từ S1->S2, bit=1
        // Nếu traceback từ S3 với dec_bit[3]=0: từ S2->S3, bit=0
        // Với pattern 4'b1010, nếu bắt đầu từ S0:
        // - S0: dec[0]=1 -> từ S1, bit=1, next_state=S1
        // - S1: dec[1]=0 -> từ S2, bit=0, next_state=S2
        // - S2: dec[2]=1 -> từ S1, bit=1, next_state=S1
        // - S1: dec[1]=0 -> từ S2, bit=0, next_state=S2
        // Pattern lặp lại: 1, 0, 1, 0, ...
        expected_output_bits[i] = (i % 2 == 0) ? 1'b1 : 1'b0;
        
        pm_new_s0 = 8'd0;
        pm_new_s1 = 8'd5;   // S1 có PM nhỏ nhất
        pm_new_s2 = 8'd10;
        pm_new_s3 = 8'd15;
        
        pmu_valid_i = 1;
        #10;
        pmu_valid_i = 0;
        #10;
    end
    
    // PM cuối: S1 có PM nhỏ nhất
    pm_new_s0 = 8'd10;
    pm_new_s1 = 8'd5;   // S1 nhỏ nhất
    pm_new_s2 = 8'd15;
    pm_new_s3 = 8'd20;
    pmu_valid_i = 1;
    #10;
    pmu_valid_i = 0;
    #10;
    
    $display("Thời gian=%0t: Đã ghi decision bits = 4'b1010 vào PMU", $time);
    $display("  PM cuối: S0=%d, S1=%d (nhỏ nhất), S2=%d, S3=%d", 
             pm_current_s0, pm_current_s1, pm_current_s2, pm_current_s3);
    
    // Kích hoạt TBU
    valid_i = 1;
    #10;
    valid_i = 0;
    
    // Đợi TBU traceback
    $display("\nBắt đầu traceback từ S1...");
    for (i = 0; i < 15; i = i + 1) begin
        wait(valid_serial_o);
        $display("  Clock %0d: data_serial_o=%b (Kỳ vọng %b) | addr=%0d", 
                 i, data_serial_o, expected_output_bits[14-i], pm_read_addr);
        #10;
    end
    
    // ============================================
    // TEST CASE 4: Kiểm tra tất cả trạng thái có PM bằng nhau
    // ============================================
    $display("\n--- TEST CASE 4: Tất cả PM bằng nhau ---");
    
    rst_n = 0;
    #10;
    rst_n = 1;
    #20;
    
    // Ghi một số decision bits
    for (i = 0; i < 5; i = i + 1) begin
        dec_bits_pmu = 4'b0000;
        pm_new_s0 = 8'd10;
        pm_new_s1 = 8'd10;
        pm_new_s2 = 8'd10;
        pm_new_s3 = 8'd10;
        pmu_valid_i = 1;
        #10;
        pmu_valid_i = 0;
        #10;
    end
    
    // PM cuối: Tất cả bằng nhau
    pm_new_s0 = 8'd10;
    pm_new_s1 = 8'd10;
    pm_new_s2 = 8'd10;
    pm_new_s3 = 8'd10;
    pmu_valid_i = 1;
    #10;
    pmu_valid_i = 0;
    #10;
    
    $display("Thời gian=%0t: Tất cả PM = %d", $time, pm_current_s0);
    
    valid_i = 1;
    #10;
    valid_i = 0;
    
    // Đợi tìm trạng thái tốt nhất (theo logic, sẽ chọn S0)
    #10;
    $display("  Kỳ vọng: Chọn S0 (theo thứ tự ưu tiên)");
    
    $display("\n========================================");
    $display("--- Kết thúc kiểm tra TBU ---");
    $display("========================================");
    
    #100;
    $finish;
end

// Monitor để theo dõi trạng thái TBU
always @(posedge clk) begin
    if (valid_serial_o) begin
        $display("[Monitor] Time=%0t: TBU output bit=%b, addr=%0d", 
                 $time, data_serial_o, pm_read_addr);
    end
end

endmodule

