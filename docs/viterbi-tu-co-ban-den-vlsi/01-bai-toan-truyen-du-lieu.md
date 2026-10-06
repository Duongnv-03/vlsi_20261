# 1. Bài toán thực tế: dữ liệu bị nhiễu trên đường truyền

## Hãy bắt đầu từ một cảm biến

Một cảm biến gửi số đo đến bộ điều khiển. Nếu gửi bit 1 mà nhiễu làm nó thành 0, bên nhận không thể biết bit nào đã bị đổi chỉ bằng cách nhìn vào bit nhận được.

Ví dụ:

    Đã gửi:   101101
    Nhận được: 100101

Hai chuỗi khác nhau ở một vị trí. Nếu không có thêm thông tin, bên nhận không biết chuỗi nào đúng.

## Ý tưởng đơn giản: gửi dư thông tin

Thay vì gửi mỗi bit một lần, có thể gửi lặp ba lần:

    Bit 1 → 111
    Bit 0 → 000

Nếu nhận 101, ta đoán bit ban đầu là 1 vì hai trong ba bit là 1. Đây là mã lặp. Nó dễ hiểu nhưng tốn nhiều bit truyền.

Một cách khác là để mỗi bit được gửi ra phụ thuộc vào bit hiện tại và một phần lịch sử. Bộ thu sẽ dùng chuỗi đầu ra đó để tìm lại chuỗi đầu vào hợp lý nhất. Đó là ý tưởng của **mã tích chập** và **giải mã Viterbi**.

## Vì sao cần thuật toán Viterbi?

Encoder có trạng thái nhớ. Do vậy, một bit đầu vào không chỉ quyết định hai bit đầu ra hiện tại; nó còn ảnh hưởng đến trạng thái tiếp theo và các đầu ra tương lai.

Khi dữ liệu nhận bị lỗi, ta có thể:

1. Liệt kê các chuỗi đầu vào có thể đã tạo ra nó.
2. Tính mỗi chuỗi dự đoán đầu ra nào.
3. So sánh dự đoán với dữ liệu nhận.
4. Chọn chuỗi có ít khác biệt nhất.

Liệt kê mọi chuỗi sẽ tốn rất nhiều phép tính khi chuỗi dài. Viterbi tận dụng việc nhiều chuỗi cùng đi qua một trạng thái để loại bỏ sớm những đường đi kém hơn.

## Ba từ cần nhớ

- **Encoder:** thêm dư thừa có quy luật trước khi gửi.
- **Kênh truyền:** nơi dữ liệu có thể bị lật bit, mất bit hoặc trễ.
- **Decoder:** dùng quy luật encoder để ước lượng lại dữ liệu gốc.

Trong bộ giải mã này, ta giả sử biết ranh giới các cặp bit nhận được và lỗi chủ yếu là bit 0 bị lật thành 1 hoặc ngược lại. Đây gọi là giải mã hard-decision: mỗi bit nhận chỉ là 0 hoặc 1, không kèm độ tin cậy analog.

## Tự kiểm tra

1. Nếu nhận 001 từ mã lặp ba lần, bạn sẽ đoán bit nào?
2. Vì sao thêm bit dư có thể giúp phát hiện hoặc sửa lỗi?
3. Nếu không biết quy luật encoder, bên nhận có thể khôi phục dữ liệu bằng cách nào?

**Ý chính:** bộ giải mã không “biết chắc” bit đã gửi; nó chọn lời giải phù hợp nhất với quy luật và dữ liệu nhận.

