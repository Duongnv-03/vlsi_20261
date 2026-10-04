# Hướng dẫn Cài đặt Icarus Verilog trên Windows

## Cách 1: Tải và Cài đặt Thủ công (Khuyến nghị)

1. **Tải Icarus Verilog:**
   - Truy cập: http://bleyer.org/icarus/
   - Hoặc: https://github.com/steveicarus/iverilog/releases
   - Tải file `.exe` installer mới nhất cho Windows

2. **Cài đặt:**
   - Chạy file `.exe` đã tải
   - Làm theo hướng dẫn cài đặt
   - Đảm bảo chọn "Add to PATH" trong quá trình cài đặt

3. **Kiểm tra cài đặt:**
   ```powershell
   iverilog -v
   ```

## Cách 2: Dùng Chocolatey (Nếu đã cài Chocolatey)

```powershell
choco install iverilog
```

## Cách 3: Dùng Scoop (Nếu đã cài Scoop)

```powershell
scoop install iverilog
```

## Sau khi cài đặt xong

Chạy testbench TBU:
```powershell
.\run_tb_tbu.ps1
```

---

## Nếu không muốn cài đặt Icarus Verilog

Bạn có thể sử dụng:
- **ModelSim/QuestaSim** (nếu có license)
- **Xilinx Vivado** (có ModelSim simulator)
- **Intel Quartus** (có ModelSim simulator)
- **Online Verilog Simulator** như EDA Playground: https://www.edaplayground.com/

