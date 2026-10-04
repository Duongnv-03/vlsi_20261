`timescale 1ns/1ps

// Chú ý: Không include file .v ở đây nếu  biên dịch bằng lệnh iverilog có kèm file design
`include "../design/piso.v" 

module tb_piso;

    // ============================================================
    // 1. CẤU HÌNH & TÍN HIỆU
    // ============================================================
    parameter TBL = 15; 
    parameter CLK_PERIOD = 10;
    parameter EXPECTED_GAP_CYCLES = TBL + 2; 

    logic        clk;
    logic        rst_n;
    logic        load_i;
    logic [15:0] data_parallel_i;
    logic [1:0]  data_serial_o;
    logic        valid_serial_o;

    int          error_count = 0;
    logic [1:0]  expected_queue [$]; 

    // Kết nối DUT
    piso #(.TBL(TBL)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .load_i(load_i),
        .data_parallel_i(data_parallel_i),
        .data_serial_o(data_serial_o),
        .valid_serial_o(valid_serial_o)
    );

    // Tạo Clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ============================================================
    // 2. TASKS HỖ TRỢ
    // ============================================================

    task apply_reset();
        rst_n = 0; load_i = 0; data_parallel_i = 0;
        expected_queue.delete(); // Xóa sạch hàng đợi cũ
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);
    endtask

    // Task nạp dữ liệu (kèm nạp vào hàng đợi mong đợi)
    task drive_data(input logic [15:0] data);
        int i;
        $display("[DRIVER] Loading Data: 0x%h", data);
        
        // Nạp Queue MSB First (Từ 7 về 0) cho đúng logic thiết kế
        for (i = 7; i >= 0; i--) begin
            expected_queue.push_back(data[2*i +: 2]); 
        end

        @(posedge clk);
        data_parallel_i <= data;
        load_i          <= 1;
        @(posedge clk);
        load_i          <= 0;
    endtask

    // Task Monitor (Trọng tài kiểm tra Data & Timing)
    task monitor_check_packet();
        int bit_idx;
        realtime last_valid_time;
        realtime current_time;
        realtime time_diff;
        logic [1:0] expected_val;

        last_valid_time = $realtime;

        for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
            // 1. Chờ Valid lên 1
            fork : wait_valid
                begin
                    wait(valid_serial_o == 1);
                end
                begin
                    #((EXPECTED_GAP_CYCLES + 50) * CLK_PERIOD); 
                    $error("\033[1;31m[FAIL] Timeout at Idx %0d\033[0m", bit_idx);
                    error_count++;
                    disable wait_valid;
                end
            join_any
            disable wait_valid;

            // 2. Check Data
            if (expected_queue.size() > 0) begin
                expected_val = expected_queue.pop_front();
                if (data_serial_o !== expected_val) begin
                    $error("\033[1;31m[DATA FAIL]\033[0m Idx %0d: Exp=%b Act=%b", bit_idx, expected_val, data_serial_o);
                    error_count++;
                end else begin
                    $display("\033[1;32m[OK] Data match: %b\033[0m", data_serial_o); // Uncomment nếu muốn log chi tiết
                end
            end

            // 3. Check Timing (TC_02)
            if (bit_idx > 0) begin
                current_time = $realtime;
                time_diff = current_time - last_valid_time;
                
                // Cho phép sai số nhỏ +/- 1ns
                if (time_diff < ((EXPECTED_GAP_CYCLES * CLK_PERIOD) - 1) || 
                    time_diff > ((EXPECTED_GAP_CYCLES * CLK_PERIOD) + 1)) begin
                    $error("\033[1;31m[TIMING FAIL]\033[0m Gap: %0t ns (Exp: %0d ns)", time_diff, EXPECTED_GAP_CYCLES*CLK_PERIOD);
                    error_count++;
                end
                last_valid_time = current_time;
            end else begin
                last_valid_time = $realtime;
            end

            // Chờ Valid xuống 0 để tránh đọc nhầm
            @(posedge clk);
            wait(valid_serial_o == 0); 
        end
    endtask

    // ============================================================
    // 3. MAIN TEST (KỊCH BẢN THEO ẢNH)
    // ============================================================
    initial begin
        $display("==================================================");
        $display(" STARTING PISO TESTBENCH (TC_01 -> TC_05)");
        $display("==================================================");

        apply_reset();

        // ------------------------------------------------------------
        // TC_01: Basic Transfer (0xABCD)
        // ------------------------------------------------------------
        $display("\n--- TC_01: Basic Transfer (0xABCD) ---");
        drive_data(16'hABCD); 
        monitor_check_packet(); // Kiểm tra đủ 8 cặp bit
        $display("-> TC_01 Finished.");
        
        #200; // Nghỉ giữa các bài test

        // ------------------------------------------------------------
        // TC_02: Timing Check (0xFFFF)
        // ------------------------------------------------------------
        $display("\n--- TC_02: Timing Check (0xFFFF) ---");
        // Task monitor_check_packet đã tích hợp sẵn việc đo Timing Gap
        // Nếu nó không báo lỗi [TIMING FAIL] nghĩa là TC này PASS
        drive_data(16'hFFFF);
        monitor_check_packet();
        $display("-> TC_02 Finished.");

        #200;

        // ------------------------------------------------------------
        // TC_03: Busy Ignore (0x1111 -> Chèn 0x2222)
        // ------------------------------------------------------------
        $display("\n--- TC_03: Busy Ignore (Input 0x1111, Inject 0x2222) ---");
        // Bước 1: Nạp 0x1111 (Hàng chuẩn)
        drive_data(16'h1111);
        
        // Bước 2: Chạy song song 2 luồng
        fork
            begin
                // Luồng 1: Giám sát xem đầu ra có đúng là 0x1111 không
                monitor_check_packet();
            end
            begin
                // Luồng 2: Kẻ phá hoại - Cố nạp 0x2222 khi đang bận
                #300; // Đợi một chút cho PISO chạy
                $display("[TEST] Injecting 0x2222 while BUSY...");
                load_i = 1; data_parallel_i = 16'h2222;
                @(posedge clk) load_i = 0;
            end
        join
        // Nếu Monitor không báo lỗi [DATA FAIL], nghĩa là PISO đã lờ đi 0x2222
        $display("-> TC_03 Finished.");

        #200;

        // ------------------------------------------------------------
        // TC_04: Reset Check (0x1234 -> Reset mid-stream)
        // ------------------------------------------------------------
        $display("\n--- TC_04: Reset Check (Input 0x1234) ---");
        apply_reset();
        
        // Không dùng drive_data vì ta không muốn nạp vào queue mong đợi (sẽ check tay)
        $display("[DRIVER] Loading 0x1234");
        @(posedge clk);
        data_parallel_i <= 16'h1234; load_i <= 1;
        @(posedge clk); load_i <= 0;

        // Đợi khoảng 4 cặp bit được gửi (4 * 170ns = 680ns)
        #600; 
        $display("[TEST] Asserting Reset mid-stream!");
        rst_n = 0; // Kéo Reset
        #20;
        
        // Kiểm tra ngay lập tức
        if (valid_serial_o == 0 && data_serial_o == 0) begin
             $display("\033[1;32m[PASS] Output dropped to 0 immediately.\033[0m");
        end else begin
             $display("\033[1;31m[FAIL] Output did not reset! Valid=%b Data=%b\033[0m", valid_serial_o, data_serial_o);
             error_count++;
        end
        
        // Khôi phục Reset để test tiếp
        rst_n = 1;
        expected_queue.delete(); // Xóa rác nếu có
        #100;

        // ------------------------------------------------------------
        // TC_05: Continuous (0xAAAA -> 0x5555)
        // ------------------------------------------------------------
        $display("\n--- TC_05: Continuous Transfer (0xAAAA then 0x5555) ---");
        // Gửi gói 1
        drive_data(16'hAAAA);
        monitor_check_packet();
        
        // Ngay khi gói 1 xong (Monitor return), nạp ngay gói 2
        // Lưu ý: monitor trả về khi bit cuối cùng đã tắt valid -> thời điểm vàng để nạp
        drive_data(16'h5555);
        monitor_check_packet();
        $display("-> TC_05 Finished.");

        // ============================================================
        // TỔNG KẾT
        // ============================================================
        $display("\n==================================================");
        if (error_count == 0) begin
            $display("\033[1;32m [PASS] CONGRATULATIONS! ALL 5 TEST CASES PASSED! \033[0m");
        end else begin
            $display("\033[1;31m [FAIL] FOUND %0d ERRORS. PLEASE CHECK LOGS. \033[0m", error_count);
        end
        $display("==================================================");
        $finish;
    end

    initial begin
        $dumpfile("piso_wave.vcd");
        $dumpvars(0, tb_piso);
    end

endmodule