`include "sync_fifo.v"
`include "piso.v"
`include "sipo.v"
`include "viterbi_core.v"

module system_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        dvalid_i,     // Input Valid (Write Enable cho FIFO)
    input  wire [15:0] data_i,       // Input Data
    output wire [7:0]  data_o,       // Output Data
    output wire        valid_o,      // Output Valid
    output wire        busy_o        // Báo bận (Khi FIFO đầy)
);

    // --- Dây kết nối FIFO -> PISO ---
    wire        fifo_full;
    wire        fifo_empty;
    wire        piso_rd_en;
    wire [15:0] fifo_data_out;

    // --- Dây kết nối PISO -> Core ---
    wire [1:0]  piso_to_core_data;
    wire        piso_to_core_valid;

    // --- Dây kết nối Core -> SIPO ---
    wire        core_to_sipo_data;
    wire        core_to_sipo_valid;

    // --- 1. FIFO Input Buffer ---
    // Buffer đầu vào để tránh mất mát dữ liệu khi PISO đang bận
    sync_fifo #(
        .DATA_WIDTH(16),
        .DEPTH(16)      // Chứa được 16 gói tin (16 * 16 bit)
    ) u_input_fifo (
        .clk(clk),
        .rst_n(rst_n),
        // Write side (Từ bên ngoài)
        .wr_en_i(dvalid_i),
        .wr_data_i(data_i),
        .full_o(fifo_full),
        // Read side (Tới PISO)
        .rd_en_i(piso_rd_en),
        .rd_data_o(fifo_data_out),
        .empty_o(fifo_empty)
    );

    // --- 2. PISO (Active Mode) ---
    piso u_piso (
        .clk(clk),
        .rst_n(rst_n),
        // Lấy dữ liệu từ FIFO
        .fifo_data_i(fifo_data_out),
        .fifo_empty_i(fifo_empty),
        .fifo_rd_en_o(piso_rd_en),
        // Đẩy ra Core
        .data_serial_o(piso_to_core_data),
        .valid_serial_o(piso_to_core_valid)
    );

    // --- 3. Viterbi Core (Phiên bản Pipeline/PMU_RE mới nhất) ---
    // (Đại ca nhớ dùng file viterbi_core.v em viết ở bước trước nhé)
    viterbi_core u_viterbi_core (
        .clk(clk),
        .rst_n(rst_n),
        .piso_data_i(piso_to_core_data),
        .valid_i(piso_to_core_valid),
        .core_data_o(core_to_sipo_data),
        .core_valid_o(core_to_sipo_valid)
    );

    // --- 4. SIPO ---
    sipo u_sipo (
        .clk(clk),
        .rst_n(rst_n),
        .data_serial_i(core_to_sipo_data),
        .valid_serial_i(core_to_sipo_valid),
        .data_parallel_o(data_o),
        .byte_ready_o(valid_o)
    );

    // Busy Logic:
    // Bây giờ hệ thống chỉ "bận" thực sự (từ chối input) khi FIFO đã đầy.
    // Nếu FIFO chưa đầy, bên ngoài vẫn có thể bắn data vào thoải mái.
    assign busy_o = fifo_full;

endmodule
