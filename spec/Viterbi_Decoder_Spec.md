# Đặc tả thiết kế bộ giải mã Viterbi

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái tài liệu | Draft — chuẩn hóa từ Requirements.pdf |
| Phiên bản | 0.1 |
| Ngôn ngữ | Tiếng Việt |
| Nguồn yêu cầu | [Requirements.pdf](Requirements.pdf) |

> Bản này chuyển các yêu cầu trong PDF thành mục có thể thiết kế và nghiệm thu. Các điểm PDF chưa quy định hoặc tự mâu thuẫn được đánh dấu TBD; chúng chưa phải yêu cầu mới.

## 1. Mục tiêu và phạm vi

Thiết kế một bộ giải mã dùng thuật toán Viterbi cho mã tích chập nhị phân. Thiết kế cần có mô tả RTL, testbench, kiểm tra chức năng, tối ưu và layout với các giới hạn PPA dưới đây.

Đặc tả này chốt hành vi và tiêu chí nghiệm thu ở mức hệ thống. Cách chia module, loại bộ nhớ traceback, số pipeline stage và công cụ triển khai thuộc phần kiến trúc, trừ khi được chốt thành yêu cầu riêng.

## 2. Yêu cầu chức năng

| ID | Yêu cầu |
|---|---|
| FR-01 | Bộ giải mã phải dùng thuật toán Viterbi để khôi phục chuỗi thông tin từ chuỗi mã hóa. |
| FR-02 | Mã sử dụng constraint length K=3 và coding rate R=1/2. |
| FR-03 | Encoder tham chiếu phải dùng hai phương trình đầu ra được định nghĩa ở mục 3. |
| FR-04 | Word mã hóa có độ rộng 16 bit; word thông tin khôi phục có độ rộng 8 bit. |
| FR-05 | Testbench phải giải mã toàn bộ vector mã hóa trong output.txt và so sánh với vector chuẩn tương ứng trong input.txt. |
| FR-06 | Tất cả vector trong bộ test được cung cấp phải pass; yêu cầu pass rate là 100%. |

## 3. Định nghĩa mã tích chập

### 3.1 Tham số và phương trình

- Một bit dữ liệu vào tạo hai bit mã hóa.
- Constraint length K=3, gồm bit hiện tại và hai bit nhớ.
- Hai đa thức sinh theo biểu diễn nhị phân là 111 và 101, tương ứng với x²+x+1 và x²+1.
- Gọi bit vào hiện tại là u; gọi hai bit nhớ trước cạnh cập nhật là S0 và S1.

    O1 = u XOR S0 XOR S1
    O2 = u XOR S1
    symbol = {O1, O2}

Sau khi tạo đầu ra:

    next_S0 = u
    next_S1 = old_S0

### 3.2 Bảng chuyển trạng thái

Trạng thái được viết theo thứ tự {S0,S1}. Cặp đầu ra được viết theo thứ tự {O1,O2}.

| Trạng thái hiện tại | Bit vào u | Đầu ra O1O2 | Trạng thái kế tiếp |
|---|---:|---:|---|
| 00 | 0 | 00 | 00 |
| 00 | 1 | 11 | 10 |
| 01 | 0 | 11 | 00 |
| 01 | 1 | 00 | 10 |
| 10 | 0 | 10 | 01 |
| 10 | 1 | 01 | 11 |
| 11 | 0 | 01 | 01 |
| 11 | 1 | 10 | 11 |

Các chuyển trạng thái trên được suy ra trực tiếp từ phương trình đầu ra và quy tắc dịch thanh ghi ở mục 3.1.

### 3.3 Trạng thái bắt đầu và thứ tự bit

Ví dụ encoder trong Requirements.pdf bắt đầu với S0=S1=0. Tài liệu cũng trình bày ví dụ giải mã trong đó chuỗi bit xử lý theo thời gian là 100110, còn word thông tin được ghi là 011001. Điều này gợi ý thứ tự serial LSB-first; tuy nhiên PDF chưa định nghĩa rõ cách ánh xạ bit của word 8-bit và word 16-bit.

