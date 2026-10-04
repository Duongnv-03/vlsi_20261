module piso (
    input  wire        clk,
    input  wire        rst_n,
    
    // Giao tiep voi FIFO
    input  wire [15:0] fifo_data_i,  // Du lieu tu FIFO
    input  wire        fifo_empty_i, // Co bao FIFO rong
    output reg         fifo_rd_en_o, // Lenh doc gui toi FIFO
    
    // Output toi Viterbi Core
    output reg  [1:0]  data_serial_o,
    output reg         valid_serial_o
);

    reg [15:0] shift_reg;
    reg [3:0]  count;
    
    // FSM States
    localparam IDLE      = 2'b00;
    localparam READ_WAIT = 2'b01; 
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
                    data_serial_o  <= 2'b00;
                    count          <= 4'd0;
                    
                    if (!fifo_empty_i) begin
                        fifo_rd_en_o <= 1'b1;
                        state        <= READ_WAIT;
                    end else begin
                        fifo_rd_en_o <= 1'b0;
                        state        <= IDLE;
                    end
                end

                READ_WAIT: begin
                    fifo_rd_en_o   <= 1'b0; // Ngat lenh doc
                    valid_serial_o <= 1'b1;
                    count          <= 4'd7; 
                    
                    // Lay du lieu va thuc hien luot day dau tien (MSB)
                    data_serial_o  <= fifo_data_i[15:14]; 
                    shift_reg      <= {fifo_data_i[13:0], 2'b00};
                    state          <= SHIFT;
                end

                SHIFT: begin
                    fifo_rd_en_o <= 1'b0; // Dam bao luon tat lenh doc trong khi dich
                    
                    if (count > 0) begin
                        data_serial_o  <= shift_reg[15:14];
                        shift_reg      <= {shift_reg[13:0], 2'b00};
                        valid_serial_o <= 1'b1;
                        count          <= count - 1;
                        state          <= SHIFT;
                    end else begin
                        data_serial_o  <= 2'b00;
                        shift_reg      <= 16'b0;
                        valid_serial_o <= 1'b0;
                        count          <= 4'd0;
                        state          <= IDLE; 
                    end
                end
                
                default: begin
                    state          <= IDLE;
                    fifo_rd_en_o   <= 1'b0;
                    valid_serial_o <= 1'b0;
                    data_serial_o  <= 2'b00;
                    shift_reg      <= 16'b0;
                    count          <= 4'd0;
                end
            endcase
        end
    end
endmodule