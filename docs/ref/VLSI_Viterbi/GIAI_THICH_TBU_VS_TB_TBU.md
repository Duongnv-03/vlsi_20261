# Giải thích: tbu.v vs tb_tbu.v

## 📋 Tóm tắt

| File | Loại | Tác dụng |
|------|------|----------|
| **`tbu.v`** | **Design Module** (Module thiết kế) | Module TBU thực tế - code cần được test |
| **`tb_tbu.v`** | **Testbench** (File test) | File dùng để test module `tbu.v` |

---

## 🔧 File `tbu.v` - Design Module

### Tác dụng:
- **Module thiết kế thực tế** của khối TBU (Traceback Unit)
- Chứa **logic xử lý** của TBU
- Đây là **code sẽ được dùng trong hệ thống thực tế**

### Nội dung:
```verilog
module tbu #(
    parameter TBL      = 15,
    parameter PM_WIDTH = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_i,
    // ... các input/output
    output reg  data_serial_o,
    output reg  valid_serial_o
);
    // Logic xử lý:
    // - Tìm trạng thái tốt nhất
    // - Traceback TBL bước
    // - Xuất bit giải mã
endmodule
```

### Đặc điểm:
- ✅ **Có thể tổng hợp** (synthesizable) - dùng để tạo hardware
- ✅ **Có thể tái sử dụng** - dùng trong hệ thống lớn hơn
- ✅ **Logic thực tế** - thực hiện chức năng TBU

---

## 🧪 File `tb_tbu.v` - Testbench

### Tác dụng:
- **File test** để kiểm tra module `tbu.v` có hoạt động đúng không
- **Tạo tín hiệu đầu vào** (stimulus) cho module `tbu.v`
- **Kiểm tra tín hiệu đầu ra** (monitor) từ module `tbu.v`
- **So sánh kết quả** với kỳ vọng

### Nội dung:
```verilog
module tb_tbu;  // Không có tham số, không có port

    // 1. Khai báo tín hiệu test
    reg clk;
    reg rst_n;
    reg valid_i;
    // ...
    
    // 2. Instantiate module cần test (UUT - Unit Under Test)
    tbu #(
        .TBL(15),
        .PM_WIDTH(8)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        // ... kết nối tín hiệu
    );
    
    // 3. Tạo clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 4. Tạo test cases
    initial begin
        // Test case 1: ...
        // Test case 2: ...
    end
    
    // 5. Monitor kết quả
    always @(posedge clk) begin
        if (valid_serial_o) begin
            $display("Output: %b", data_serial_o);
        end
    end
endmodule
```

### Đặc điểm:
- ❌ **KHÔNG tổng hợp được** (không synthesizable) - chỉ dùng để simulation
- ✅ **Chỉ dùng để test** - không dùng trong hệ thống thực tế
- ✅ **Có thể xóa sau khi test xong** (nhưng nên giữ lại để test lại sau này)

---

## 🔄 Mối quan hệ giữa 2 file

```
┌─────────────────────────────────────────┐
│         tb_tbu.v (Testbench)           │
│                                         │
│  ┌──────────────┐                      │
│  │   Clock Gen  │                      │
│  └──────┬───────┘                      │
│         │                               │
│  ┌──────▼───────┐                      │
│  │  Test Cases  │                      │
│  │  (Stimulus)  │                      │
│  └──────┬───────┘                      │
│         │                               │
│  ┌──────▼──────────────────────────┐   │
│  │      tbu.v (UUT)                │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │  Logic xử lý TBU         │   │   │
│  │  │  - Tìm trạng thái tốt nhất│   │   │
│  │  │  - Traceback              │   │   │
│  │  │  - Xuất bit giải mã      │   │   │
│  │  └──────────────────────────┘   │   │
│  └──────┬──────────────────────────┘   │
│         │                               │
│  ┌──────▼───────┐                      │
│  │   Monitor    │                      │
│  │  (Kiểm tra)  │                      │
│  └──────────────┘                      │
│                                         │
└─────────────────────────────────────────┘
```

### Quy trình:
1. **Testbench** (`tb_tbu.v`) tạo tín hiệu đầu vào (clock, reset, data...)
2. **Module** (`tbu.v`) nhận tín hiệu và xử lý
3. **Testbench** đọc kết quả đầu ra từ module
4. **Testbench** so sánh với kết quả kỳ vọng và báo PASS/FAIL

---

## 📝 Ví dụ cụ thể

### Trong `tbu.v`:
```verilog
// Logic thực tế: Tìm trạng thái tốt nhất
always @(posedge clk) begin
    if (state == S_FIND_BEST) begin
        current_state <= find_min_state(
            pm_current_s0_i,
            pm_current_s1_i,
            pm_current_s2_i,
            pm_current_s3_i
        );
    end
end
```

### Trong `tb_tbu.v`:
```verilog
// Test case: Kiểm tra tìm trạng thái tốt nhất
initial begin
    // Thiết lập PM: S0 có PM nhỏ nhất
    pm_new_s0 = 8'd5;
    pm_new_s1 = 8'd10;
    pm_new_s2 = 8'd15;
    pm_new_s3 = 8'd20;
    
    // Kích hoạt TBU
    valid_i = 1;
    #10;
    valid_i = 0;
    
    // Kiểm tra kết quả
    $display("Kỳ vọng: Chọn S0 (PM=%d là nhỏ nhất)", pm_current_s0);
end
```

---

## 🎯 Tóm tắt

### `tbu.v`:
- ✅ **Module thiết kế** - code thực tế
- ✅ **Dùng trong hệ thống** - sẽ được tích hợp vào `viterbi_core.v`
- ✅ **Có thể tổng hợp** - tạo hardware

### `tb_tbu.v`:
- ✅ **File test** - chỉ dùng để kiểm tra
- ✅ **Tạo test cases** - kiểm tra module hoạt động đúng
- ❌ **Không tổng hợp được** - chỉ dùng simulation
- ✅ **Có thể xóa** - nhưng nên giữ để test lại

---

## 💡 Lưu ý

1. **Naming convention:**
   - Module: `tbu.v` → module name: `tbu`
   - Testbench: `tb_tbu.v` → module name: `tb_tbu` (thường có prefix `tb_`)

2. **Khi chạy testbench:**
   - Cần cả 2 file: `tbu.v` (module) và `tb_tbu.v` (testbench)
   - Compiler sẽ compile cả 2 file: `iverilog tbu.v tb_tbu.v`

3. **Trong hệ thống thực tế:**
   - Chỉ dùng `tbu.v` (không dùng `tb_tbu.v`)
   - `tb_tbu.v` chỉ dùng khi test/development

