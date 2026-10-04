`timescale 1ns/1ps
//`include "../design/system_top.v"
//`include "../design/viterbi_core.v"

module tb_system_top;

    // ============================================================
    // 1. PARAMETERS & SIGNALS
    // ============================================================
    parameter TBL      = 15;
    parameter PM_WIDTH = 8;
    parameter CLK_PERIOD = 10; // 100MHz

    reg         clk;
    reg         rst_n;
    reg         dvalid_i;
    reg  [15:0] data_i;
    wire [7:0]  data_o;
    wire        valid_o;
    wire        busy_o;

    // Biến hỗ trợ kiểm tra
    reg [7:0] sent_bytes_queue [$]; // Hàng đợi chứa byte đã gửi
    reg [7:0] received_byte;
    integer   errors = 0;
    integer   test_count = 0;

    // ============================================================
    // 2. DUT INSTANTIATION
    // ============================================================
    // Lưu ý: Cần update module PISO như code phía trên để chạy đúng
    system_top #(
        .TBL(TBL),
        .PM_WIDTH(PM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .dvalid_i(dvalid_i),
        .data_i(data_i),
        .data_o(data_o),
        .valid_o(valid_o),
        .busy_o(busy_o)
    );

    // ============================================================
    // 3. CLOCK GENERATION
    // ============================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ============================================================
    // 4. HELPER TASKS (SOFTWARE ENCODER)
    // ============================================================
    // Mô phỏng bộ mã hóa K=3, R=1/2 (Polys: 7, 5) để tạo input test
    function [15:0] encode_byte(input [7:0] in_byte);
        integer i;
        reg [1:0] shift_reg;
        reg [1:0] encoded_symbol;
        reg [15:0] result;
        begin
            shift_reg = 2'b00; // Reset state encoder mỗi byte (để đơn giản hóa test)
            // Vì Viterbi cần trạng thái liên tục, nhưng PISO gửi theo block 16 bit
            // Ở đây ta giả lập gửi từng block độc lập để test cơ bản.
            // Để test chính xác luồng stream, cần giữ state của encoder, 
            // nhưng với thiết kế hiện tại reset mỗi block là dễ debug nhất.
            
            for (i = 7; i >= 0; i = i - 1) begin
                // Input bit (MSB first)
                // Poly 1 (111) -> x^2 + x + 1
                encoded_symbol[1] = in_byte[i] ^ shift_reg[1] ^ shift_reg[0];
                // Poly 2 (101) -> x^2 + 1
                encoded_symbol[0] = in_byte[i] ^ shift_reg[0];
                
                // Shift register encoder
                shift_reg = {in_byte[i], shift_reg[1]};
                
                // Pack vào kết quả (MSB vào trước)
                result[2*i + 1] = encoded_symbol[1];
                result[2*i]     = encoded_symbol[0];
            end
            encode_byte = result;
        end
    endfunction

    // ============================================================
    // 5. TEST SCENARIO
    // ============================================================
    initial begin
        // --- Setup ---
        rst_n = 0;
        dvalid_i = 0;
        data_i = 0;
        #100;
        rst_n = 1;
        #50;

        $display("-------------------------------------------------------------");
        $display("Starting Viterbi System Testbench");
        $display("Config: TBL=%0d, PM_WIDTH=%0d", TBL, PM_WIDTH);
        $display("-------------------------------------------------------------");

        // --- Test Case 1: Gửi 1 Byte đơn giản (0x55) ---
        send_data(8'h55);
        
        // --- Test Case 2: Gửi 1 Byte khác (0xAB) ---
        send_data(8'hAB);

        // --- Test Case 3: Random Bytes ---
        repeat(5) begin
            send_data($random);
        end

        // Chờ xử lý hết
        wait_until_idle();
        #2000; // Thêm thời gian trễ để chắc chắn

        // --- Kết luận ---
        $display("-------------------------------------------------------------");
        if (errors == 0) begin
            $display("\033[1;32m [PASS] ALL TESTS PASSED! (%0d vectors checked) \033[0m", test_count);
        end else begin
            $display("\033[1;31m [FAIL] Found %0d ERRORS out of %0d tests. \033[0m", errors, test_count);
        end
        $display("-------------------------------------------------------------");
        $finish;
    end

    // ============================================================
    // 6. TASKS & MONITORING
    // ============================================================

    task send_data(input [7:0] raw_byte);
        reg [15:0] encoded_frame;
        begin
            wait_until_idle();
            
            // Encode dữ liệu bằng phần mềm
            encoded_frame = encode_byte(raw_byte);
            
            // Đẩy vào DUT
            @(posedge clk);
            data_i   <= encoded_frame;
            dvalid_i <= 1'b1;
            sent_bytes_queue.push_back(raw_byte); // Lưu vào hàng đợi check
            
            @(posedge clk);
            dvalid_i <= 1'b0;
            
            $display("[Time %0t] Sent Raw: 0x%h | Encoded Input: 0x%h", $time, raw_byte, encoded_frame);
        end
    endtask

    task wait_until_idle();
        begin
            wait(busy_o == 0);
            repeat(5) @(posedge clk); // Chờ thêm chút cho an toàn
        end
    endtask

    // Monitor Output
    always @(posedge clk) begin
        if (valid_o) begin
            reg [7:0] expected;
            received_byte = data_o;
            
            if (sent_bytes_queue.size() > 0) begin
                expected = sent_bytes_queue.pop_front();
                test_count = test_count + 1;
                
                if (received_byte === expected) begin
                    $display("    \033[1;32m[CHECK PASS]\033[0m Time %0t: Expected 0x%h, Got 0x%h", $time, expected, received_byte);
                end else begin
                    $display("    \033[1;31m[CHECK FAIL]\033[0m Time %0t: Expected 0x%h, Got 0x%h", $time, expected, received_byte);
                    errors = errors + 1;
                end
            end else begin
                $display("    \033[1;33m[WARNING]\033[0m Received unexpected data: 0x%h (Queue empty)", received_byte);
            end
        end
    end

endmodule