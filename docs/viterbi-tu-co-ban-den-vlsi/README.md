# Học bộ giải mã Viterbi: từ bài toán thực tế đến VLSI

Bộ tài liệu này dành cho người muốn học lại từ đầu. Ta đi theo thứ tự:

**truyền dữ liệu bị nhiễu → mã hóa có dư thừa → giải mã Viterbi → kiến trúc phần cứng → RTL và kiểm chứng → thiết kế VLSI.**

Không cần biết trước Viterbi, Verilog hay OpenLane. Mỗi bài giải thích ý tưởng trước, rồi mới nối ý tưởng đó với dự án trong thư mục `docs/ref`.

## Lộ trình

1. [Bài toán thực tế: làm sao nhận đúng dữ liệu khi có nhiễu?](01-bai-toan-truyen-du-lieu.md)
2. [Mã tích chập: encoder ghi nhớ lịch sử như thế nào?](02-ma-tich-chap.md)
3. [Viterbi: chọn đường đi có vẻ hợp lý nhất](03-giai-ma-viterbi.md)
4. [Từ thuật toán sang các khối phần cứng](04-tu-thuat-toan-den-phan-cung.md)
5. [RTL, xung clock và giao tiếp dữ liệu](05-rtl-va-giao-tiep.md)
6. [Kiểm chứng: làm sao biết mạch giải mã đúng?](06-kiem-chung.md)
7. [Từ RTL đến layout VLSI](07-tu-rtl-den-vlsi.md)
8. [Bản đồ dự án và bài tập tự học](08-ban-do-du-an-va-bai-tap.md)

## Cách học

- Đọc lần lượt; chưa cần mở EDA ở những bài đầu.
- Sau bài 3, hãy tự làm lại ví dụ bằng giấy hoặc bảng tính.
- Khi sang bài RTL, coi quy ước trong bài 2 là quy ước tham chiếu. Đối chiếu riêng với RTL hiện tại vì dự án có nhiều phiên bản và một số quy ước chưa được ghi thành hợp đồng rõ ràng.
- Khi gặp lỗi, kiểm tra từng tầng: encoder tham chiếu, thuật toán, module, giao tiếp, rồi mới đến layout.

## Ký hiệu dùng xuyên suốt

- `u`: bit dữ liệu gốc đưa vào encoder.
- `S0` đến `S3`: bốn trạng thái của encoder có hai bit nhớ.
- `00`, `01`, `10`, `11`: một ký hiệu mã hóa gồm hai bit.
- `BM`: chi phí nhánh; `PM`: chi phí đường đi.
- `valid`: dữ liệu ở chu kỳ này có ý nghĩa.
- `TBL`: độ sâu truy vết (traceback depth).

