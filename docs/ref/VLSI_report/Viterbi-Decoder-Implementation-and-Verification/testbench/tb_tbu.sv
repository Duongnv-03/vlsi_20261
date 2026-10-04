`timescale 1ns/1ps
`include "../design/tbu.v"

module tb_tbu;

    parameter TBL      = 15;
    parameter PM_WIDTH = 8;

    logic clk, rst_n, valid_i;
    wire  busy_o; // Cổng mới
    
    // Inputs giả lập từ PMU -> TBU
    logic [PM_WIDTH-1:0] pm_s0, pm_s1, pm_s2, pm_s3;
    logic [3:0]          pm_read_data;
    
    // Outputs từ TBU -> PMU
    wire [$clog2(TBL)-1:0] pm_read_addr;
    
    // Result
    wire data_serial, valid_serial;

    // Bộ nhớ RAM ảo để test
    logic [3:0] virtual_ram [0:TBL-1];

    tbu #(.TBL(TBL), .PM_WIDTH(PM_WIDTH)) dut (
        .clk(clk), .rst_n(rst_n),
        .valid_i(valid_i), .busy_o(busy_o), // Kết nối busy_o
        .pm_current_s0_i(pm_s0), .pm_current_s1_i(pm_s1),
        .pm_current_s2_i(pm_s2), .pm_current_s3_i(pm_s3),
        .pm_read_data_i(pm_read_data),
        .pm_read_addr_o(pm_read_addr),
        .data_serial_o(data_serial), .valid_serial_o(valid_serial)
    );

    // Clock
    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    // Giả lập phản hồi của RAM (Latency = 1 clock)
    always @(posedge clk) begin
        pm_read_data <= virtual_ram[pm_read_addr];
    end

    initial begin
        $display("========================================");
        $display("       TESTING TBU MODULE");
        $display("========================================");
        
        // 1. Init & Reset
        rst_n = 0; valid_i = 0;
        {pm_s0, pm_s1, pm_s2, pm_s3} = 0;
        // Điền RAM ảo toàn số 0 (nghĩa là đường về luôn chọn nhánh 0)
        for(int i=0; i<TBL; i++) virtual_ram[i] = 4'b0000;
        
        #20 rst_n = 1; #10;

        // 2. Warm-up Phase (Nạp 15 mẫu để kích hoạt Busy)
        $display("[TEST] Warming up (Filling Latency Buffer)...");
        repeat(TBL) begin
            @(posedge clk); valid_i = 1;
            @(posedge clk); valid_i = 0;
        end
        
        // Kiểm tra xem Busy đã bật chưa (đáng lẽ chưa, mẫu thứ 16 mới bật)
        #1;
        if(busy_o === 0) $display("[INFO] Warm-up done. Ready to trigger.");

        // 3. Trigger Traceback
        $display("[TEST] Triggering Traceback...");
        // Setup Min Path: Chọn S0 nhỏ nhất (pm_s0=0, các cái khác lớn)
        pm_s0 = 0; pm_s1 = 255; pm_s2 = 255; pm_s3 = 255;
        
        @(posedge clk); valid_i = 1; 
        #1; // Delay check
        if(busy_o === 1) $display("[PASS] Busy asserted correctly.");
        else $error("[FAIL] Busy did not assert!");
        
        @(posedge clk); valid_i = 0;

        // 4. Wait for Result
        $display("[INFO] Waiting for result...");
        wait(valid_serial == 1);
        
        // Với RAM toàn 0 và bắt đầu từ S0 -> Kết quả giải mã phải là 0
        if(data_serial === 0) 
            $display("[PASS] Correctly decoded bit 0.");
        else 
            $error("[FAIL] Decoded wrong bit!");

        // 5. Check Busy Release
        @(posedge clk);
        if(busy_o === 0) $display("[PASS] Busy released correctly.");

        $display("========================================");
        $finish;
    end
endmodule