`timescale 1ns / 1ps
`include "../design/sipo.v"

module tb_sipo;

    // Parameters
    parameter CLK_PERIOD = 10;  // 100MHz clock

    // Signals
    reg       clk;
    reg       rst_n;
    reg       data_serial_i;
    reg       valid_serial_i;
    wire [7:0] data_parallel_o;
    wire       byte_ready_o;

    // Instantiate SIPO
    sipo dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .data_serial_i   (data_serial_i),
        .valid_serial_i  (valid_serial_i),
        .data_parallel_o (data_parallel_o),
        .byte_ready_o    (byte_ready_o)
    );

    // Clock generator
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test procedure
    initial begin
        // Initialize
        clk             = 0;
        rst_n           = 0;
        data_serial_i   = 0;
        valid_serial_i  = 0;

        // Reset
        # (2*CLK_PERIOD);
        rst_n = 1;
        # (2*CLK_PERIOD);

        // Test case 1: Send 8 bits: 10101010 (MSB first)
        send_bit(1);  // bit7 = 1 (MSB)
        send_bit(0);  // bit6 = 0
        send_bit(1);  // bit5 = 1
        send_bit(0);  // bit4 = 0
        send_bit(1);  // bit3 = 1
        send_bit(0);  // bit2 = 0
        send_bit(1);  // bit1 = 1
        send_bit(0);  // bit0 = 0 (LSB)

        // Check output after last bit
        # (CLK_PERIOD);
        if (data_parallel_o !== 8'b10101010) begin
            $display("ERROR: Expected data_parallel_o = 8'b10101010, got %b", data_parallel_o);
        end else begin
            $display("PASS: data_parallel_o = %b", data_parallel_o);
        end
        if (byte_ready_o !== 1'b1) begin
            $display("ERROR: byte_ready_o should be 1");
        end

        // Wait for ready to drop
        # (CLK_PERIOD);
        if (byte_ready_o !== 1'b0) begin
            $display("ERROR: byte_ready_o should drop to 0");
        end

        // Test case 2: Send another byte: 11110000, with some invalid cycles
        # (2*CLK_PERIOD);  // idle
        valid_serial_i = 0; // no valid
        # (CLK_PERIOD);
        send_bit(1);  // bit7 = 1
        send_bit(1);  // bit6 = 1
        send_bit(1);  // bit5 = 1
        send_bit(1);  // bit4 = 1
        # (CLK_PERIOD);  // idle cycle (no valid)
        valid_serial_i = 0;
        # (CLK_PERIOD);
        send_bit(0);  // bit3 = 0 (continue after idle)
        send_bit(0);  // bit2 = 0
        send_bit(0);  // bit1 = 0
        send_bit(0);  // bit0 = 0

        // Check
        # (CLK_PERIOD);
        if (data_parallel_o !== 8'b11110000) begin
            $display("ERROR: Expected data_parallel_o = 8'b11110000, got %b", data_parallel_o);
        end else begin
            $display("PASS: data_parallel_o = %b", data_parallel_o);
        end

        // Test reset in middle
        send_bit(1);  // start new byte
        send_bit(0);
        rst_n = 0;    // reset
        # (2*CLK_PERIOD);
        rst_n = 1;
        # (2*CLK_PERIOD);
        if (byte_ready_o !== 1'b0 || data_parallel_o !== 8'b0) begin
            $display("ERROR: Reset failed");
        end else begin
            $display("PASS: Reset successful");
        end

        // End simulation
        # (10*CLK_PERIOD);
        $display("Simulation finished");
        $finish;
    end

    // Task to send a single bit with valid pulse
    task send_bit;
        input bit_val;
        begin
            data_serial_i  = bit_val;
            valid_serial_i = 1;
            # (CLK_PERIOD);
            valid_serial_i = 0;  // optional, but to simulate pulse
        end
    endtask

endmodule