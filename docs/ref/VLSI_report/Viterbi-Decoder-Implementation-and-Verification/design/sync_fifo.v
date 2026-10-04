module sync_fifo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    
    // Write Interface (Nối với Input bên ngoài)
    input  wire                  wr_en_i,
    input  wire [DATA_WIDTH-1:0] wr_data_i,
    output wire                  full_o,
    
    // Read Interface (Nối với PISO)
    input  wire                  rd_en_i,
    output reg  [DATA_WIDTH-1:0] rd_data_o,
    output wire                  empty_o
);

    // Bộ nhớ RAM
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    
    reg [$clog2(DEPTH)-1:0] wr_ptr;
    reg [$clog2(DEPTH)-1:0] rd_ptr;
    reg [$clog2(DEPTH):0]   count; // Biến đếm số lượng phần tử

    assign full_o  = (count == DEPTH);
    assign empty_o = (count == 0);

    // Write Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en_i && !full_o) begin
            mem[wr_ptr] <= wr_data_i;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            rd_data_o <= 0;
        end else if (rd_en_i && !empty_o) begin
            rd_data_o <= mem[rd_ptr]; // Đọc dữ liệu ra
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Count Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            case ({wr_en_i && !full_o, rd_en_i && !empty_o})
                2'b10: count <= count + 1; // Chỉ Ghi
                2'b01: count <= count - 1; // Chỉ Đọc
                2'b11: count <= count;     // Vừa Ghi vừa Đọc
            endcase
        end
    end

endmodule
