# Hướng dẫn Chạy Testbench TBU

## 📋 Mục đích
File này hướng dẫn cách chạy testbench để kiểm tra khối TBU (Traceback Unit) có hoạt động đúng spec không.

---

## ✅ Bước 1: Kiểm tra Icarus Verilog đã cài đặt

Mở PowerShell và chạy:
```powershell
iverilog -v
```

**Nếu thấy thông báo lỗi "command not found":**

### Cách 1: Refresh PATH (Nếu đã cài đặt rồi) ⭐

Chạy lệnh này để refresh PATH:
```powershell
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
iverilog -v
```

### Cách 2: Restart PowerShell

- Đóng PowerShell hiện tại
- Mở PowerShell mới
- Chạy lại `iverilog -v`

### Cách 3: Chạy trực tiếp từ đường dẫn

Nếu Icarus Verilog cài ở `D:\iverilog\bin\`:
```powershell
D:\iverilog\bin\iverilog.exe -v
```

**Nếu vẫn không được:**
- Xem file `HUONG_DAN_CAI_DAT.md` để cài đặt Icarus Verilog

---

## 🚀 Bước 2: Chạy Testbench

### Cách 1: Dùng Script (Dễ nhất) ⭐

Mở PowerShell tại thư mục dự án và chạy:
```powershell
.\run_tb_tbu.ps1
```

**Lưu ý:** Script này sẽ tự động refresh PATH, nên không cần lo về vấn đề PATH.

### Cách 2: Chạy Thủ công (Từng bước) 🔧

#### Bước 1: Refresh PATH (Nếu cần)

Nếu gặp lỗi "iverilog: command not found", chạy lệnh này trước:
```powershell
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

Kiểm tra xem iverilog đã hoạt động chưa:
```powershell
iverilog -v
```

Nếu vẫn không được, dùng đường dẫn đầy đủ (ví dụ: `D:\iverilog\bin\iverilog.exe`)

#### Bước 2: Biên dịch Testbench

Chạy lệnh biên dịch để tạo file thực thi:
```powershell
iverilog -o tb_tbu.exe pmu.v tbu.v tb_tbu.v
```

**Giải thích:**
- `iverilog` - Compiler Verilog
- `-o tb_tbu.exe` - Tên file output
- `pmu.v tbu.v tb_tbu.v` - Các file Verilog cần biên dịch

**Kết quả:** Nếu thành công, sẽ tạo file `tb_tbu.exe` (không có thông báo lỗi)

#### Bước 3: Chạy Simulation

Chạy file đã biên dịch:
```powershell
vvp tb_tbu.exe
```

**Kết quả:** Sẽ hiển thị output của testbench với các test case và kết quả

---

### Cách 3: Chạy Thủ công với Đường dẫn Đầy đủ

Nếu `iverilog` không có trong PATH, dùng đường dẫn đầy đủ:

```powershell
# Bước 1: Biên dịch (thay đường dẫn cho đúng với máy bạn)
D:\iverilog\bin\iverilog.exe -o tb_tbu.exe pmu.v tbu.v tb_tbu.v

# Bước 2: Chạy simulation
D:\iverilog\bin\vvp.exe tb_tbu.exe
```

**Tìm đường dẫn Icarus Verilog:**
```powershell
# Tìm file iverilog.exe
Get-ChildItem -Path "C:\", "D:\" -Recurse -Filter "iverilog.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 FullName
```

---

## 📊 Bước 3: Đọc Kết quả

Sau khi chạy, bạn sẽ thấy output như sau:

```
========================================
--- Bắt đầu kiểm tra TBU ---
========================================

--- TEST CASE 1: Tìm trạng thái tốt nhất (S0) ---
...
```

### Các Test Case được kiểm tra:

1. **TEST CASE 1**: Tìm trạng thái tốt nhất
   - ✅ PASS: TBU tìm đúng trạng thái có PM nhỏ nhất

2. **TEST CASE 2**: Traceback với decision history đơn giản
   - ✅ PASS: Traceback 15 bước và xuất bit đúng

3. **TEST CASE 3**: Traceback với decision bits khác nhau
   - Kiểm tra logic traceback phức tạp hơn

4. **TEST CASE 4**: Tất cả PM bằng nhau
   - ✅ PASS: TBU xử lý edge case đúng

---

## 🔍 Kiểm tra Kết quả

### Kết quả Tốt:
- Tất cả test case đều PASS
- Không có lỗi compilation
- Output bit khớp với kỳ vọng

### Nếu có Lỗi:
- Kiểm tra lại file `tbu.v` và `pmu.v`
- Xem thông báo lỗi trong output
- Kiểm tra logic traceback trong code

---

## 📝 Lưu ý

1. **File cần thiết:**
   - `tbu.v` - Module TBU
   - `pmu.v` - Module PMU (TBU cần PMU để đọc decision history)
   - `tb_tbu.v` - Testbench

2. **Nếu không có Icarus Verilog:**
   - Xem file `HUONG_DAN_CAI_DAT.md` để cài đặt
   - Hoặc chạy online tại: https://www.edaplayground.com/ (xem `run_tb_tbu_online.md`)

3. **Sau khi cài đặt Icarus Verilog:**
   - Có thể cần restart PowerShell
   - Hoặc chạy script sẽ tự động refresh PATH

---

## 🎯 Tóm tắt Nhanh

### Nếu gặp lỗi "iverilog: command not found":

**Bước 1:** Refresh PATH
```powershell
.\refresh_path.ps1
```

**Bước 2:** Chạy testbench
```powershell
.\run_tb_tbu.ps1
```

### Nếu không gặp lỗi:

```powershell
# Chạy 1 lệnh duy nhất:
.\run_tb_tbu.ps1
```

Xong! Kết quả sẽ hiển thị ngay trên màn hình.

---

## 📚 File liên quan

- `tb_tbu.v` - Testbench code
- `tbu.v` - Module TBU cần test
- `pmu.v` - Module PMU (dependency)
- `HUONG_DAN_CAI_DAT.md` - Hướng dẫn cài đặt Icarus Verilog
- `run_tb_tbu_online.md` - Chạy testbench online

