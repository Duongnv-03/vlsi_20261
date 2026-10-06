# 6. Kiểm chứng: làm sao biết decoder đúng?

## Tạo một nguồn sự thật độc lập

Trước khi tin RTL, cần một mô hình tham chiếu nhỏ chạy trên máy tính:

1. Nhận chuỗi bit gốc.
2. Mã hóa theo đúng trạng thái, đa thức và thứ tự bit đã chốt.
3. Có thể lật một số bit để mô phỏng nhiễu.
4. So kết quả decoder với chuỗi bit gốc.

Mô hình này là **golden model**. Nó nên được viết độc lập với cách RTL được chia module; nếu sao chép cùng một lỗi quy ước thì so sánh sẽ không phát hiện lỗi.

## Kiểm tra theo từng tầng

1. **Encoder tham chiếu:** xác minh bảng chuyển trạng thái bằng vài chuỗi ngắn.
2. **BMU:** thử đủ bốn ký hiệu nhận 00, 01, 10, 11 cho từng loại nhánh.
3. **ACSU/PMU:** kiểm tra tổng, nhánh thắng, phá hòa, reset và chuỗi dài.
4. **TBU:** kiểm tra đường quyết định, TBL, độ trễ khởi động và thứ tự bit phát.
5. **PISO/SIPO/FIFO:** kiểm tra bit đầu tiên, bit cuối, word liên tiếp, reset và FIFO đầy/rỗng.
6. **Top:** so cả word đầu vào và byte đầu ra theo chu kỳ valid.

## Các ca nên có

- Không có lỗi.
- Lật từng vị trí của một hoặc nhiều ký hiệu 2 bit.
- Nhiều lỗi gần nhau và chuỗi có burst lỗi.
- Toàn 0, toàn 1, mẫu xen kẽ 1010...
- Reset trước khi chạy và reset giữa khung.
- Word đầu vào liên tiếp, có khoảng nghỉ, hoặc đúng lúc FIFO đầy.
- Chuỗi dài để kiểm tra PM có tràn hay không.
- Khung ngắn hơn traceback depth và khung có bit đuôi, nếu thiết kế hỗ trợ hai trường hợp đó.

Không nên biến câu “sửa được một bit” thành tiêu chí chung khi chưa định nghĩa độ dài khung, trạng thái đầu-cuối và vị trí lỗi. Hãy tạo test cụ thể theo mô hình mã đang dùng.

## Simulation không phải physical verification

- Mô phỏng RTL kiểm tra hành vi logic trong các tình huống đã thử.
- STA kiểm tra đường trễ theo thư viện và ràng buộc clock.
- DRC kiểm tra hình học layout theo luật chế tạo.
- LVS so sánh kết nối layout với netlist.

DRC/LVS sạch không chứng minh thuật toán giải mã đúng. Ngược lại, testbench pass cũng không chứng minh chip đạt timing hay layout hợp lệ.

## Đọc các kết quả đang lưu trong dự án

[README hiện tại](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/README.md) ghi kết quả test tổng hợp, trong khi [log mô phỏng được lưu](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/testbench/log_system) báo 2/3 ca pass. Đây là các artefact từ những lần chạy/phiên bản khác nhau; cần chạy lại trên một bộ RTL và testbench đã chọn làm chuẩn trước khi dùng làm bằng chứng.

**Ý chính:** kiểm thử cần một mô hình độc lập, các ca có chủ đích và đối chiếu đúng dữ liệu cùng chu kỳ valid.

