module sipo (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       data_serial_i,  // Bit từ TBU
    input  wire       valid_serial_i, // Cờ valid từ TBU
    output reg [7:0]  data_parallel_o,
    output reg        byte_ready_o    // Báo đã đủ 8 bit
);

    reg [2:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_parallel_o <= 8'b0;
            byte_ready_o    <= 1'b0;
            count           <= 3'b0;
        end else begin
            byte_ready_o <= 1'b0; // Mặc định mức thấp
            if (valid_serial_i) begin
                // Lưu ý: Traceback thường trả về bit theo thứ tự ngược (mới nhất -> cũ nhất)
                // Hoặc xuôi tuỳ vào cách TBU bắn ra.
                // Ở TBU trên ta trace từ cuối về đầu -> Bit nhận được là bit cuối cùng của gói (LSB hay MSB tuỳ endian).
                // Giả sử ta dịch bit vào từ MSB đến LSB hoặc ngược lại.
                // Để đúng thứ tự gói tin gốc (thường gửi bit 0 trước), và TBU trả bit 7 trước...
                // Ta shift right:
                data_parallel_o <= {data_serial_i, data_parallel_o[7:1]}; 
                
                count <= count + 1;
                if (count == 3'd7) begin
                    byte_ready_o <= 1'b1;
                end
            end
        end
    end

endmodule
