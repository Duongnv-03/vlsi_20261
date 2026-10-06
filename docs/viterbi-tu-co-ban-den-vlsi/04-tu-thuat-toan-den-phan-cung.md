# 4. Từ thuật toán Viterbi sang các khối phần cứng

## Một bước xử lý của decoder

Decoder nhận một ký hiệu 2 bit ở mỗi bước. Các khối chính của thuật toán là:

    ký hiệu nhận
        ↓
    BMU → ACSU → PMU
              ↘ lưu quyết định → TBU → bit dữ liệu

### BMU — Branch Metric Unit

BMU so sánh ký hiệu nhận với các ký hiệu dự đoán trên tám nhánh của trellis. Nó tạo BM từ 0 đến 2.

### ACSU — Add, Compare, Select

Mỗi trạng thái đích có hai trạng thái trước có thể đi tới. ACSU:

1. Cộng PM trạng thái trước với BM của nhánh.
2. So sánh hai tổng.
3. Chọn tổng nhỏ hơn làm PM mới.
4. Ghi lại nhánh thắng để traceback.

Nếu hai tổng bằng nhau, thiết kế cần quy tắc phá hòa cố định. Điều đó giúp mô phỏng và phần cứng cho kết quả nhất quán.

### PMU — Path Metric Unit

PMU giữ bốn PM hiện tại để bước sau dùng tiếp. Trạng thái ban đầu thường bắt đầu ở S0; ba trạng thái kia phải được xem là chưa tới được.

Trong phần cứng không có số ∞ thực sự. Có thể dùng giá trị lớn, nhưng phép cộng phải được thiết kế để giá trị này không tràn thành số nhỏ. Một cách phổ biến khác là chuẩn hóa: trừ PM nhỏ nhất khỏi cả bốn PM ở mỗi bước. Việc này giữ nguyên thứ tự tốt-xấu giữa các đường.

### TBU — Traceback Unit

TBU lưu quyết định của ACSU rồi dùng chúng để chọn lại các bit dữ liệu.

Có hai cách triển khai thường gặp:

- **Traceback qua bộ nhớ:** lưu quyết định theo thời gian, chọn trạng thái cuối rồi lần ngược. Tiết kiệm số thanh ghi nhưng cần bộ nhớ và điều khiển đọc/ghi cẩn thận.
- **Register exchange:** mỗi trạng thái mang theo một lịch sử bit; mỗi chu kỳ lịch sử được sao chép sang trạng thái kế tiếp phù hợp. Dễ hình dung hơn khi mới học, nhưng có thể tốn nhiều thanh ghi.

## Bao quanh lõi giải mã

Ở mức hệ thống, dự án còn có các khối giao tiếp:

    data_i[15:0] → FIFO → PISO → Viterbi core → SIPO → data_o[7:0]

- **FIFO:** đệm các word 16 bit khi phần lõi chưa xử lý kịp.
- **PISO:** chuyển một word 16 bit thành tám ký hiệu 2 bit.
- **Viterbi core:** giải mã từng ký hiệu.
- **SIPO:** gom các bit giải mã thành byte 8 bit.

FIFO, PISO và SIPO không làm thuật toán Viterbi đúng hơn; chúng xử lý tốc độ, thứ tự dữ liệu và giao tiếp giữa các khối.

## So với RTL đang có

Trong [RTL của dự án](../ref/VLSI_report/Viterbi-Decoder-Implementation-and-Verification/design/viterbi_core.v):

- BMU tính khoảng cách Hamming.
- ACSU là logic tổ hợp tạo PM mới và quyết định.
- PMU lưu PM qua các cạnh lên của clock.
- TBU dùng register-exchange với lịch sử 15 bit.

Điều này khác cách mô tả PMU/TBU lưu lịch sử kiểu RAM trong [đặc tả cũ](../ref/old_spec/Spec_Viterbi_Decoder_ver2%20.docx). Hai cách đều có thể dạy thuật toán, nhưng không nên trộn chúng khi đọc sơ đồ hoặc kiểm tra độ trễ.

Một điểm cần chú ý khi học RTL hiện tại: PM trong ACSU/PMU rộng 8 bit, và ACSU cộng trực tiếp BM vào PM. Khi giá trị vượt 255, phép cộng có thể quay vòng nếu không có bão hòa hoặc chuẩn hóa. Đây là rủi ro nhìn thấy từ mã nguồn; cần kiểm tra bằng mô hình và test có chuỗi dài trước khi kết luận ảnh hưởng thực tế.

**Ý chính:** BMU, ACSU, PMU và TBU hiện thực thuật toán; FIFO/PISO/SIPO đưa dữ liệu vào và ra đúng nhịp.

