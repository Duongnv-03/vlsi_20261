//`include "system_top.v"
`timescale 1ns/1ps

module tb_system_top;

    // --- 0. ANSI COLORS ---
    string RESET  = "\033[0m";
    string RED    = "\033[1;31m";
    string GREEN  = "\033[1;32m";
    string YELLOW = "\033[1;33m";
    string BLUE   = "\033[1;34m";
    string CYAN   = "\033[1;36m";

    // --- 1. Signals ---
    logic        clk, rst_n, dvalid_i, valid_o, busy_o;
    logic [15:0] data_i;
    logic [7:0]  data_o;

    // --- 2. State ---
    logic [7:0] expected_queue [$];
    logic [1:0] encoder_state; 
    bit first_byte_rcvd; 
    
    // DUT
    system_top u_dut (.*);

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- 3. Table Utils ---
    task print_separator(); $display("+------------+--------+--------+----------+"); endtask
    task print_header();
        print_separator();
        $display("|  Time (ns) |  Recv  | Expect |  Status  |");
        print_separator();
    endtask

    task print_row(input string status, input [7:0] recv, input [7:0] exp);
        string color;
        if (status == "PASS") color = GREEN;
        else if (status == "FAIL") color = RED;
        else if (status == "WARMUP") color = YELLOW;
        else if (status == "FLUSH")  color = CYAN; // Màu cho data rác lúc xả ống
        else color = RESET;
        
        if (status == "FLUSH" || status == "WARMUP")
            $display("| %10t |   %02h   |   --   | %s %-6s %s |", $time, recv, color, status, RESET);
        else
            $display("| %10t |   %02h   |   %02h   | %s %-6s %s |", $time, recv, exp, color, status, RESET);
    endtask

    // --- 4. Monitor Logic (FIXED: Không báo lỗi khi Flush) ---
    task monitor_and_check();
        logic [7:0] exp_data;
        forever begin
            @(posedge clk);
            if(valid_o) begin
                // Byte đầu tiên sau reset luôn là Warmup
                if(!first_byte_rcvd) begin
                    print_row("WARMUP", data_o, 8'h00); 
                    first_byte_rcvd = 1; 
                end else begin
                    // Nếu còn hàng đợi -> Check
                    if(expected_queue.size() > 0) begin
                        exp_data = expected_queue.pop_front();
                        if(data_o === exp_data) print_row("PASS", data_o, exp_data);
                        else                    print_row("FAIL", data_o, exp_data);
                    end 
                    // Nếu hàng đợi rỗng -> Coi như đang Flush (Data thừa)
                    else begin
                         print_row("FLUSH", data_o, 8'h00);
                    end
                end
            end
        end
    endtask

    // --- 5. Drivers ---
    task reset_for_new_test();
        rst_n = 0; dvalid_i = 0; expected_queue.delete(); 
        encoder_state = 0; first_byte_rcvd = 0; 
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(10) @(posedge clk); 
    endtask

    task encode_and_drive(input logic [7:0] byte_in, input bit check_queue);
        logic [15:0] encoded_packet;
        logic [1:0] pair;
        for (int i = 0; i < 8; i++) begin
            pair[0] = byte_in[i] ^ encoder_state[1] ^ encoder_state[0]; 
            pair[1] = byte_in[i] ^ encoder_state[0];                    
            encoder_state = {byte_in[i], encoder_state[1]};
            encoded_packet[15 - (2*i)] = pair[0]; 
            encoded_packet[15 - (2*i) - 1] = pair[1]; 
        end
        @(posedge clk); while(busy_o) @(posedge clk);
        dvalid_i <= 1; data_i <= encoded_packet;
        if(check_queue) expected_queue.push_back(byte_in);
        @(posedge clk); dvalid_i <= 0;
    endtask

    task encode_and_drive_noisy(input logic [7:0] byte_in, input int num_errors);
        logic [15:0] encoded_packet;
        logic [1:0] pair;
        int i, err_pos;
        for (i = 0; i < 8; i++) begin
            pair[0] = byte_in[i] ^ encoder_state[1] ^ encoder_state[0]; 
            pair[1] = byte_in[i] ^ encoder_state[0];                    
            encoder_state = {byte_in[i], encoder_state[1]};
            encoded_packet[15 - (2*i)]     = pair[0]; 
            encoded_packet[15 - (2*i) - 1] = pair[1]; 
        end
        repeat(num_errors) begin
            err_pos = $urandom_range(0, 15);
            encoded_packet[err_pos] = ~encoded_packet[err_pos];
        end
        @(posedge clk); while(busy_o) @(posedge clk);
        dvalid_i <= 1; data_i <= encoded_packet; expected_queue.push_back(byte_in);
        @(posedge clk); dvalid_i <= 0;
    endtask

    task flush_pipeline();
        // Bơm 20 gói rác vào, tham số thứ 2 là '0' nghĩa là không đưa vào queue check
        repeat(20) encode_and_drive(8'h00, 0); 
        repeat(50) @(posedge clk);
    endtask

    // --- FIX QUAN TRỌNG: Sửa lỗi Timeout ảo ---
    task wait_for_queue_empty(input string name);
        fork : wait_blk
            // Thread 1: Đợi queue rỗng
            begin
                wait(expected_queue.size() == 0);
            end
            
            // Thread 2: Đếm giờ
            begin 
                #500000; 
                $display("%s[TIMEOUT] %s timed out! Remaining: %0d%s", RED, name, expected_queue.size(), RESET); 
            end
        join_any // <--- Quan trọng: Chỉ cần 1 trong 2 xong là thoát
        
        disable wait_blk; // Ngắt thread còn lại ngay lập tức
    endtask

    // --- 6. Main Test Sequence ---
    initial begin
        fork monitor_and_check(); join_none
        
        // PHASE 1: CLEAN
        reset_for_new_test();
        $display("\n%s[TEST PHASE 1] CLEAN CHANNEL%s", BLUE, RESET);
        print_header();
        for (int k = 0; k < 20; k++) encode_and_drive($urandom_range(0, 255), 1);
        flush_pipeline();
        wait_for_queue_empty("Phase 1");
        print_separator();

        // PHASE 2: NOISY
        reset_for_new_test();
        $display("\n%s[TEST PHASE 2] NOISY CHANNEL (1-Bit Error)%s", BLUE, RESET);
        print_header();
        for (int k = 0; k < 20; k++) encode_and_drive_noisy($urandom_range(0, 255), 1);
        flush_pipeline();
        wait_for_queue_empty("Phase 2");
        print_separator();

        // PHASE 3: PATTERNS
        reset_for_new_test();
        $display("\n%s[TEST PHASE 3] TEST PATTERN%s", BLUE, RESET);
        print_header();
        encode_and_drive(8'h00, 1); 
        encode_and_drive(8'hFF, 1);
        encode_and_drive(8'hAA, 1);
        encode_and_drive(8'h55, 1);
        flush_pipeline();
        wait_for_queue_empty("Pattern Test");
        print_separator();

        // PHASE 4: STRESS
        reset_for_new_test();
        $display("\n%s[TEST PHASE 4] STRESS%s", BLUE, RESET);
        print_header();
        for(int k=0; k<20; k++) begin
            logic [7:0] val; val = k;
            encode_and_drive(val, 1);
        end
        flush_pipeline();
        wait_for_queue_empty("FIFO Stress");
        print_separator();

        // PHASE 5: BREAKING POINT
        reset_for_new_test();
        $display("\n%s[TEST PHASE 5] BREAKING POINT%s", BLUE, RESET);
        print_header();
        encode_and_drive_noisy(8'hAB, 3);
        flush_pipeline();
        // Riêng cái này expect fail hoặc timeout nên giữ logic cũ
        fork : wait_bp
            wait(expected_queue.size() == 0);
            begin #100000; disable wait_bp; end
        join
        print_separator();

        // PHASE 6: RESET RECOVERY
        reset_for_new_test();
        $display("\n%s[TEST PHASE 6] RESET RECOVERY%s", BLUE, RESET);
        print_header();
        encode_and_drive(8'hAA, 1);
        $display("%s[ACTION] Asserting Mid-stream Reset...%s", YELLOW, RESET);
        
        reset_for_new_test();
        
        for(int k=0; k<10; k++) begin
            logic [7:0] val;
            val = (k << 4) | k; 
            encode_and_drive(val, 1);
        end
        flush_pipeline();
        wait_for_queue_empty("Reset Recovery");
        print_separator();

        $display("\n%s*** ALL TESTS COMPLETED ***%s\n", GREEN, RESET);
        $finish;
    end
endmodule