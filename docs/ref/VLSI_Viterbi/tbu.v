/*
 * MODULE: tbu
 * CHỨC NĂNG: Traceback Unit
 * Thực hiện thuật toán traceback để giải mã bit thông tin
 * KIẾN TRÚC: Tìm đường đi tốt nhất từ trạng thái có PM nhỏ nhất
 */
module tbu #(
    parameter TBL      = 15,  // Traceback Length
    parameter PM_WIDTH = 8    // Độ rộng bit của Path Metric
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    valid_i,           // Cờ "bắt đầu chặng mới"
    
    // Đầu vào PM Hiện tại (từ PMU)
    input  wire [PM_WIDTH-1:0]    pm_current_s0_i,
    input  wire [PM_WIDTH-1:0]    pm_current_s1_i,
    input  wire [PM_WIDTH-1:0]    pm_current_s2_i,
    input  wire [PM_WIDTH-1:0]    pm_current_s3_i,
    
    // Cổng Đọc Lịch sử (từ PMU)
    input  wire [3:0]             pm_read_data_i,    // Decision bits đọc từ RAM
    output reg  [$clog2(TBL)-1:0] pm_read_addr_o,    // Địa chỉ đọc
    
    // Đầu ra cuối cùng (gửi cho SIPO)
    output reg                    data_serial_o,      // Bit giải mã (1-bit)
    output reg                    valid_serial_o      // Cờ valid
);

    // Trạng thái FSM
    localparam S_IDLE        = 2'b00;
    localparam S_FIND_BEST   = 2'b01;  // Tìm trạng thái tốt nhất
    localparam S_TRACEBACK   = 2'b10;  // Thực hiện traceback
    
    reg [1:0] state;
    
    // Bộ đếm traceback (0 đến TBL-1)
    reg [$clog2(TBL)-1:0] traceback_counter;
    
    // Trạng thái hiện tại trong quá trình traceback
    reg [1:0] current_state;  // 0=S0, 1=S1, 2=S2, 3=S3
    
    // Tìm trạng thái có PM nhỏ nhất
    function [1:0] find_min_state;
        input [PM_WIDTH-1:0] pm0, pm1, pm2, pm3;
        begin
            if ((pm0 <= pm1) && (pm0 <= pm2) && (pm0 <= pm3))
                find_min_state = 2'b00;  // S0
            else if ((pm1 <= pm2) && (pm1 <= pm3))
                find_min_state = 2'b01;  // S1
            else if (pm2 <= pm3)
                find_min_state = 2'b10;  // S2
            else
                find_min_state = 2'b11;  // S3
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state              <= S_IDLE;
            traceback_counter  <= {$clog2(TBL){1'b0}};
            current_state      <= 2'b00;
            pm_read_addr_o     <= {$clog2(TBL){1'b0}};
            data_serial_o      <= 1'b0;
            valid_serial_o     <= 1'b0;
        end
        else begin
            valid_serial_o <= 1'b0; // Mặc định không valid
            
            case (state)
                S_IDLE: begin
                    if (valid_i) begin
                        // Bắt đầu traceback: tìm trạng thái tốt nhất
                        state <= S_FIND_BEST;
                    end
                end
                
                S_FIND_BEST: begin
                    // Tìm trạng thái có PM nhỏ nhất
                    current_state <= find_min_state(
                        pm_current_s0_i,
                        pm_current_s1_i,
                        pm_current_s2_i,
                        pm_current_s3_i
                    );
                    
                    // Tính địa chỉ đọc đầu tiên (circular buffer)
                    // Địa chỉ = (write_ptr - 1) mod TBL
                    // Ở đây ta bắt đầu từ TBL-1 (lùi về quá khứ)
                    pm_read_addr_o <= TBL - 1;
                    traceback_counter <= TBL - 1;
                    state <= S_TRACEBACK;
                end
                
                S_TRACEBACK: begin
                    // Đọc decision bit cho trạng thái hiện tại
                    // Decision bit cho mỗi trạng thái:
                    // - S0: dec_bits[0] -> quyết định từ S0 (0) hay S1 (1)
                    // - S1: dec_bits[1] -> quyết định từ S2 (0) hay S3 (1)
                    // - S2: dec_bits[2] -> quyết định từ S0 (0) hay S1 (1)
                    // - S3: dec_bits[3] -> quyết định từ S2 (0) hay S3 (1)
                    
                    // Bit giải mã = LSB của trạng thái trước đó
                    // Trạng thái trước đó được xác định từ decision bit
                    case (current_state)
                        2'b00: begin // S0
                            data_serial_o <= pm_read_data_i[0]; // Bit quyết định
                            // Nếu dec_bit[0] = 0: từ S0 -> S0 (bit=0)
                            // Nếu dec_bit[0] = 1: từ S1 -> S0 (bit=1)
                            current_state <= pm_read_data_i[0] ? 2'b01 : 2'b00;
                        end
                        2'b01: begin // S1
                            data_serial_o <= pm_read_data_i[1]; // Bit quyết định
                            // Nếu dec_bit[1] = 0: từ S2 -> S1 (bit=0)
                            // Nếu dec_bit[1] = 1: từ S3 -> S1 (bit=1)
                            current_state <= pm_read_data_i[1] ? 2'b11 : 2'b10;
                        end
                        2'b10: begin // S2
                            data_serial_o <= pm_read_data_i[2]; // Bit quyết định
                            // Nếu dec_bit[2] = 0: từ S0 -> S2 (bit=0)
                            // Nếu dec_bit[2] = 1: từ S1 -> S2 (bit=1)
                            current_state <= pm_read_data_i[2] ? 2'b01 : 2'b00;
                        end
                        2'b11: begin // S3
                            data_serial_o <= pm_read_data_i[3]; // Bit quyết định
                            // Nếu dec_bit[3] = 0: từ S2 -> S3 (bit=0)
                            // Nếu dec_bit[3] = 1: từ S3 -> S3 (bit=1)
                            current_state <= pm_read_data_i[3] ? 2'b11 : 2'b10;
                        end
                    endcase
                    
                    valid_serial_o <= 1'b1;
                    
                    // Giảm bộ đếm và địa chỉ đọc
                    if (traceback_counter == 0) begin
                        // Đã traceback xong TBL bước
                        state <= S_IDLE;
                    end
                    else begin
                        traceback_counter <= traceback_counter - 1'b1;
                        // Đọc từ quá khứ (giảm địa chỉ, circular)
                        if (pm_read_addr_o == 0) begin
                            pm_read_addr_o <= TBL - 1;
                        end
                        else begin
                            pm_read_addr_o <= pm_read_addr_o - 1'b1;
                        end
                    end
                end
            endcase
        end
    end

endmodule

