module piso (
    input  wire        clk,
    input  wire        rst_n,
    
    // Giao tiếp với FIFO
    input  wire [15:0] fifo_data_i,  // Dữ liệu từ FIFO
    input  wire        fifo_empty_i, // Cờ báo FIFO rỗng
    output reg         fifo_rd_en_o, // Lệnh đọc gửi tới FIFO
    
    // Output tới Viterbi Core
    output reg  [1:0]  data_serial_o,
    output reg         valid_serial_o
);

    reg [15:0] shift_reg;
    reg [3:0]  count;
    
    // FSM States
    localparam IDLE      = 2'b00;
    localparam READ_WAIT = 2'b01; // Đợi RAM của FIFO phản hồi (1 clock latency)
    localparam SHIFT     = 2'b10;
    
    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= IDLE;
            shift_reg      <= 16'b0;
            data_serial_o  <= 2'b00;
            valid_serial_o <= 1'b0;
            fifo_rd_en_o   <= 1'b0;
            count          <= 4'd0;
        end else begin
            case (state)
                IDLE: begin
                    valid_serial_o <= 1'b0;
                    // Nếu FIFO không rỗng, yêu cầu đọc
                    if (!fifo_empty_i) begin
                        fifo_rd_en_o <= 1'b1;
                        state <= READ_WAIT;
                    end
                end

                READ_WAIT: begin
                    // Ngắt lệnh đọc (chỉ cần xung 1 clock)
                    fifo_rd_en_o <= 1'b0;
                    
                    // Dữ liệu từ FIFO đã có ở fifo_data_i tại clock này
                    shift_reg <= fifo_data_i; 
                    
                    // Bắt đầu shift ngay lập tức để không lãng phí clock
                    // Output 2 bit đầu tiên (MSB)
                    data_serial_o  <= fifo_data_i[15:14]; 
                    shift_reg      <= {fifo_data_i[13:0], 2'b00}; // Shift chuẩn bị cho vòng sau
                    
                    valid_serial_o <= 1'b1;
                    count          <= 4'd7; // Còn 7 lần shift nữa (tổng 8 lần)
                    state          <= SHIFT;
                end

                SHIFT: begin
                    fifo_rd_en_o <= 1'b0;
                    if (count > 0) begin
                        data_serial_o  <= shift_reg[15:14];
                        shift_reg      <= {shift_reg[13:0], 2'b00};
                        valid_serial_o <= 1'b1;
                        count          <= count - 1;
                    end else begin
                        // Đã shift xong 16 bit
                        valid_serial_o <= 1'b0;
                        state          <= IDLE; 
                        // Có thể check ngay (!fifo_empty_i) ở đây để pipeline, 
                        // nhưng về IDLE cho an toàn logic trước.
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
