module sync_fifo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 16
)(
    input  wire                    clk,
    input  wire                    rst_n,
    
    // Write Interface
    input  wire                    wr_en_i,
    input  wire [DATA_WIDTH-1:0] wr_data_i,
    output wire                    full_o,
    
    // Read Interface
    input  wire                    rd_en_i,
    output reg  [DATA_WIDTH-1:0] rd_data_o,
    output wire                    empty_o
);

    // Bo nho RAM
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    
    reg [$clog2(DEPTH)-1:0] wr_ptr;
    reg [$clog2(DEPTH)-1:0] rd_ptr;
    reg [$clog2(DEPTH):0]   count;

    assign full_o  = (count == DEPTH);
    assign empty_o = (count == 0);

    // Write Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en_i && !full_o) begin
            mem[wr_ptr] <= wr_data_i;
            wr_ptr <= wr_ptr + 1;
        end else begin
            // Giu nguyen gia tri khi khong ghi
            wr_ptr <= wr_ptr;
        end
    end

    // Read Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            rd_data_o <= 0;
        end else if (rd_en_i && !empty_o) begin
            rd_data_o <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end else begin
            // Giu nguyen gia tri khi khong doc
            rd_ptr <= rd_ptr;
            rd_data_o <= rd_data_o;
        end
    end

    // Count Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            case ({wr_en_i && !full_o, rd_en_i && !empty_o})
                2'b10: count <= count + 1; // Chi Ghi
                2'b01: count <= count - 1; // Chi Doc
                2'b11: count <= count;     // Vua Ghi vua Doc
                2'b00: count <= count;     // Khong Ghi khong Doc
                default: count <= count;   // Dam bao cover moi truong hop (X, Z)
            endcase
        end
    end

endmodule