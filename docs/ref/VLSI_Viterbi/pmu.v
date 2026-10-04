/*
 * MODULE: pmu
 * CHỨC NĂNG: Path Metric Unit
 * Lưu trữ và quản lý Path Metrics (PM) và Decision Bits
 * KIẾN TRÚC: RAM-based để lưu lịch sử decision bits
 */
module pmu #(
    parameter TBL      = 15,  // Traceback Length
    parameter PM_WIDTH = 8    // Độ rộng bit của Path Metric
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    valid_i,           // Cờ "Ghi" - bắt đầu chu kỳ mới
    
    // Đầu vào từ ACSU (Ghi)
    input  wire [3:0]              dec_bits_i,        // Decision bits [S0, S1, S2, S3]
    input  wire [PM_WIDTH-1:0]    pm_new_s0_i,
    input  wire [PM_WIDTH-1:0]    pm_new_s1_i,
    input  wire [PM_WIDTH-1:0]    pm_new_s2_i,
    input  wire [PM_WIDTH-1:0]    pm_new_s3_i,
    
    // Cổng Đọc Lịch sử (cho TBU)
    input  wire [$clog2(TBL)-1:0] read_addr_i,       // Địa chỉ TBU muốn đọc
    output reg  [3:0]             read_data_o,       // Dữ liệu lịch sử TBU nhận
    
    // Đầu ra PM Hiện tại (cho ACSU & TBU)
    output reg  [PM_WIDTH-1:0]    pm_current_s0_o,
    output reg  [PM_WIDTH-1:0]    pm_current_s1_o,
    output reg  [PM_WIDTH-1:0]    pm_current_s2_o,
    output reg  [PM_WIDTH-1:0]    pm_current_s3_o
);

    // RAM lưu trữ lịch sử Decision Bits
    // Kích thước: TBL x 4 bits
    reg [3:0] decision_history [0:TBL-1];
    
    // Con trỏ ghi (write pointer) - vị trí ghi tiếp theo
    reg [$clog2(TBL)-1:0] write_ptr;
    
    // Thanh ghi lưu Path Metrics hiện tại
    reg [PM_WIDTH-1:0] pm_s0_reg;
    reg [PM_WIDTH-1:0] pm_s1_reg;
    reg [PM_WIDTH-1:0] pm_s2_reg;
    reg [PM_WIDTH-1:0] pm_s3_reg;

    // Khởi tạo
    integer i;
    initial begin
        for (i = 0; i < TBL; i = i + 1) begin
            decision_history[i] = 4'b0;
        end
    end

    // Cập nhật Path Metrics và Decision History
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pm_s0_reg <= {PM_WIDTH{1'b0}};
            pm_s1_reg <= {PM_WIDTH{1'b0}};
            pm_s2_reg <= {PM_WIDTH{1'b0}};
            pm_s3_reg <= {PM_WIDTH{1'b0}};
            write_ptr <= {$clog2(TBL){1'b0}};
            
            for (i = 0; i < TBL; i = i + 1) begin
                decision_history[i] <= 4'b0;
            end
        end
        else begin
            if (valid_i) begin
                // Cập nhật Path Metrics mới từ ACSU
                pm_s0_reg <= pm_new_s0_i;
                pm_s1_reg <= pm_new_s1_i;
                pm_s2_reg <= pm_new_s2_i;
                pm_s3_reg <= pm_new_s3_i;
                
                // Ghi Decision Bits vào RAM (theo kiểu circular buffer)
                decision_history[write_ptr] <= dec_bits_i;
                
                // Tăng con trỏ ghi (circular)
                if (write_ptr == (TBL - 1)) begin
                    write_ptr <= {$clog2(TBL){1'b0}};
                end
                else begin
                    write_ptr <= write_ptr + 1'b1;
                end
            end
        end
    end

    // Đọc Path Metrics hiện tại (combinational)
    always @(*) begin
        pm_current_s0_o = pm_s0_reg;
        pm_current_s1_o = pm_s1_reg;
        pm_current_s2_o = pm_s2_reg;
        pm_current_s3_o = pm_s3_reg;
    end

    // Đọc Decision History (combinational)
    always @(*) begin
        read_data_o = decision_history[read_addr_i];
    end

endmodule