Do đó, trạng thái bắt đầu 00 được yêu cầu cho ví dụ tham chiếu. Việc có reset về 00 ở đầu mỗi word/khung hay giữ trạng thái giữa các word vẫn là TBD tại mục 8.

## 4. Hành vi giải mã

### 4.1 Branch metric

Decoder nhận mỗi ký hiệu 2 bit và so sánh với ký hiệu dự đoán trên từng nhánh. Chi phí nhánh là khoảng cách Hamming:

    BM = số vị trí bit khác nhau

Với ký hiệu 2 bit, BM có giá trị từ 0 đến 2.

### 4.2 Path metric và survivor

Tại mỗi thời điểm, với mỗi trạng thái đích, decoder phải:

1. Cộng path metric của từng trạng thái trước hợp lệ với branch metric của nhánh tương ứng.
2. So sánh các ứng viên đi vào cùng trạng thái đích.
3. Giữ ứng viên có tổng metric nhỏ nhất và lưu quyết định survivor.
4. Dùng chuỗi quyết định survivor để traceback và khôi phục dữ liệu.

Đây là phép chọn đường Viterbi toàn cục theo path metric tích lũy. Việc chỉ chọn nhánh có Hamming distance nhỏ nhất tại một thời điểm không thay thế được phép so sánh path metric.

### 4.3 Ví dụ tham chiếu ghi trong yêu cầu

Requirements.pdf nêu ví dụ decoder nhận:

    Mã hóa:          11 10 11 11 01 01
    Bit theo thời gian được khôi phục: 1 0 0 1 1 0
    Word thông tin được ghi trong PDF: 011001

Ví dụ này tương thích với phương trình tại mục 3.1 nếu serial hóa word 011001 theo thứ tự LSB-first, tạo chuỗi bit 100110.

## 5. Giao tiếp và độ rộng dữ liệu

| Tín hiệu/đối tượng | Yêu cầu |
|---|---|
| Dữ liệu mã hóa vào | 16 bit |
| Dữ liệu thông tin ra | 8 bit |
| Số bit thông tin trên mỗi word mã hóa | 8 bit theo mô tả yêu cầu |
| Clock, reset và tín hiệu điều khiển | TBD — Requirements.pdf không quy định tên, cực tính hoặc giao thức |

Đặc tả nguồn không quy định ranh giới khung, tín hiệu valid/busy, xử lý khi đầu vào liên tục, hoặc thời điểm dữ liệu đầu ra được xem là hợp lệ. Không được suy các quy tắc này từ một bản RTL cũ mà không ghi rõ là quyết định kiến trúc bổ sung.

## 6. Yêu cầu PPA

| Chỉ tiêu | Ngưỡng bắt buộc | Mục tiêu |
|---|---:|---|
| Tần số hoạt động | Tối thiểu 200 MHz | Cao nhất có thể; khi so sánh phương án, phương án có tần số cao hơn được ưu tiên |
| Diện tích | Tối đa 7000 µm² | Không vượt ngưỡng |
| Công suất tiêu thụ | Tối đa 1.5 mW | Không vượt ngưỡng |

Các giới hạn này áp dụng cho kết quả layout theo yêu cầu “Layout với các yêu cầu về PPA”. Cách đo chính xác — stage của flow, corner, điện áp, nhiệt độ, tải đầu ra và hoạt động dùng cho power — chưa được quy định trong PDF và cần được ghi cùng báo cáo nghiệm thu.

## 7. Kiểm chứng và tiêu chí nghiệm thu

### 7.1 Bộ vector bắt buộc

- output.txt chứa các word mã hóa 16-bit cần đưa vào decoder.
- input.txt chứa word 8-bit kỳ vọng tương ứng.
- Testbench phải đọc hai file tự động, giải mã từng vector và đối chiếu với word chuẩn.
- Tất cả vector phải đúng; pass rate yêu cầu là 100%.

