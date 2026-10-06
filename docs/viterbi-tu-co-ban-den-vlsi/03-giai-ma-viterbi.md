# 3. Viterbi: tìm đường đi có chi phí thấp nhất

## Từ trạng thái sang trellis

Nếu lặp bảng chuyển trạng thái theo thời gian, ta được một đồ thị gọi là **trellis**. Ở mỗi thời điểm, decoder biết một cặp bit nhận được. Nó cần xác định nhánh nào có thể đã tạo ra cặp đó.

Ta dùng hai loại chi phí:

- **Branch metric (BM):** số bit khác nhau giữa cặp nhận và cặp dự đoán trên một nhánh. Với cặp 2 bit, BM là 0, 1 hoặc 2.
- **Path metric (PM):** tổng BM của các nhánh trên một đường đi từ lúc bắt đầu đến hiện tại.

Ví dụ nhận 11:

| Cặp dự đoán | Số bit khác | BM |
|---|---:|---:|
| 11 | 0 | 0 |
| 10 | 1 | 1 |
| 00 | 2 | 2 |

Đây là khoảng cách Hamming: chỉ đếm số vị trí khác nhau.

## Quy tắc chọn đường

Viterbi thực hiện lặp lại ba thao tác:

1. Tính BM của các nhánh dựa trên cặp bit nhận.
2. Với từng trạng thái đích, cộng PM của trạng thái trước với BM của nhánh.
3. Giữ ứng viên có tổng nhỏ nhất; ghi lại trạng thái trước đã thắng.

Lý do có thể bỏ ứng viên thua: nếu hai đường cùng kết thúc ở một trạng thái, mọi phần tiếp theo có thể nối vào cả hai như nhau. Đường có chi phí cao hơn sẽ không thể trở thành đường tốt hơn đường có chi phí thấp hơn.

## Ví dụ có một bit lỗi

Encoder ở bài trước phát cho dữ liệu 1,0,1:

    Phát sạch: 11 10 00
    Nhận:      11 11 00
                  ^

Một bit trong cặp thứ hai đã bị lật. Bắt đầu ở S0, có thể tính PM sau từng cặp. Ký hiệu ∞ nghĩa là trạng thái chưa thể tới được.

| Sau cặp nhận | PM tại S0 | PM tại S1 | PM tại S2 | PM tại S3 |
|---|---:|---:|---:|---:|
| Bắt đầu | 0 | ∞ | ∞ | ∞ |
| 11 | 2 | ∞ | 0 | ∞ |
| 11 | 4 | 1 | 2 | 1 |
| 00 | 3 | 2 | **1** | 3 |

Trạng thái có PM nhỏ nhất cuối cùng là S2. Để biết chuỗi bit đầu vào nào đi tới đó, ta lần ngược các quyết định đã lưu:

    S0 → S2 → S1 → S2
          1     0     1

Decoder khôi phục được 1,0,1, dù cặp thứ hai nhận không giống cặp đã phát.

## Vì sao không lưu mọi đường đi?

Sau n bit có thể có tới 2^n chuỗi đầu vào. Viterbi chỉ giữ đường tốt nhất đi tới mỗi trạng thái. Với bốn trạng thái, mỗi bước chỉ phải so sánh một số ít ứng viên.

Để khôi phục bit đầu vào, phần cứng cần lưu quyết định thắng qua một khoảng thời gian. Sau khi đủ sâu, decoder truy vết từ trạng thái có PM thấp nhất. Độ sâu đó thường gọi là TBL.

## TBL không phải một con số ma thuật

TBL=15 trong tài liệu cũ là một tham số thiết kế, không tự nó xác định:

- Độ trễ chính xác theo chu kỳ.
- Thời điểm byte đầu ra đầu tiên hợp lệ.
- Cách xử lý khi một gói kết thúc trước khi đủ độ sâu.
- Cách chọn trạng thái cuối nếu encoder có bit đuôi.

Các quy tắc này phải được mô tả cùng giao thức khung dữ liệu.

**Ý chính:** mỗi bước decoder cập nhật bốn PM và lưu quyết định; sau đó traceback dùng lịch sử đó để phát lại bit dữ liệu.

