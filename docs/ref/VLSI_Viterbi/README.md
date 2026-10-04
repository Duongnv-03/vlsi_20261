# Viterbi Decoder - Tài liệu Hướng dẫn

## Mục lục
1. [Giới thiệu về Viterbi Decoder](#1-giới-thiệu-về-viterbi-decoder)
2. [Sơ đồ Khối Tổng quan](#2-sơ-đồ-khối-tổng-quan)
3. [Chi tiết từng Khối](#3-chi-tiết-từng-khối)
4. [Hướng dẫn Sử dụng Code](#4-hướng-dẫn-sử-dụng-code)
5. [Hướng dẫn Viết và Chạy Testbench](#5-hướng-dẫn-viết-và-chạy-testbench)

---

## 1. Giới thiệu về Viterbi Decoder

### 1.1 Viterbi Decoder là gì?

**Viterbi Decoder** là một thuật toán giải mã cho **Convolutional Codes** (mã xoắn), được sử dụng rộng rãi trong truyền thông số để sửa lỗi. Thuật toán này tìm đường đi có chi phí nhỏ nhất trong một **trellis diagram** (biểu đồ trellis).

### 1.2 Nguyên lý hoạt động

Viterbi Decoder hoạt động theo 3 bước chính:

1. **Branch Metric Calculation (BMU)**: Tính chi phí Hamming giữa dữ liệu nhận được và các codeword dự kiến
2. **Add-Compare-Select (ACSU)**: Cộng chi phí, so sánh và chọn đường đi tốt nhất
3. **Traceback (TBU)**: Truy ngược lại để tìm chuỗi bit thông tin gốc

### 1.3 Thông số của thiết kế

- **Constraint Length (K)**: 3
- **Code Rate (R)**: 1/2 (1 bit thông tin → 2 bit mã hóa)
- **Số trạng thái**: 4 (S0, S1, S2, S3)
- **Traceback Length (TBL)**: 15
- **Path Metric Width**: 8 bits

### 1.4 Trellis Diagram

Với K=3, R=1/2, ta có 4 trạng thái và các chuyển đổi:

```
S0 (00) → S0 (00) hoặc S2 (11)
S1 (01) → S0 (11) hoặc S2 (00)
S2 (10) → S1 (10) hoặc S3 (01)
S3 (11) → S1 (01) hoặc S3 (10)
```

---

## 2. Sơ đồ Khối Tổng quan

### 2.1 Sơ đồ Khối Thực tế

![Sơ đồ khối Viterbi Decoder](./sơ%20đồ%20khối.jfif)

*Hình 1: Sơ đồ khối tổng quan của Viterbi Decoder - Xem file "sơ đồ khối.jfif" để xem chi tiết*

### 2.2 Kiến trúc Tổng thể (Text Diagram)

```
┌─────────────────────────────────────────────────────────────┐
│                      system_top                             │
│                                                              │
│  ┌──────────┐      ┌──────────────┐      ┌──────────┐    │
│  │   PISO   │──────▶│ Viterbi Core │──────▶│   SIPO   │    │
│  │ 16→2-bit │      │              │      │ 1→8-bit  │    │
│  └──────────┘      └──────────────┘      └──────────┘    │
│       ▲                    │                    │          │
│       │                    │                    │          │
│  ┌────┴────┐              │                    │          │
│  │   FSM   │              │                    │          │
│  │(busy_o) │              │                    │          │
│  └─────────┘              │                    │          │
│                            │                    │          │
│  Input: 16-bit parallel   │                    │          │
│  Output: 8-bit parallel   │                    │          │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Viterbi Core - Chi tiết

```
┌─────────────────────────────────────────────────────────────┐
│                    viterbi_core                              │
│                                                              │
│  Input: 2-bit serial                                        │
│                                                              │
│  ┌─────┐      ┌─────┐      ┌─────┐      ┌─────┐          │
│  │ BMU │─────▶│ACSU │─────▶│ PMU │◀─────▶│ TBU │          │
│  └─────┘      └─────┘      └─────┘      └─────┘          │
│     │            │            │            │               │
│     │            │            │            │               │
│     └────────────┴────────────┴────────────┘               │
│                                                              │
│  Output: 1-bit serial                                       │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Luồng Dữ liệu

1. **PISO**: Nhận 16-bit song song → Xuất 2-bit nối tiếp (8 lần)
2. **BMU**: Tính 8 Branch Metrics từ 2-bit input
3. **ACSU**: Cộng BM với PM cũ, so sánh, chọn đường tốt nhất
4. **PMU**: Lưu PM mới và Decision Bits vào RAM
5. **TBU**: Traceback TBL bước để giải mã bit thông tin
6. **SIPO**: Nhận 1-bit nối tiếp (8 lần) → Xuất 8-bit song song

---

## 3. Chi tiết từng Khối

### 3.1 PISO (Parallel-In Serial-Out)

**File**: `piso.v`

**Chức năng**: Chuyển đổi 16-bit song song thành 2-bit nối tiếp

**Interface**:
```verilog
module piso (
    input  wire           clk,
    input  wire           rst_n,
    input  wire           load_i,              // Xung nạp dữ liệu
    input  wire [15:0]    data_parallel_i,      // 16-bit vào
    
    output reg  [1:0]     data_serial_o,       // 2-bit ra
    output reg            valid_serial_o       // Cờ valid
);
```

**Hoạt động**:
- **Trạng thái IDLE**: Chờ tín hiệu `load_i`
- **Trạng thái SHIFTING**: Xuất 2-bit từ MSB, dịch trái 2 bit, lặp 8 lần
- Mỗi chu kỳ clock xuất 1 lần 2-bit với `valid_serial_o = 1`

**FSM States**:
- `S_IDLE`: Chờ nạp dữ liệu
- `S_SHIFTING`: Đang xuất dữ liệu nối tiếp

---

### 3.2 BMU (Branch Metric Unit)

**File**: `bmu.v`

**Chức năng**: Tính toán chi phí Hamming (Branch Metric) cho 8 đường chuyển đổi

**Interface**:
```verilog
module bmu (
    input  [1:0] piso_data_i,    // Dữ liệu nhận được (2 bits)
    
    output [1:0] bm_s0_s0_o,     // Branch metric cho S0→S0
    output [1:0] bm_s0_s2_o,     // Branch metric cho S0→S2
    output [1:0] bm_s1_s0_o,     // Branch metric cho S1→S0
    output [1:0] bm_s1_s2_o,     // Branch metric cho S1→S2
    output [1:0] bm_s2_s1_o,     // Branch metric cho S2→S1
    output [1:0] bm_s2_s3_o,     // Branch metric cho S2→S3
    output [1:0] bm_s3_s1_o,     // Branch metric cho S3→S1
    output [1:0] bm_s3_s3_o      // Branch metric cho S3→S3
);
```

**Hoạt động**:
- Tính Hamming Distance: `diff = received_data XOR expected_codeword`
- Tính Hamming Weight: `BM = diff[1] + diff[0]` (số bit khác nhau)
- BM = 0: Khớp hoàn toàn
- BM = 2: Khác hoàn toàn
- BM = 1: Khác 1 bit

**Expected Codewords**:
- S0→S0: `00`
- S0→S2: `11`
- S1→S0: `11`
- S1→S2: `00`
- S2→S1: `10`
- S2→S3: `01`
- S3→S1: `01`
- S3→S3: `10`

**Loại**: Combinational (không có clock)

---

### 3.3 ACSU (Add-Compare-Select Unit)

**File**: `ascu.v`

**Chức năng**: Thực hiện bước đệ quy chính của thuật toán Viterbi

**Interface**:
```verilog
module ascu (
    // Đầu vào Branch Metrics từ BMU
    input [1:0] bm_s0_s0_i, bm_s0_s2_i, bm_s1_s0_i, bm_s1_s2_i,
    input [1:0] bm_s2_s1_i, bm_s2_s3_i, bm_s3_s1_i, bm_s3_s3_i,
    
    // Đầu vào Path Metrics cũ từ PMU
    input [7:0] pm_s0_i, pm_s1_i, pm_s2_i, pm_s3_i,
    
    // Đầu ra Decision Bits và Path Metrics mới
    output [3:0] dec_bits_o,
    output [7:0] pm_s0_o, pm_s1_o, pm_s2_o, pm_s3_o
);
```

**Hoạt động**:

1. **ADD**: Cộng Branch Metric với Path Metric cũ
   - `PM_00 = PM_S0 + BM_S0→S0`
   - `PM_10 = PM_S1 + BM_S1→S0`
   - Tương tự cho các trạng thái khác

2. **COMPARE**: So sánh 2 đường đến cùng 1 trạng thái
   - S0: So sánh PM_00 và PM_10
   - S1: So sánh PM_21 và PM_31
   - S2: So sánh PM_02 và PM_12
   - S3: So sánh PM_23 và PM_33

3. **SELECT**: Chọn đường có PM nhỏ hơn
   - `PM_S0_o = min(PM_00, PM_10)`
   - `dec_bits_o[0] = (PM_00 <= PM_10) ? 0 : 1`

**Loại**: Combinational (không có clock)

---

### 3.4 PMU (Path Metric Unit)

**File**: `pmu.v`

**Chức năng**: Lưu trữ và quản lý Path Metrics và Decision Bits

**Interface**:
```verilog
module pmu #(
    parameter TBL      = 15,
    parameter PM_WIDTH = 8
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    valid_i,
    input  wire [3:0]              dec_bits_i,
    input  wire [PM_WIDTH-1:0]    pm_new_s0_i, pm_new_s1_i,
    input  wire [PM_WIDTH-1:0]    pm_new_s2_i, pm_new_s3_i,
    input  wire [$clog2(TBL)-1:0] read_addr_i,
    output reg  [3:0]             read_data_o,
    output reg  [PM_WIDTH-1:0]    pm_current_s0_o,
    output reg  [PM_WIDTH-1:0]    pm_current_s1_o,
    output reg  [PM_WIDTH-1:0]    pm_current_s2_o,
    output reg  [PM_WIDTH-1:0]    pm_current_s3_o
);
```

**Hoạt động**:

1. **Lưu Path Metrics**: 4 thanh ghi lưu PM hiện tại của 4 trạng thái
2. **Lưu Decision History**: RAM TBL x 4 bits lưu lịch sử decision bits
3. **Circular Buffer**: Write pointer quay vòng khi đầy
4. **Đọc cho TBU**: Cung cấp decision bits theo địa chỉ từ TBU

**Cấu trúc RAM**:
- Kích thước: `TBL` x 4 bits
- Mỗi entry: `[dec_S3, dec_S2, dec_S1, dec_S0]`
- Circular buffer để tiết kiệm bộ nhớ

**Loại**: Sequential (có clock)

---

### 3.5 TBU (Traceback Unit)

**File**: `tbu.v`

**Chức năng**: Thực hiện traceback để giải mã bit thông tin

**Interface**:
```verilog
module tbu #(
    parameter TBL      = 15,
    parameter PM_WIDTH = 8
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    valid_i,
    input  wire [PM_WIDTH-1:0]    pm_current_s0_i, pm_current_s1_i,
    input  wire [PM_WIDTH-1:0]    pm_current_s2_i, pm_current_s3_i,
    input  wire [3:0]             pm_read_data_i,
    output reg  [$clog2(TBL)-1:0] pm_read_addr_o,
    output reg                    data_serial_o,
    output reg                    valid_serial_o
);
```

**Hoạt động**:

1. **FIND_BEST**: Tìm trạng thái có PM nhỏ nhất
   ```verilog
   best_state = min(PM_S0, PM_S1, PM_S2, PM_S3)
   ```

2. **TRACEBACK**: Truy ngược TBL bước
   - Bắt đầu từ trạng thái tốt nhất
   - Đọc decision bit từ PMU
   - Xác định trạng thái trước đó
   - Bit giải mã = LSB của trạng thái trước đó
   - Lặp lại TBL lần

**FSM States**:
- `S_IDLE`: Chờ tín hiệu `valid_i`
- `S_FIND_BEST`: Tìm trạng thái tốt nhất
- `S_TRACEBACK`: Thực hiện traceback TBL bước

**Mapping Decision Bits**:
- `dec_bits[0]`: Quyết định đến S0 (0=S0→S0, 1=S1→S0)
- `dec_bits[1]`: Quyết định đến S1 (0=S2→S1, 1=S3→S1)
- `dec_bits[2]`: Quyết định đến S2 (0=S0→S2, 1=S1→S2)
- `dec_bits[3]`: Quyết định đến S3 (0=S2→S3, 1=S3→S3)

**Loại**: Sequential (có clock)

---

### 3.6 SIPO (Serial-In Parallel-Out)

**File**: `sipo.v`

**Chức năng**: Chuyển đổi 1-bit nối tiếp thành 8-bit song song

**Interface**:
```verilog
module sipo (
    input  wire           clk,
    input  wire           rst_n,
    input  wire           data_serial_i,       // 1-bit vào
    input  wire           valid_serial_i,      // Cờ valid
    
    output reg  [7:0]     data_parallel_o,     // 8-bit ra
    output reg            byte_ready_o         // Xung báo đủ 8-bit
);
```

**Hoạt động**:
- **Trạng thái IDLE**: Chờ bit đầu tiên
- **Trạng thái COLLECTING**: Thu thập 8 bit vào thanh ghi dịch
- Khi đủ 8 bit: Xuất `data_parallel_o` và `byte_ready_o = 1`

**FSM States**:
- `S_IDLE`: Chờ bit đầu tiên
- `S_COLLECTING`: Đang thu thập bits

---

### 3.7 FSM (Finite State Machine) trong system_top

**Chức năng**: Điều khiển trạng thái `busy_o` của hệ thống

**States**:
- `S_IDLE`: Hệ thống rảnh, sẵn sàng nhận dữ liệu mới
- `S_BUSY`: Hệ thống đang xử lý, không nhận dữ liệu mới

**Hoạt động**:
- Chuyển từ IDLE → BUSY khi có `dvalid_i` và đang IDLE
- Chuyển từ BUSY → IDLE khi `sipo_byte_ready = 1`

---

## 4. Hướng dẫn Sử dụng Code

### 4.1 Cấu trúc File

```
Viterbi/
├── system_top.v      # Module top level
├── viterbi_core.v    # Lõi Viterbi (chứa BMU, ACSU, PMU, TBU)
├── piso.v            # Parallel-In Serial-Out
├── sipo.v            # Serial-In Parallel-Out
├── bmu.v             # Branch Metric Unit
├── ascu.v            # Add-Compare-Select Unit
├── pmu.v             # Path Metric Unit
├── tbu.v             # Traceback Unit
├── tb_bmu.v          # Testbench cho BMU
├── tb_ascu.v         # Testbench cho ACSU
└── README.md         # Tài liệu này
```

### 4.2 Tham số có thể cấu hình

Trong `system_top.v` và `viterbi_core.v`:

```verilog
parameter TBL      = 15,  // Traceback Length (độ sâu traceback)
parameter PM_WIDTH = 8   // Độ rộng bit của Path Metric
```

**Khuyến nghị**:
- `TBL`: 5×K đến 10×K (với K=3, nên dùng 15-30)
- `PM_WIDTH`: 8 bits cho hầu hết ứng dụng (có thể tăng nếu cần)

### 4.3 Cách Instantiate Module

```verilog
system_top #(
    .TBL      (15),
    .PM_WIDTH (8)
) viterbi_inst (
    .clk      (clk),
    .rst_n    (rst_n),
    .dvalid_i (dvalid_i),
    .data_i   (data_i),      // [15:0]
    .data_o   (data_o),      // [7:0]
    .valid_o  (valid_o),
    .busy_o   (busy_o)
);
```

### 4.4 Timing Diagram

```
Clock:     __|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__
dvalid_i:  ____|‾‾|_____________________________________________
data_i:    ____[16-bit data]_____________________________________
busy_o:    ____|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____
valid_o:   ________________________________________|‾|__________
data_o:    ________________________________________[8-bit]______
```

**Lưu ý**: 
- `busy_o` sẽ bật lên khi bắt đầu xử lý và tắt khi hoàn thành
- `valid_o` là xung 1 chu kỳ clock khi `data_o` hợp lệ

---

## 5. Hướng dẫn Viết và Chạy Testbench

### 5.1 Testbench cho Module Đơn lẻ

#### 5.1.1 Testbench BMU (tb_bmu.v)

**Mục đích**: Kiểm tra tính toán Branch Metrics

**Các test case**:
1. Input = `00`: Kiểm tra BM cho các codeword `00` và `11`
2. Input = `11`: Kiểm tra BM cho các codeword `00` và `11`
3. Input = `10`: Kiểm tra BM cho các codeword `10` và `01`
4. Input = `01`: Kiểm tra BM cho các codeword `10` và `01`

**Cách chạy**:
```bash
# Với ModelSim/QuestaSim
vlog bmu.v tb_bmu.v
vsim -c bmu_tb -do "run -all; quit"

# Với Verilator
verilator --cc bmu.v tb_bmu.v --exe tb_bmu.cpp
make -C obj_dir -f Vbmu.mk
./obj_dir/Vbmu

# Với Icarus Verilog
iverilog -o bmu_tb bmu.v tb_bmu.v
vvp bmu_tb
```

#### 5.1.2 Testbench ACSU (tb_ascu.v)

**Mục đích**: Kiểm tra logic Add-Compare-Select

**Các test case**:
1. Chọn đường PM nhỏ: PM cũ khác nhau, BM nhỏ cho một đường
2. Chọn đường PM lớn: PM cũ lớn nhưng BM nhỏ hơn tổng

**Cách chạy**: Tương tự như BMU

#### 5.1.3 Testbench TBU (tb_tbu.v)

**📖 Xem hướng dẫn chi tiết**: `HUONG_DAN_CHAY_TBU.md`

**Mục đích**: Kiểm tra thuật toán traceback và giải mã bit

**Các test case**:
1. **Tìm trạng thái tốt nhất**: Kiểm tra TBU tìm đúng trạng thái có PM nhỏ nhất
2. **Traceback với decision history đã biết**: Kiểm tra traceback với pattern decision bits đơn giản
3. **Traceback với decision bits khác nhau**: Kiểm tra traceback với pattern phức tạp hơn
4. **Tất cả PM bằng nhau**: Kiểm tra trường hợp edge case khi tất cả PM bằng nhau

**Cách chạy**:

**Trên Windows (PowerShell):**
```powershell
# Cách 1: Dùng script PowerShell
.\run_tb_tbu.ps1

# Cách 2: Dùng script batch
.\run_tb_tbu.bat

# Cách 3: Chạy thủ công
iverilog -o tb_tbu.exe pmu.v tbu.v tb_tbu.v
vvp tb_tbu.exe
```

**Trên Linux/Mac:**
```bash
# Cách 1: Dùng script
chmod +x run_tb_tbu.sh
./run_tb_tbu.sh

# Cách 2: Chạy thủ công
iverilog -o tb_tbu pmu.v tbu.v tb_tbu.v
vvp tb_tbu
```

**Với ModelSim/QuestaSim:**
```bash
vlog pmu.v tbu.v tb_tbu.v
vsim -c tb_tbu -do "run -all; quit"
```

**Với Verilator:**
```bash
verilator --cc pmu.v tbu.v tb_tbu.v --exe tb_tbu.cpp
make -C obj_dir -f Vtb_tbu.mk
./obj_dir/Vtb_tbu
```

**Lưu ý**: Nếu chưa cài đặt Icarus Verilog:
- **Windows**: Tải từ http://iverilog.icarus.com/ hoặc dùng `winget install IcarusVerilog`
- **Linux**: `sudo apt-get install iverilog` (Ubuntu/Debian) hoặc `sudo yum install iverilog` (CentOS/RHEL)
- **Mac**: `brew install icarus-verilog`

**Lưu ý**: Testbench TBU cần instantiate PMU vì TBU đọc decision history từ PMU.

### 5.2 Testbench cho System Top

#### 5.2.1 Tạo Testbench Mới

Tạo file `tb_system_top.v`:

```verilog
`timescale 1ns / 1ps

module tb_system_top;

    // Khai báo tín hiệu
    reg clk;
    reg rst_n;
    reg dvalid_i;
    reg [15:0] data_i;
    
    wire [7:0] data_o;
    wire valid_o;
    wire busy_o;
    
    // Instantiate DUT
    system_top #(
        .TBL      (15),
        .PM_WIDTH (8)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .dvalid_i (dvalid_i),
        .data_i   (data_i),
        .data_o   (data_o),
        .valid_o  (valid_o),
        .busy_o   (busy_o)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz (10ns period)
    end
    
    // Reset generation
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end
    
    // Test stimulus
    initial begin
        dvalid_i = 0;
        data_i = 16'h0000;
        
        // Đợi reset xong
        wait(rst_n);
        #10;
        
        // Test case 1: Gửi dữ liệu
        $display("--- Test Case 1: Gửi dữ liệu 16-bit ---");
        data_i = 16'hA5A5; // Ví dụ dữ liệu
        dvalid_i = 1;
        #10;
        dvalid_i = 0;
        
        // Đợi xử lý xong
        wait(busy_o == 0);
        #10;
        
        // Kiểm tra kết quả
        if (valid_o) begin
            $display("Kết quả: data_o = 0x%02h", data_o);
        end
        
        // Test case 2: Gửi nhiều dữ liệu
        $display("\n--- Test Case 2: Gửi nhiều dữ liệu ---");
        repeat(5) begin
            data_i = $random;
            dvalid_i = 1;
            #10;
            dvalid_i = 0;
            wait(busy_o == 0);
            #10;
        end
        
        $display("\n--- Kết thúc test ---");
        #100;
        $finish;
    end
    
    // Monitor
    always @(posedge clk) begin
        if (valid_o) begin
            $display("Time=%0t: Output valid, data_o=0x%02h", $time, data_o);
        end
    end

endmodule
```

#### 5.2.2 Chạy Testbench System Top

```bash
# Với ModelSim/QuestaSim
vlog *.v tb_system_top.v
vsim -c tb_system_top -do "run -all; quit"

# Với Icarus Verilog
iverilog -o system_tb *.v tb_system_top.v
vvp system_tb
```

### 5.3 Test với Dữ liệu Thực tế

#### 5.3.1 Tạo Test Vector

Để test với dữ liệu thực tế, bạn cần:

1. **Mã hóa dữ liệu** bằng Convolutional Encoder (K=3, R=1/2)
2. **Thêm nhiễu** (nếu muốn test khả năng sửa lỗi)
3. **Gửi vào Viterbi Decoder**
4. **So sánh kết quả** với dữ liệu gốc

#### 5.3.2 Ví dụ Test Vector

```verilog
// Dữ liệu gốc: 8 bits
reg [7:0] original_data = 8'b10101010;

// Sau khi mã hóa (giả sử): 16 bits
reg [15:0] encoded_data = 16'b1100110011001100;

// Gửi vào decoder
data_i = encoded_data;
dvalid_i = 1;
#10;
dvalid_i = 0;

// Kiểm tra kết quả
wait(valid_o);
if (data_o == original_data) begin
    $display("PASS: Decode thành công");
end else begin
    $display("FAIL: Kết quả không khớp");
end
```

### 5.4 Debug và Monitoring

#### 5.4.1 Thêm Waveform

```verilog
// Trong testbench
initial begin
    $dumpfile("viterbi.vcd");
    $dumpvars(0, tb_system_top);
end
```

Sau đó xem waveform:
```bash
gtkwave viterbi.vcd
```

#### 5.4.2 Thêm Print Statements

Thêm vào các module để debug:

```verilog
// Trong viterbi_core.v
always @(posedge clk) begin
    if (valid_i) begin
        $display("Time=%0t: BMU input=%b", $time, data_core_i);
        $display("  BM outputs: S0->S0=%d, S0->S2=%d", 
                 w_bm_s0_s0, w_bm_s0_s2);
    end
end
```

### 5.5 Best Practices

1. **Test từng module riêng** trước khi test toàn bộ hệ thống
2. **Sử dụng test vectors** đã biết kết quả
3. **Kiểm tra edge cases**: reset, overflow PM, v.v.
4. **Monitor timing**: Đảm bảo không có setup/hold time violation
5. **Kiểm tra resource usage**: Area, power, timing

---

## 6. Tài liệu Tham khảo

### 6.1 Sách và Tài liệu

- "Digital Communications" - John G. Proakis
- "Error Control Coding" - Shu Lin & Daniel J. Costello
- "VLSI Digital Signal Processing Systems" - Keshab K. Parhi

### 6.2 Online Resources

- Wikipedia: Viterbi Algorithm
- Xilinx/Intel Application Notes về Viterbi Decoder

---

## 7. Troubleshooting

### 7.1 Vấn đề thường gặp

**Q: Decoder không xuất kết quả?**
- Kiểm tra `busy_o`: Đảm bảo hệ thống không bị kẹt ở trạng thái BUSY
- Kiểm tra `valid_i` vào viterbi_core: Đảm bảo PISO đang xuất dữ liệu

**Q: Kết quả decode sai?**
- Kiểm tra trellis diagram: Đảm bảo expected codewords đúng
- Kiểm tra traceback logic: Đảm bảo mapping decision bits đúng
- Kiểm tra TBL: Có thể cần tăng TBL nếu BER cao

**Q: Timing violation?**
- Kiểm tra critical path: Có thể cần pipeline thêm
- Kiểm tra PM_WIDTH: Có thể cần tăng độ rộng để tránh overflow

---

## 8. Kết luận

Thiết kế Viterbi Decoder này là một implementation hoàn chỉnh với:
- ✅ Kiến trúc modular, dễ hiểu và maintain
- ✅ Hỗ trợ tham số hóa (TBL, PM_WIDTH)
- ✅ Interface rõ ràng với handshake signals
- ✅ Sẵn sàng để synthesis và implementation

Chúc bạn thành công với dự án VLSI của mình! 🚀

