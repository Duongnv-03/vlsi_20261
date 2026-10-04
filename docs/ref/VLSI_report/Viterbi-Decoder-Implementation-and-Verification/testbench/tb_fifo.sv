`timescale 1ns/1ps
`include "../design/fifo.v"

module tb_fifo;
    logic clk, rst_n, wr_en, rd_en;
    logic [15:0] din;
    wire  [15:0] dout;
    wire  full, empty;

    fifo #(.WIDTH(16), .DEPTH(4)) dut ( // Test depth nhỏ cho nhanh đầy
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr_en), .din(din), .full(full),
        .rd_en(rd_en), .dout(dout), .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        $display("--- TEST FIFO ---");
        clk = 0; rst_n = 0; wr_en = 0; rd_en = 0; din = 0;
        #15 rst_n = 1;

        // 1. Kiểm tra Empty sau reset
        if(empty === 1) $display("[PASS] Reset -> Empty OK");

        // 2. Ghi 4 gói (Làm đầy)
        $display("[INFO] Filling FIFO...");
        repeat(4) begin
            @(posedge clk);
            wr_en <= 1; din <= din + 1;
        end
        @(posedge clk); wr_en <= 0;
        
        #1;
        if(full === 1) $display("[PASS] FIFO Full OK");

        // 3. Đọc ra
        $display("[INFO] Reading FIFO...");
        @(posedge clk); rd_en <= 1;
        @(posedge clk);
        if(dout === 16'h0001) $display("[PASS] Read Data 1 OK");
        
        $display("--- FIFO TEST DONE ---");
        $finish;
    end
endmodule