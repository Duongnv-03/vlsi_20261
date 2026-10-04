module sipo (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        data_serial_i,  // Bit tu TBU
    input  wire        valid_serial_i, // Co valid tu TBU
    output reg [7:0]   data_parallel_o,
    output reg         byte_ready_o    // Bao da du 8 bit
);

    reg [2:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_parallel_o <= 8'b0;
            byte_ready_o    <= 1'b0;
            count           <= 3'b0;
        end else begin
            byte_ready_o <= 1'b0; // Mac dinh muc thap
            if (valid_serial_i) begin
                // Luu y: Traceback thuong tra ve bit theo thu tu nguoc (moi nhat -> cu nhat)
                // Hoac xuoi tuy vao cach TBU ban ra.
                // O TBU tren ta trace tu cuoi ve dau -> Bit nhan duoc la bit cuoi cung cua goi (LSB hay MSB tuy endian).
                // Gia su ta dich bit vao tu MSB den LSB hoac nguoc lai.
                // De dung thu tu goi tin goc (thuong gui bit 0 truoc), va TBU tra bit 7 truoc...
                // Ta shift right:
                data_parallel_o <= {data_serial_i, data_parallel_o[7:1]}; 
                
                // 3. Quan ly bo dem bit
                if (count == 3'd7) begin
                    byte_ready_o <= 1'b1;
                    count        <= 3'b0; // Reset dem khi du 8 bit
                end else begin
                    byte_ready_o <= 1'b0;
                    count        <= count + 1'b1;
                end
            end else begin
                // 4. Nhanh ELSE quan trong: Giu nguyen moi gia tri khi du lieu chua san sang
                data_parallel_o <= data_parallel_o;
                count           <= count;
                byte_ready_o    <= 1'b0; // Luon dam bao ready = 0 khi khong co bit moi
            end
        end
    end

endmodule
