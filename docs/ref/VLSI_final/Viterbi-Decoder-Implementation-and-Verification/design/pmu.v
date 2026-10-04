module pmu (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       valid_i,         // Enable update
    
    // Path Metrics MỚI từ ACSU
    input  wire [7:0] pm_new_s0_i, pm_new_s1_i, pm_new_s2_i, pm_new_s3_i,

    // Path Metrics HIỆN TẠI (Feedback về ACSU)
    output reg  [7:0] pm_current_s0_o, pm_current_s1_o, pm_current_s2_o, pm_current_s3_o
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pm_current_s0_o <= 8'd0;   // S0 khởi đầu là 0
            pm_current_s1_o <= 8'd255; // Các state khác max
            pm_current_s2_o <= 8'd255;
            pm_current_s3_o <= 8'd255;
        end else if (valid_i) begin
            pm_current_s0_o <= pm_new_s0_i;
            pm_current_s1_o <= pm_new_s1_i;
            pm_current_s2_o <= pm_new_s2_i;
            pm_current_s3_o <= pm_new_s3_i;
        end
    end

endmodule