# Cách Sửa Lỗi Font Chữ (Encoding) trong PowerShell

## 🔴 Vấn đề

Khi chạy testbench, các ký tự tiếng Việt hiển thị sai:
- "Tất cả PM bằng nhau" → "TB||Nt cẞ||ú PM bẞ||ng nhau"
- "Thời gian" → "Thß¥i gian"
- "Kết quả" → "Kving"

## ✅ Giải pháp

### Cách 1: Dùng Script (Tự động) ⭐

Script `run_tb_tbu.ps1` đã được cập nhật để tự động fix encoding:
```powershell
.\run_tb_tbu.ps1
```

### Cách 2: Fix Thủ công (Mỗi lần mở PowerShell)

Chạy các lệnh này trước khi chạy testbench:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
chcp 65001
```

Sau đó chạy testbench:
```powershell
.\run_tb_tbu.ps1
```

### Cách 3: Fix Vĩnh viễn (Khuyến nghị)

Thêm vào PowerShell Profile để tự động fix mỗi khi mở PowerShell:

1. **Mở PowerShell Profile:**
   ```powershell
   notepad $PROFILE
   ```

2. **Thêm dòng này vào cuối file:**
   ```powershell
   # Fix encoding cho tiếng Việt
   [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
   [Console]::InputEncoding = [System.Text.Encoding]::UTF8
   chcp 65001 | Out-Null
   ```

3. **Lưu và đóng Notepad**

4. **Reload profile:**
   ```powershell
   . $PROFILE
   ```

Từ giờ mỗi khi mở PowerShell, encoding sẽ tự động được fix!

### Cách 4: Dùng Testbench Tiếng Anh

Nếu không muốn fix encoding, có thể sửa testbench để dùng tiếng Anh thay vì tiếng Việt.

---

## 📝 Giải thích

- **UTF-8 (65001)**: Encoding hỗ trợ đầy đủ ký tự tiếng Việt
- **Mặc định PowerShell**: Thường dùng encoding khác (Windows-1252) không hỗ trợ tốt tiếng Việt
- **Fix encoding**: Chuyển sang UTF-8 để hiển thị đúng

---

## 🎯 Tóm tắt

**Cách nhanh nhất:**
```powershell
.\run_tb_tbu.ps1
```
(Script đã tự động fix encoding)

**Cách vĩnh viễn:**
Thêm fix encoding vào PowerShell Profile (xem Cách 3 ở trên)

