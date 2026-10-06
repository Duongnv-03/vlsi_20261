# 8. Bản đồ dự án và bài tập tự học

## Thư mục nào để đọc trước?

Các tài liệu dưới docs/ref là tài liệu tham khảo và có nhiều phiên bản cũ, không phải một giáo trình có thứ tự. Với người mới học, đi theo thứ tự sau:

1. Đọc bộ bài học này từ đầu đến cuối.
2. Đọc [đặc tả cũ](../ref/old_spec/Spec_Viterbi_Decoder_ver2%20.docx) để xem yêu cầu ban đầu.
3. Đọc [README của bản VLSI report](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/README.md) để xem kiến trúc và flow mà bản đó mô tả.
4. Đọc RTL theo thứ tự: [bmu.v](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/design/bmu.v), [acsu.v](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/design/acsu.v), [pmu.v](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/design/pmu.v), [tbu.v](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/design/tbu.v), rồi [viterbi_core.v](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/design/viterbi_core.v).
5. Sau đó mới đọc [system_top.v](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/design/system_top.v), FIFO, PISO/SIPO và cấu hình OpenLane.

## Bài tập theo từng nấc

### Nấc 1 — hiểu encoder

1. Tự tính đầu ra cho 0,0,1,1 từ trạng thái S0.
2. Tự điền lại bảng tám nhánh từ hai phương trình XOR.
3. Thêm bit đuôi 0,0: encoder kết thúc ở trạng thái nào?

### Nấc 2 — hiểu Viterbi

1. Với đầu vào sạch 11 10 00, hãy tính PM ở mỗi trạng thái sau mỗi cặp.
2. Lật bit đầu tiên của ký hiệu thứ hai rồi tính lại.
3. Ghi predecessor thắng cho mỗi trạng thái đích và traceback ra chuỗi dữ liệu.
4. Thử trường hợp hai ứng viên hòa PM. Xác định quy tắc phá hòa trong mô hình của bạn.

### Nấc 3 — hiểu RTL

1. Với từng module, ghi đầu vào, đầu ra và cạnh clock làm thay đổi thanh ghi nào.
2. Vẽ chu kỳ của valid_i đi từ PISO qua core tới SIPO.
3. Kiểm tra busy_o có ngăn được mất dữ liệu khi FIFO đầy không.
4. Chạy chuỗi dài trong mô hình để tìm xem PM 8 bit có quay vòng không.

### Nấc 4 — hiểu VLSI

1. Tìm chu kỳ clock trong file config và đổi ra MHz.
2. Trong báo cáo flow, tìm cell count, diện tích và đường timing chậm nhất.
3. Giải thích vì sao DRC/LVS pass không thay thế được test chức năng.

## Câu hỏi cần chốt trước khi gọi đây là bản thiết kế chuẩn

- Quy ước trạng thái, đa thức và thứ tự bit có khớp giữa encoder tham chiếu, RTL và testbench không?
- Dữ liệu đầu vào là các word liên tục hay các khung độc lập?
- Khung bắt đầu/kết thúc thế nào? Có bit đuôi không?
- busy_o, dvalid_i và hành vi khi FIFO đầy được đảm bảo ra sao?
- TBL là bao nhiêu và độ trễ/flush cuối khung được định nghĩa thế nào?
- PM được chuẩn hóa hoặc bảo vệ khỏi tràn ra sao?
- Tần số mục tiêu chính thức là 50 MHz hay 100 MHz?
- Thư mục RTL nào là nguồn chuẩn cho simulation và OpenLane?

Khi trả lời được các câu hỏi này, có thể viết một đặc tả mới ngắn và nhất quán. Bộ tài liệu học này giải thích nền tảng; nó không thay thế đặc tả giao tiếp cuối cùng của chip.

