/*
 * MODULE: sipo
 * CHỨC NĂNG: Serial-In Parallel-Out converter
 * Nhận 1-bit nối tiếp (8 lần), xuất 8-bit song song
 */
module sipo (
    input  wire           clk,
    input  wire           rst_n,
    input  wire           data_serial_i,       // Dữ liệu 1-bit vào (nối tiếp)
    input  wire           valid_serial_i,      // Cờ valid cho mỗi bit
    
    output reg  [7:0]     data_parallel_o,     // Dữ liệu 8-bit ra (song song)
    output reg            byte_ready_o         // Xung báo đã đủ 8-bit
);

    // Thanh ghi dịch để tích lũy 8 bit
    reg [7:0] shift_reg;
    
    // Bộ đếm: 0-7 (8 bit)
    reg [2:0] counter;
    
    // Trạng thái: IDLE hoặc COLLECTING
    reg state;
    localparam S_IDLE       = 1'b0;
    localparam S_COLLECTING = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg      <= 8'b0;
            counter        <= 3'b0;
            state          <= S_IDLE;
            data_parallel_o <= 8'b0;
            byte_ready_o   <= 1'b0;
        end
        else begin
            byte_ready_o <= 1'b0; // Mặc định không ready
            
            case (state)
                S_IDLE: begin
                    if (valid_serial_i) begin
                        // Bắt đầu thu thập bit đầu tiên
                        shift_reg <= {shift_reg[6:0], data_serial_i};
                        counter   <= 3'd1;
                        state     <= S_COLLECTING;
                    end
                end
                
                S_COLLECTING: begin
                    if (valid_serial_i) begin
                        // Dịch trái và thêm bit mới vào LSB
                        shift_reg <= {shift_reg[6:0], data_serial_i};
                        counter   <= counter + 1'b1;
                        
                        if (counter == 3'd7) begin
                            // Đã thu thập đủ 8 bit
                            data_parallel_o <= {shift_reg[6:0], data_serial_i};
                            byte_ready_o    <= 1'b1;
                            counter         <= 3'b0;
                            state           <= S_IDLE;
                        end
                    end
                end
            endcase
        end
    end

endmodule

