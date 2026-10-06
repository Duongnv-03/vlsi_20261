# 7. Từ RTL đến thiết kế VLSI

## RTL chưa phải layout

RTL mô tả chức năng bằng thanh ghi, phép toán và kết nối. Công cụ thiết kế biến mô tả đó qua nhiều bước để tạo layout các cell vật lý:

    RTL
     ↓
    Simulation
     ↓
    Synthesis → netlist cổng
     ↓
    Floorplan → Placement → Clock Tree → Routing
     ↓
    STA + DRC + LVS
     ↓
    GDSII

Tên bước và mức tự động hóa thay đổi tùy flow, nhưng ý nghĩa cơ bản như sau:

- **Synthesis:** ánh xạ phép cộng, so sánh, mux, thanh ghi thành standard cell.
- **Floorplan:** đặt vùng lõi và các ràng buộc ban đầu.
- **Placement:** đặt cell lên mặt phẳng.
- **Clock tree synthesis:** phân phối clock đến các thanh ghi.
- **Routing:** nối các cell bằng dây kim loại.
- **STA:** tính xem các đường tín hiệu có kịp trong chu kỳ clock không.
- **DRC/LVS:** kiểm tra luật hình học và đối chiếu kết nối.

## Viterbi tạo ra phần cứng gì?

- BMU tạo các phép XOR và đếm số bit khác.
- ACSU tạo bộ cộng, bộ so sánh và mux chọn đường.
- PMU và TBU tạo nhiều thanh ghi.
- FIFO tạo bộ nhớ nhỏ, con trỏ và logic điều khiển.
- Clock và reset nối tới nhiều thanh ghi, nên ảnh hưởng đến routing và diện tích.

Một thuật toán có cùng chức năng có thể cho diện tích khác nhau tùy cách lưu lịch sử, độ rộng PM, mức pipeline và cách tổng hợp.

## Tần số clock và timing

Chu kỳ clock là thời gian giữa hai cạnh lên liên tiếp. Ví dụ mục tiêu 50 MHz tương ứng:

    T = 1 / 50 MHz = 20 ns

Nếu đường từ một thanh ghi qua logic tổ hợp đến thanh ghi kế tiếp lâu hơn ngân sách timing, thiết kế không đạt mục tiêu. Có thể giảm logic trên đường tới hạn, thêm pipeline, hoặc điều chỉnh mục tiêu hệ thống nếu yêu cầu cho phép.

Clock period trong [OpenLane config hiện tại](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/OpenLane/designs/viterbi/config.tcl) là 20 ns. Đặc tả cũ nêu 100 MHz, nên cần chọn một yêu cầu chính thức trước khi đánh giá timing.

## Cần tách ba câu hỏi

1. **Đúng chức năng không?** Trả lời bằng mô hình và simulation.
2. **Đủ nhanh/nhỏ/ít điện không?** Trả lời bằng báo cáo synthesis, STA, area và power.
3. **Layout đúng hình học và kết nối không?** Trả lời bằng DRC/LVS.

Kết quả VLSI được ghi trong [result.md](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/result.md) là báo cáo của một run cũ. Hãy coi đó là tư liệu tham khảo cho đến khi xác nhận run đó dùng đúng RTL, đúng ràng buộc và đúng PDK hiện đang chọn.

**Ý chính:** VLSI bắt đầu sau khi chức năng RTL đã được mô tả và kiểm chứng; layout sạch là một loại bằng chứng riêng với simulation.

