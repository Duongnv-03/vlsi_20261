`timescale 1ns/1ps

module tb_system_top_auto;

    // =================================================================
    // 1. CẤU HÌNH
    // =================================================================
    parameter CLK_PERIOD = 10;   // 100MHz
    parameter TEST_LOOPS = 5;   // Số lượng gói tin muốn test
    parameter TIMEOUT_CYCLES = 2000; // Chờ tối đa bao nhiêu nhịp clock thì báo lỗi
    
    reg         clk;
    reg         rst_n;
    reg         dvalid_i;
    reg  [15:0] data_i;
    
    wire [7:0]  data_o;
    wire        valid_o;
    wire        busy_o;

    // Biến toàn cục lưu trạng thái Encoder (Để đồng bộ với mạch thật)
    reg [2:0]   encoder_state; 
    
    // Biến thống kê
    int pass_cnt = 0;
    int fail_cnt = 0;

    // Kết nối DUT
    system_top #( .TBL(15) ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .dvalid_i(dvalid_i),
        .data_i(data_i),
        .data_o(data_o),
        .valid_o(valid_o),
        .busy_o(busy_o)
    );

    // =================================================================
    // 2. SOFTWARE ENCODER (Chuẩn LSB First, 7/5, Stateful)
    // =================================================================
    function bit [15:0] software_encoder(input bit [7:0] data_in);
        bit [15:0] encoded_word;
        bit        g_y, g_x; 
        int        i;
        
        encoded_word = 0;

        // Quét từ LSB (bit 0) đến MSB (bit 7)
        for (i = 0; i < 8; i++) begin
            // 1. Dịch bit vào thanh ghi trạng thái (Lưu vết từ gói trước)
            encoder_state = {encoder_state[1:0], data_in[i]}; 
            
            // 2. Tính toán (Poly: Y=101, X=111)
            g_y = encoder_state[2] ^ encoder_state[0]; 
            g_x = encoder_state[2] ^ encoder_state[1] ^ encoder_state[0];
            
            // 3. Đóng gói: Cặp đầu tiên (i=0) nằm ở vị trí cao [15:14]
            encoded_word[15 - 2*i]     = g_x; 
            encoded_word[14 - 2*i]     = g_y; 
        end
        return encoded_word;
    endfunction

    // =================================================================
    // 3. TẠO CLOCK
    // =================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // =================================================================
    // 4. MAIN TEST PROCESS
    // =================================================================
    initial begin
        $display("\n[START] --- STOP-AND-WAIT VERIFICATION ---");
        $display("-----------------------------------------------------------------------------------------");
        $display("|   TIME   | STATUS |  GOC (8-bit) |  INPUT (16-bit)  | OUTPUT (8-bit) | NOTE           |");
        $display("-----------------------------------------------------------------------------------------");
        
        // Reset hệ thống
        rst_n = 0; dvalid_i = 0; data_i = 0; encoder_state = 0;
        #100; rst_n = 1; #100;

        // --- TEST CASE 1: Kiểm tra gói tin E217 (Mồi) ---
        send_and_wait(8'h35); 
        
        // --- TEST CASE 2: Chạy Random ---
        repeat (TEST_LOOPS) begin
            bit [7:0] rand_byte;
            rand_byte = $urandom(); 
            
            // Gửi xong, chờ nhận xong mới quay lại vòng lặp
            send_and_wait(rand_byte);
        end

        // Tổng kết
        $display("-----------------------------------------------------------------------------------------");
        $display(" FINAL REPORT: Passed %0d / %0d", pass_cnt, (pass_cnt + fail_cnt));
        
        if (fail_cnt == 0) $display(" RESULT: [[ SUCCESS - HE THONG CHAY NGON LANH CANH DAO ]] \n");
        else               $display(" RESULT: [[ FAILED - CO LOI XAY RA ]] \n");
        
        $finish;
    end

    // =================================================================
    // TASK: Gửi -> Chờ -> So sánh (Trái tim của Testbench này)
    // =================================================================
    task send_and_wait(input [7:0] original_data);
        bit [15:0] encoded_val;
        bit        got_result;
        int        timeout_ctr;
        
        begin
            // 1. Mã hóa
            encoded_val = software_encoder(original_data);
            
            // 2. Gửi dữ liệu vào DUT
            wait(busy_o == 0);
            @(posedge clk);
            dvalid_i = 1;
            data_i   = encoded_val;
            @(posedge clk);
            dvalid_i = 0;
            data_i   = 0;

            // 3. Vòng lặp CHỜ KẾT QUẢ (Wait for Output)
            got_result = 0;
            timeout_ctr = 0;
            
            while (!got_result && timeout_ctr < TIMEOUT_CYCLES) begin
                @(posedge clk);
                timeout_ctr++;

                if (valid_o) begin
                    // Lọc rác: Nếu ra 00 mà mình không mong đợi 00 -> Bỏ qua, chờ tiếp
                    if (data_o == 8'h00 && original_data != 8'h00) begin
                        // Đây là flush byte, kệ nó, chờ byte tiếp theo
                    end 
                    else begin
                        // ĐÂY RỒI! Hàng thật đã về
                        if (data_o == original_data) begin
                            $display("| %8t |  PASS  |      %h      |       %h       |       %h       |                |", 
                                     $time, original_data, encoded_val, data_o);
                            pass_cnt++;
                        end else begin
                            $display("| %8t |  FAIL  |      %h      |       %h       |       %h       | Sai Output !!! |", 
                                     $time, original_data, encoded_val, data_o);
                            fail_cnt++;
                        end
                        got_result = 1; // Thoát vòng lặp chờ
                    end
                end
            end

            // 4. Kiểm tra Timeout
            if (!got_result) begin
                $display("| %8t | TIMEOUT|      %h      |       %h       |       --       | Khong thay ra  |", 
                         $time, original_data, encoded_val);
                fail_cnt++;
            end

            // 5. Nghỉ một chút cho hệ thống ổn định trước khi bắn gói sau
            #200; 
        end
    endtask

    initial begin
        $dumpfile("system_wave.vcd");
        $dumpvars(0, tb_system_top_auto);
    end

endmodule