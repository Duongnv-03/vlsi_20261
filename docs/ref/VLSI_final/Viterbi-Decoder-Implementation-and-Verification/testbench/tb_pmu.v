`timescale 1ns / 1ps
`include "../design/pmu.v"

module tb_pmu;

    // Parameters
    parameter TBL = 15;
    parameter PM_WIDTH = 8;
    parameter CLK_PERIOD = 10;  // 100MHz

    // Signals
    reg                   clk;
    reg                   rst_n;
    reg                   valid_i;
    reg [3:0]             dec_bits_i;
    reg [PM_WIDTH-1:0]    pm_new_s0_i;
    reg [PM_WIDTH-1:0]    pm_new_s1_i;
    reg [PM_WIDTH-1:0]    pm_new_s2_i;
    reg [PM_WIDTH-1:0]    pm_new_s3_i;
    reg [$clog2(TBL)-1:0] read_addr_i;
    wire [PM_WIDTH-1:0]   pm_current_s0_o;
    wire [PM_WIDTH-1:0]   pm_current_s1_o;
    wire [PM_WIDTH-1:0]   pm_current_s2_o;
    wire [PM_WIDTH-1:0]   pm_current_s3_o;
    wire [3:0]            read_data_o;

    // Instantiate DUT
    pmu #(
        .TBL(TBL),
        .PM_WIDTH(PM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_i(valid_i),
        .dec_bits_i(dec_bits_i),
        .pm_new_s0_i(pm_new_s0_i),
        .pm_new_s1_i(pm_new_s1_i),
        .pm_new_s2_i(pm_new_s2_i),
        .pm_new_s3_i(pm_new_s3_i),
        .read_addr_i(read_addr_i),
        .pm_current_s0_o(pm_current_s0_o),
        .pm_current_s1_o(pm_current_s1_o),
        .pm_current_s2_o(pm_current_s2_o),
        .pm_current_s3_o(pm_current_s3_o),
        .read_data_o(read_data_o)
    );

    // Clock generator
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test procedure
    initial begin
        // Initialize
        clk          = 0;
        rst_n        = 0;
        valid_i      = 0;
        dec_bits_i   = 4'b0;
        pm_new_s0_i  = 8'd0;
        pm_new_s1_i  = 8'd0;
        pm_new_s2_i  = 8'd0;
        pm_new_s3_i  = 8'd0;
        read_addr_i  = 4'd0;

        // Reset and check
        #(2*CLK_PERIOD);
        rst_n = 1;
        #(2*CLK_PERIOD);
        check_reset();

        // Test case 1: Single write & immediate read
        write_dec(4'b1010, 8'd10, 8'd20, 8'd30, 8'd40);
        check_pm(8'd10, 8'd20, 8'd30, 8'd40, "Single PM update");
        read_addr_i = 4'd14;  // Newest
        #(CLK_PERIOD/2);
        check_read(4'b1010, "Single decision write/read");

        // Test case 2: Multiple writes to verify shift
        // Write seq: 0001 -> 0010 -> 0100 -> 1000
        // Expected: addr14=1000, addr13=0100, addr12=0010, addr11=0001, others 0
        write_dec(4'b0001, 8'd50, 8'd60, 8'd70, 8'd80);
        write_dec(4'b0010, 8'd90, 8'd100, 8'd110, 8'd120);
        write_dec(4'b0100, 8'd130, 8'd140, 8'd150, 8'd160);
        write_dec(4'b1000, 8'd170, 8'd180, 8'd190, 8'd200);
        check_pm(8'd170, 8'd180, 8'd190, 8'd200, "Multi PM update");

        // Check multiple reads
        read_addr_i = 4'd14; #(CLK_PERIOD/2); check_read(4'b1000, "addr14");
        read_addr_i = 4'd13; #(CLK_PERIOD/2); check_read(4'b0100, "addr13");
        read_addr_i = 4'd12; #(CLK_PERIOD/2); check_read(4'b0010, "addr12");
        read_addr_i = 4'd11; #(CLK_PERIOD/2); check_read(4'b0001, "addr11");
        read_addr_i = 4'd0;  #(CLK_PERIOD/2); check_read(4'b0000, "addr0 (oldest)");

        // Test case 3: Full TBL writes + overflow
        repeat (TBL) begin
            write_dec(4'b1111, 8'd255, 8'd254, 8'd253, 8'd252);
        end
        // Now all should be 1111
        read_addr_i = 4'd0;  #(CLK_PERIOD/2); check_read(4'b1111, "Full TBL fill addr0");
        read_addr_i = 4'd14; #(CLK_PERIOD/2); check_read(4'b1111, "Full TBL fill addr14");

        // Overflow: One more write with different value
        write_dec(4'b0000, 8'd1, 8'd2, 8'd3, 8'd4);
        read_addr_i = 4'd0;  #(CLK_PERIOD/2); check_read(4'b1111, "Overflow: addr0 shifted out? No, shift pushes old out");
        // Wait, in shift logic: oldest [0] <= [1], so after full +1, [0] = old [1] =1111, [14]=0000
        // To check overflow: [0] should be the second last 1111 shifted
        // But since all 1111, after one more, [0..13]=1111, [14]=0000
        read_addr_i = 4'd14; #(CLK_PERIOD/2); check_read(4'b0000, "Overflow newest");
        read_addr_i = 4'd0;  #(CLK_PERIOD/2); check_read(4'b1111, "Overflow oldest");

        // Test case 4: No update without valid_i
        pm_new_s0_i = 8'd0;  // Try to set to 0 without valid
        pm_new_s1_i = 8'd0;
        #(2*CLK_PERIOD);  // No valid, so no change
        if (pm_current_s0_o == 8'd1) begin  // Should still be 1 from last write
            $display("PASS: No update without valid");
        end else begin
            $display("ERROR: Updated without valid - PM0=%h", pm_current_s0_o);
        end

        // End simulation
        #(10*CLK_PERIOD);
        $display("All tests completed");
        $finish;
    end

    // Task: Write one entry
    task write_dec;
        input [3:0] dec;
        input [PM_WIDTH-1:0] p0, p1, p2, p3;
        begin
            dec_bits_i  = dec;
            pm_new_s0_i = p0;
            pm_new_s1_i = p1;
            pm_new_s2_i = p2;
            pm_new_s3_i = p3;
            valid_i     = 1;
            #(CLK_PERIOD);
            valid_i     = 0;
            #(CLK_PERIOD);  // Settle
        end
    endtask

    // Task: Check reset
    task check_reset;
        begin
            if (pm_current_s0_o == 0 && pm_current_s1_o == 0 && pm_current_s2_o == 0 && pm_current_s3_o == 0 && read_data_o == 4'b0) begin
                $display("PASS: Reset successful");
            end else begin
                $display("ERROR: Reset failed");
            end
        end
    endtask

    // Task: Check PM values
    task check_pm;
        input [PM_WIDTH-1:0] exp0, exp1, exp2, exp3;
        input string msg;
        begin
            if (pm_current_s0_o == exp0 && pm_current_s1_o == exp1 && pm_current_s2_o == exp2 && pm_current_s3_o == exp3) begin
                $display("PASS: %s", msg);
            end else begin
                $display("ERROR: %s - Got PM0=%h, PM1=%h, PM2=%h, PM3=%h", msg, pm_current_s0_o, pm_current_s1_o, pm_current_s2_o, pm_current_s3_o);
            end
        end
    endtask

    // Task: Check read_data_o
    task check_read;
        input [3:0] exp;
        input string msg;
        begin
            if (read_data_o == exp) begin
                $display("PASS: %s - read_data_o=%b", msg, read_data_o);
            end else begin
                $display("ERROR: %s - Expected %b, got %b", msg, exp, read_data_o);
            end
        end
    endtask

endmodule