### 7.2 Điều kiện nghiệm thu

Thiết kế đạt yêu cầu khi đồng thời thỏa:

1. Testbench xử lý toàn bộ vector trong hai file và không có mismatch.
2. Tần số đo được ít nhất 200 MHz.
3. Diện tích không lớn hơn 7000 µm².
4. Công suất không lớn hơn 1.5 mW.
5. Có kết quả layout và báo cáo PPA dùng cùng một phiên bản RTL và cùng cấu hình đo.

Requirements.pdf không nêu số lượng vector, định dạng dòng, hoặc vị trí của hai file. Tại thời điểm soạn bản này, thư mục spec hiện chỉ có Requirements.pdf; input.txt và output.txt chưa có trong workspace.

## 8. Điểm cần chốt để phát hành bản spec hoàn chỉnh

| ID | Điểm chưa xác định hoặc mâu thuẫn | Ảnh hưởng |
|---|---|---|
| TBD-01 | Trang 2 ghi payload 011001 tạo mã hóa 010111111011. Trang 4 dùng mã hóa 111011110101, giải ra chuỗi serial 100110 rồi ghi payload là 011001. Phương trình tại mục 3.1 với serial LSB-first cho kết quả 111011110101, không phải 010111111011. | Chọn một vector chuẩn; kiểm tra hoặc sửa ví dụ trang 2. |
| TBD-02 | Không định nghĩa bit 0/bit 7 nào được xử lý trước trong word 8-bit, hoặc cặp ký hiệu đầu tiên nằm ở bit nào của word 16-bit. | Cần để encoder tham chiếu, RTL và testbench tạo cùng chuỗi. |
| TBD-03 | Không nói mỗi word 16-bit là khung độc lập hay là một đoạn của luồng liên tục. | Quyết định reset trạng thái, chọn trạng thái cuối và ghép byte đầu ra. |
| TBD-04 | Không quy định bit đuôi, trạng thái kết thúc hoặc cách flush traceback cuối khung. | Ảnh hưởng giải mã các bit cuối và độ trễ. |
| TBD-05 | Không nêu traceback depth. | Không tự lấy TBL=15 từ đặc tả cũ làm yêu cầu của PDF này. |
| TBD-06 | Không nêu cách phá hòa khi hai đường có cùng path metric, cũng không nêu độ rộng/chuẩn hóa path metric. | Cần chốt để mô hình tham chiếu và RTL có hành vi xác định, nhất là với chuỗi dài. |
| TBD-07 | Không quy định clock/reset, latency, throughput, hay valid/busy. | Cần bổ sung nếu cần nghiệm thu giao tiếp theo chu kỳ. |
| TBD-08 | Không định nghĩa methodology đo frequency, area và power. | Cần dùng cùng một flow/corner khi kết luận đạt PPA. |
| TBD-09 | Không có input.txt/output.txt trong workspace hiện tại. | Chưa thể xác nhận yêu cầu pass 100% cho bộ vector chính thức. |

## 9. Phân tách yêu cầu và lựa chọn kiến trúc

Requirements.pdf bắt buộc sử dụng Viterbi và các giới hạn PPA, nhưng không bắt buộc cấu trúc module hoặc cách lưu survivor. Có thể chọn register-exchange hoặc traceback qua bộ nhớ sau khi đánh giá PPA; lựa chọn đó không được làm thay đổi các phương trình mã, độ rộng giao tiếp hoặc kết quả vector đã chốt.

Các tham số từng xuất hiện trong tài liệu/RTL tham khảo — chẳng hạn TBL=15, clock 50 MHz, FIFO depth, cực tính reset hoặc tên cổng — không trở thành yêu cầu của bản này trừ khi được bổ sung rõ ràng vào phiên bản spec tiếp theo.
