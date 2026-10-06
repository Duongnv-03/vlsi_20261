# 5. RTL, xung clock và giao tiếp dữ liệu

## RTL mô tả phần cứng

RTL (Register-Transfer Level) mô tả dữ liệu đi qua thanh ghi và phép toán giữa các thanh ghi. Nó không phải chương trình chạy tuần tự như Python.

Trong Verilog thường gặp hai loại logic:

- **Logic tổ hợp:** đầu ra đổi theo đầu vào hiện tại; ví dụ BMU và phép so sánh trong ACSU.
- **Logic tuần tự:** giá trị được giữ trong thanh ghi và cập nhật ở cạnh clock; ví dụ PMU, bộ đếm, FIFO và các lịch sử trong TBU.

Với @(posedge clk), trạng thái được cập nhật ở cạnh lên. Dùng phép gán không chặn <= trong logic tuần tự giúp các thanh ghi cùng cập nhật theo trạng thái cũ của chu kỳ đó.

## valid nói rằng dữ liệu có nghĩa

Một giao tiếp đơn giản có:

- data: giá trị đang truyền.
- valid: dữ liệu hợp lệ tại cạnh clock này.

Nếu valid=0, nơi nhận phải bỏ qua data. Nếu valid=1, nơi nhận xử lý một mẫu dữ liệu. Trong dự án, mỗi mẫu lõi là một ký hiệu gồm hai bit; PISO đưa ra valid_serial_o để báo mẫu mới.

valid không tự nó tạo ra khả năng giữ dữ liệu khi bên nhận bận. Nếu cần bên nhận từ chối mẫu, giao thức cần thêm ready hoặc một quy tắc backpressure tương đương.

## busy trong top hiện tại

system_top đặt busy_o bằng cờ FIFO đầy. Nghĩa là busy_o phản ánh khả năng nhận thêm word vào FIFO, chứ không trực tiếp báo trạng thái TBU hay toàn bộ lõi.

Nguồn dữ liệu bên ngoài cần biết rõ quy tắc: không phát dvalid_i khi FIFO đầy, hoặc có cơ chế khác để bảo đảm word không bị mất. Nếu phát đúng lúc FIFO đầy, FIFO không ghi word đó.

## Đọc thứ tự dữ liệu

PISO hiện phát cặp đầu tiên từ fifo_data_i[15:14], rồi dịch qua các cặp thấp hơn. Đây là thứ tự MSB pair trước. SIPO ghép từng bit thành byte, nhưng kết quả phụ thuộc vào chiều dịch và thứ tự bit TBU phát ra.

Vì vậy, khi kiểm tra end-to-end hãy ghi thành một bảng tường minh:

| Thời điểm | Bit dữ liệu gốc | Cặp mã hóa | Vị trí trong data_i |
|---:|---|---|---|
| 0 | bit nào? | ký hiệu đầu tiên | [15:14] |
| 1 | bit nào? | ký hiệu thứ hai | [13:12] |
| … | … | … | … |

Điền bảng này một lần sẽ ngăn được nhiều lỗi “giải mã đúng chuỗi nhưng byte bị đảo bit”.

## Độ trễ và thông lượng là hai việc khác nhau

- **Độ trễ:** mất bao lâu từ một word đầu vào đến byte đầu ra tương ứng.
- **Thông lượng:** sau khi pipeline đã chạy, mỗi bao lâu có thể nhận hoặc phát thêm dữ liệu.

TBU có thể chờ đủ TBL bước trước khi phát bit đầu tiên, nhưng sau đó vẫn phát một bit trên mỗi mẫu hợp lệ. SIPO cần tám bit hợp lệ để tạo một byte. Bởi vậy không thể chỉ cộng “8 + TBL” mà chưa định nghĩa chu kỳ valid, khoảng nghỉ giữa các gói và cách flush phần cuối.

**Ý chính:** khi đọc RTL, luôn hỏi dữ liệu nào được lấy ở cạnh clock nào và cờ valid đi cùng dữ liệu nào.

