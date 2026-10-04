/*
 * MODULE: piso
 * CHỨC NĂNG: Parallel-In Serial-Out converter
 * Chuyển đổi 16-bit song song thành 2-bit nối tiếp (8 lần)
 */
module piso (
    input  wire           clk,
    input  wire           rst_n,
    input  wire           load_i,              // Xung nạp dữ liệu 16-bit
    input  wire [15:0]    data_parallel_i,      // Dữ liệu 16-bit vào
    
    output reg  [1:0]     data_serial_o,       // Dữ liệu 2-bit ra (nối tiếp)
    output reg            valid_serial_o       // Cờ valid cho mỗi 2-bit
);

    // Thanh ghi lưu trữ dữ liệu 16-bit
    reg [15:0] shift_reg;
    
    // Bộ đếm: 0-7 (8 lần xuất 2-bit)
    reg [2:0] counter;
    
    // Trạng thái: IDLE hoặc SHIFTING
    reg state;
    localparam S_IDLE    = 1'b0;
    localparam S_SHIFTING = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg      <= 16'b0;
            counter        <= 3'b0;
            state          <= S_IDLE;
            data_serial_o  <= 2'b0;
            valid_serial_o <= 1'b0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    valid_serial_o <= 1'b0;
                    if (load_i) begin
                        // Nạp dữ liệu 16-bit vào thanh ghi
                        shift_reg <= data_parallel_i;
                        counter   <= 3'b0;
                        state     <= S_SHIFTING;
                    end
                end
                
                S_SHIFTING: begin
                    // Xuất 2-bit từ MSB
                    data_serial_o  <= shift_reg[15:14];
                    valid_serial_o <= 1'b1;
                    
                    // Dịch trái 2 bit
                    shift_reg <= {shift_reg[13:0], 2'b0};
                    
                    // Tăng bộ đếm
                    if (counter == 3'd7) begin
                        // Đã xuất hết 8 lần (16-bit)
                        counter <= 3'b0;
                        state   <= S_IDLE;
                        valid_serial_o <= 1'b0;
                    end
                    else begin
                        counter <= counter + 1'b1;
                    end
                end
            endcase
        end
    end

endmodule

