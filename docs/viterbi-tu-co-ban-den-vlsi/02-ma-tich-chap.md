# 2. Mã tích chập của dự án

## Một bộ nhớ ngắn trong encoder

Ta học một encoder có:

- Một bit dữ liệu vào mỗi lần.
- Hai bit mã hóa ra mỗi lần, nên code rate là 1/2.
- Hai bit nhớ. Cùng bit hiện tại, hai bit nhớ tạo thành bốn trạng thái.
- Constraint length K=3: một bit hiện tại cộng hai bit nhớ.

Gọi bit đầu vào hiện tại là u. Trước khi xử lý bit đó, gọi hai bit nhớ là q1 và q0:

    q1 = bit vào trước đó
    q0 = bit vào cách đây hai bước
    trạng thái hiện tại = {q1, q0}

Encoder dùng hai đa thức sinh:

    g0 = 111
    g1 = 101

Trong quy ước của bài học này, phép tính là:

    v0 = u XOR q1 XOR q0
    v1 = u XOR q0
    ký hiệu đầu ra = {v0, v1}
    trạng thái kế tiếp = {u, q1}

XOR cho ra 1 khi số bit 1 ở các đầu vào là lẻ. Ví dụ 1 XOR 1 = 0, còn 1 XOR 0 = 1.

## Bốn trạng thái

Ta đặt tên cho các cặp bit nhớ như sau:

| Trạng thái | {q1,q0} |
|---|---:|
| S0 | 00 |
| S1 | 01 |
| S2 | 10 |
| S3 | 11 |

Bit vào 0 hoặc 1 quyết định nhánh đi ra. Bảng dưới ghi trạng thái kế tiếp và cặp bit được phát:

| Trạng thái hiện tại | u=0 → trạng thái / đầu ra | u=1 → trạng thái / đầu ra |
|---|---|---|
| S0 (00) | S0 / 00 | S2 / 11 |
| S1 (01) | S0 / 11 | S2 / 00 |
| S2 (10) | S1 / 10 | S3 / 01 |
| S3 (11) | S1 / 01 | S3 / 10 |

Bảng này là cầu nối giữa phép XOR và sơ đồ trellis. Mỗi hàng có hai nhánh vì encoder chỉ nhận một bit: 0 hoặc 1.

## Ví dụ mã hóa bằng tay

Giả sử encoder bắt đầu ở S0, trạng thái 00, và dữ liệu là 1, 0, 1:

| Bước | Trạng thái trước | Bit vào | Cặp bit ra | Trạng thái sau |
|---:|---|---:|---:|---|
| 1 | S0 | 1 | 11 | S2 |
| 2 | S2 | 0 | 10 | S1 |
| 3 | S1 | 1 | 00 | S2 |

Chuỗi phát là:

    11 10 00

Mỗi bit dữ liệu tạo ra hai bit mã hóa. Vì thế ba bit dữ liệu thành sáu bit truyền.

## Những quy ước không được để mơ hồ

Các công thức trên đủ để học thuật toán, nhưng một hệ thống hoàn chỉnh còn phải ghi rõ:

- Encoder bắt đầu ở trạng thái nào.
- Có thêm các bit đuôi để kết thúc ở trạng thái 0 hay không.
- Bit nào trong một word được gửi trước.
- Trong cặp {v0,v1}, bit nào đi trước.
- Byte đầu ra được ghép theo thứ tự nào.

Trong RTL hiện tại, PISO lấy cặp đầu tiên từ data_i[15:14], rồi tiếp tục các cặp thấp hơn. Điều đó xác định một phần thứ tự phát, nhưng hợp đồng bit đầu-cuối giữa encoder, decoder và testbench vẫn cần được kiểm tra cùng nhau.

**Ý chính:** mã tích chập là một máy trạng thái nhỏ; mỗi bit đầu vào chọn nhánh, và nhánh đó phát hai bit.

