# Hướng dẫn chạy Project Viterbi-Decoder (Windows)

Project này là một thiết kế **Viterbi Decoder** (giải mã sửa lỗi) được viết bằng ngôn ngữ **Verilog**.
Cấu trúc project:
- `design/`: Chứa các file mã nguồn Verilog (`system_top.v`, `viterbi_core.v`, ...).
- `testbench/`: Chứa các file kiểm thử (`tb_system_top.v`, `iverilog_cmd.txt`).

Để chạy được project này, bạn cần cài đặt công cụ mô phỏng. Project này được cấu hình sẵn cho **Icarus Verilog**.

## 1. Cài đặt công cụ (Prerequisites)

Bạn cần tải và cài đặt hai công cụ sau (miễn phí):

1.  **Icarus Verilog**: Để biên dịch và chạy mô phỏng.
    *   Tải tại: [bleyer.org/icarus](https://bleyer.org/icarus/)
    *   Chọn bản build mới nhất cho Windows.
    *   **Lưu ý quan trọng**: Khi cài đặt, nhớ tích vào ô **"Add executable to PATH environment variable"** để có thể chạy lệnh từ CMD/Terminal.

2.  **GTKWave** (thường đi kèm bộ cài Icarus Verilog): Để xem dạng sóng tín hiệu sau khi mô phỏng (tùy chọn).

## 2. Cách chạy mô phỏng (Run Simulation)

Sau khi cài đặt xong, hãy mở Terminal (PowerShell hoặc CMD) tại thư mục `testbench` của project.

### Bước 1: Di chuyển vào thư mục testbench
```powershell
cd d:\Duong\VLSI\VLSI_final\Viterbi-Decoder-Implementation-and-Verification\testbench
```

### Bước 2: Biên dịch và chạy
Chạy lệnh sau để biên dịch các file thiết kế và testbench:

```powershell
iverilog -g2012 -o sim.out -I ../design/ tb_system_top.v ../design/system_top.v
```
: File testbench chính.
../design/system_top.v: File thiết kế chính.

*Giải thích lệnh:*
*   `-g2012`: Sử dụng chuẩn Verilog 2012 (system verilog features).
*   `-o sim.out`: Tên file thực thi đầu ra là `sim.out`.
*   `-I ../design/`: Chỉ định đường dẫn chứa các file header/include (để tìm các file con được gọi trong `system_top.v`).
*   `tb_system_top.v`: File testbench chính.
*   `../design/system_top.v`: File thiết kế chính.

### Bước 3: Thực thi mô phỏng
Sau khi lệnh trên chạy không có lỗi, một file `sim.out` sẽ được tạo ra. Chạy nó bằng lệnh:

```powershell
vvp sim.out
```

## 3. Kết quả mong đợi

Khi chạy thành công, bạn sẽ thấy log hiển thị quá trình Test:
1.  Gửi dữ liệu (Raw Byte) -> Encode -> Đưa vào bộ giải mã.
2.  Bộ giải mã xử lý và trả về kết quả.
3.  Testbench so sánh kết quả và báo **PASS** hoặc **FAIL**.

Ví dụ output:
```text
-------------------------------------------------------------
Starting Viterbi System Testbench
Config: TBL=15, PM_WIDTH=8
-------------------------------------------------------------
[Time 155] Sent Raw: 0x55 | Encoded Input: 0x...
    [CHECK PASS] Time 365: Expected 0x55, Got 0x55
...
-------------------------------------------------------------
 [PASS] ALL TESTS PASSED! (7 vectors checked) 
-------------------------------------------------------------
```

## 4. Xem dạng sóng (Debug)
Nếu bạn muốn xem dạng sóng, bạn cần thêm dòng `$dumpfile("wave.vcd"); $dumpvars(0, tb_system_top);` vào trong file `tb_system_top.v` (trong block `initial`), sau đó chạy lại các bước trên và mở file `wave.vcd` bằng GTKWave.
