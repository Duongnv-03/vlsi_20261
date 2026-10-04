`timescale 1ns / 1ps
`include "../design/piso.v"

module tb_piso;

    // Inputs
    reg clk;
    reg rst_n;
    reg load_i;
    reg [15:0] data_parallel_i;

    // Outputs
    wire [1:0] data_serial_o;
    wire valid_serial_o;

    // Instantiate the Unit Under Test (UUT)
    piso uut (
        .clk(clk),
        .rst_n(rst_n),
        .load_i(load_i),
        .data_parallel_i(data_parallel_i),
        .data_serial_o(data_serial_o),
        .valid_serial_o(valid_serial_o)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz clock (10 ns period)

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 1;
        load_i = 0;
        data_parallel_i = 16'b0;

        // Reset the module
        #10;
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        // Test case 1: Load data and check serial output (MSB first)
        data_parallel_i = 16'hA5A5;  // Binary: 1010_0101_1010_0101
        load_i = 1;
        #10;  // Load at this clock
        load_i = 0;

        // Now wait for 8 clocks and check outputs
        // Expected serial_o sequence (MSB first):
        // Clock 1: 10 (A=1010 -> bits 15:14=10)
        // Clock 2: 10 (bits 13:12=10)
        // Clock 3: 01 (bits 11:10=01)
        // Clock 4: 01 (bits 9:8=01)
        // Clock 5: 10 (bits 7:6=10)
        // Clock 6: 10 (bits 5:4=10)
        // Clock 7: 01 (bits 3:2=01)
        // Clock 8: 01 (bits 1:0=01)
        // valid_serial_o should be 1 for exactly 8 clocks

        #80;  // Wait 8 clocks (80 ns)

        // Test case 2: Another data to check reset and reload
        data_parallel_i = 16'hFFFF;  // All 1s: 1111_1111_1111_1111
        load_i = 1;
        #10;
        load_i = 0;

        #80;  // Wait another 8 clocks

        // Test case 3: Check without load, should hold idle
        #50;

        // End simulation
        $display("Simulation completed.");
        $finish;
    end

    // Monitor outputs for debugging
    initial begin
        $monitor("Time=%0t | clk=%b | rst_n=%b | load_i=%b | data_parallel_i=%h | data_serial_o=%b | valid_serial_o=%b | cnt(internal)=%d",
                 $time, clk, rst_n, load_i, data_parallel_i, data_serial_o, valid_serial_o, uut.cnt);
    end

    // Automatic checker (optional, for simple verification)
    // You can expand this with assertions in real simulators like ModelSim/Vivado
    always @(posedge clk) begin
        if (valid_serial_o && uut.cnt == 4'd0) begin
            $display("Error: valid high when cnt=0");
            $finish;
        end
    end

endmodule