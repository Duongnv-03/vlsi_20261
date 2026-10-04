# 📘 HƯỚNG DẪN CHUẨN BỊ OPENLANE CHO VITERBI DECODER

**Dự án**: Thiết kế và Tổng hợp Viterbi Decoder từ RTL đến GDSII  
**Target PDK**: SKY130  
**Top Module**: `system_top`

---

## 📋 Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Chiến lược Verification](#2-chiến-lược-verification)
3. [Các bước đã thực hiện](#3-các-bước-đã-thực-hiện)
4. [Các bước tiếp theo](#4-các-bước-tiếp-theo)
5. [Cấu trúc thư mục](#5-cấu-trúc-thư-mục)
6. [Các lỗi thường gặp](#6-các-lỗi-thường-gặp)

---

## 1. Tổng quan

### Thông tin dự án

| Thông tin | Giá trị |
|-----------|---------|
| Loại mã hóa | Mã tích chập (Convolutional Code) |
| Cấu hình | (n, k, m) = (2, 1, 2) |
| Constraint Length (K) | 3 |
| Code Rate (R) | 1/2 |
| Đa thức sinh | G1 = 1 + x + x², G2 = 1 + x² |
| Tần số mục tiêu | 50 MHz |

### Các module RTL

```
system_top
├── sync_fifo      - FIFO đồng bộ (buffer đầu vào)
├── piso           - Parallel-In Serial-Out
├── viterbi_core   - Core giải mã Viterbi
│   ├── bmu        - Branch Metric Unit
│   ├── acsu       - Add-Compare-Select Unit
│   ├── pmu        - Path Metric Unit
│   └── tbu        - Traceback Unit
└── sipo           - Serial-In Parallel-Out
```

---

## 2. Chiến lược Verification

### 2.1 Tổng quan Test Plan

Dự án sử dụng phương pháp **Unit Testing + System Testing** với tổng cộng **44+ test cases**.

| Test Suite | Số TCs | Mô tả |
|------------|--------|-------|
| FIFO | 5 | Test SYNC_FIFO module |
| PISO | 5 | Test Parallel-In Serial-Out |
| BMU | 5 | Test Branch Metric Unit |
| ACSU | 5 | Test Add-Compare-Select Unit |
| PMU | 5 | Test Path Metric Unit |
| TBU | 6 | Test Traceback Unit |
| SIPO | 5 | Test Serial-In Parallel-Out |
| SYSTEM | 8+ | Test tích hợp toàn hệ thống |

### 2.2 Unit Tests

#### FIFO Test Cases

| ID | Kịch bản | Mô tả | Tiêu chí PASS |
|----|----------|-------|---------------|
| TC_01 | Reset & Init | Kiểm tra khởi tạo sau reset | `empty_o=1`, `full_o=0` |
| TC_02 | Write until Full | Ghi 16 entries liên tục | `full_o` lên 1 khi đủ 16 |
| TC_03 | Read until Empty | Đọc hết FIFO | Data FIFO đúng thứ tự |
| TC_04 | Data Integrity | 5 vòng ghi/đọc | `error_count = 0` |
| TC_05 | Timing Check | Kiểm tra latency | Data ổn định sau 2ns |

#### PISO Test Cases

| ID | Kịch bản | Input | Expected Output |
|----|----------|-------|-----------------|
| TC_01 | Alternating | 0xAAAA | 10,10,10,10,10,10,10,10 |
| TC_02 | Inverse | 0x5555 | 01,01,01,01,01,01,01,01 |
| TC_03 | All Ones | 0xFFFF | 11,11,11,11,11,11,11,11 |
| TC_04 | All Zeros | 0x0000 | 00,00,00,00,00,00,00,00 |
| TC_05 | Random Stress | Random | `error_count = 0` |

#### BMU Test Cases

| ID | Kịch bản | Input | Mô tả |
|----|----------|-------|-------|
| TC_01 | Ideal Case | 2'b00 | Hamming distance = 0 cho S0→S0 |
| TC_02 | Inverse Case | 2'b11 | Hamming distance = 0 cho S0→S2 |
| TC_03 | Single Bit Error | 2'b01 | Test sửa lỗi 1 bit |
| TC_04 | Single Bit Error | 2'b10 | Test sửa lỗi 1 bit (đảo) |
| TC_05 | Random Stress | Random | `error_count = 0` |

#### ACSU Test Cases

| ID | Kịch bản | Mô tả |
|----|----------|-------|
| TC_01 | Min Path | Chọn nhánh PM+BM nhỏ nhất |
| TC_02 | Switching Winner | Đổi nhánh thắng cuộc |
| TC_03 | Boundary Case | PM = 250 (gần tràn 8-bit) |
| TC_04 | Zero Case | Tất cả PM, BM = 0 |
| TC_05 | Random Stress | `error_count = 0` |

#### PMU Test Cases

| ID | Kịch bản | Mô tả |
|----|----------|-------|
| TC_01 | Reset Check | S0=0, S1-S3=255 sau reset |
| TC_02 | Update Enable | Cập nhật khi `valid_i=1` |
| TC_03 | Keep Data | Giữ data khi `valid_i=0` |
| TC_04 | Zero Stream | Clear về 0 |
| TC_05 | Random Stress | `error_count = 0` |

#### TBU Test Cases

| ID | Kịch bản | Mô tả |
|----|----------|-------|
| TC_01 | Reset Check | `valid_o=0`, history cleared |
| TC_02 | Pipeline Filling | Nạp 14 cycles, `valid_o=0` |
| TC_03 | Start Decoding | Cycle 15: `valid_o=1` |
| TC_04 | Data Traceback | Register Exchange method |
| TC_05 | Valid_i Gating | Tạm dừng khi input invalid |
| TC_06 | Winner Switching | Chọn best path từ S3 |

#### SIPO Test Cases

| ID | Kịch bản | Input | Expected |
|----|----------|-------|----------|
| TC_01 | Reset Check | N/A | `byte_ready_o=0` |
| TC_02 | Normal Byte | 0xA5 | `data_parallel_o=0xA5` |
| TC_03 | All Ones | 0xFF | `data_parallel_o=0xFF` |
| TC_04 | All Zeros | 0x00 | `data_parallel_o=0x00` |
| TC_05 | Random Stress | Random | `error_count = 0` |

### 2.3 System Integration Tests

| ID | Kịch bản | Mục đích |
|----|----------|----------|
| SYS_01 | Sanity Check | Kiểm tra logic cơ bản (0x00, 0xFF, 0xAA, 0x55) |
| SYS_02 | Full Range Sweep | Gửi 0x00 → 0xFF (256 bytes) |
| SYS_03 | Single Bit Error | Lật từng bit, hệ thống phải tự sửa |
| SYS_04 | Double Bit Error | Lật 2 bit, xác định giới hạn sửa lỗi |
| SYS_05 | Burst Error | Lật 3-4 bit liên tiếp (expected fail) |
| SYS_06 | Busy Violation | Gửi data khi `busy_o=1` (phải bị ignore) |
| SYS_07 | Continuous Streaming | 100 bytes back-to-back |
| SYS_08 | Hard Reset | Reset giữa chừng, FSM về IDLE |

### 2.4 Error Correction Capability

| Loại lỗi | Số bit lỗi | Kết quả mong đợi |
|----------|------------|------------------|
| No error | 0 | ✅ Correct (100%) |
| Single bit | 1 | ✅ Correctable |
| Double bit | 2 | ⚠️ May or may not correct |
| Burst error | 3+ | ❌ Expected fail |

> **Lưu ý**: Viterbi Decoder (2,1,2) có khả năng sửa lỗi **1 bit** trong mỗi cặp symbol. Lỗi 2 bit có thể được phát hiện nhưng không đảm bảo sửa đúng.

---

## 3. Các bước đã thực hiện

### ✅ Bước 1: Tạo cấu trúc thư mục OpenLane

```powershell
New-Item -ItemType Directory -Force -Path "OpenLane/designs/viterbi/src"
```

**Kết quả**: Đã tạo thư mục `OpenLane/designs/viterbi/src/`

---

### ✅ Bước 2: Copy các file RTL

```powershell
Copy-Item -Path "design\*.v" -Destination "OpenLane\designs\viterbi\src\" -Force
```

**9 file đã copy**:
- `system_top.v` (Top module)
- `viterbi_core.v`
- `sync_fifo.v`
- `piso.v`, `sipo.v`
- `bmu.v`, `acsu.v`, `pmu.v`, `tbu.v`

---

### ✅ Bước 3: Comment các dòng `include`

**File đã sửa**: `OpenLane/designs/viterbi/src/system_top.v`

```diff
-`include "sync_fifo.v"
-`include "piso.v"
-`include "sipo.v"
-`include "viterbi_core.v"
+// `include "sync_fifo.v"    // Commented for OpenLane - auto-compiled
+// `include "piso.v"         // Commented for OpenLane - auto-compiled
+// `include "sipo.v"         // Commented for OpenLane - auto-compiled
+// `include "viterbi_core.v" // Commented for OpenLane - auto-compiled
```

> **Lưu ý**: OpenLane tự động biên dịch tất cả file `.v` trong thư mục `src/`, nên không cần `include`.

---

### ✅ Bước 4: Tạo file `config.tcl`

**Đường dẫn**: `OpenLane/designs/viterbi/config.tcl`

**Các thiết lập quan trọng**:

| Tham số | Giá trị | Mô tả |
|---------|---------|-------|
| `DESIGN_NAME` | `system_top` | Top module |
| `CLOCK_PORT` | `clk` | Port clock |
| `CLOCK_PERIOD` | `20.0` ns | 50 MHz |
| `FP_CORE_UTIL` | `40%` | Core utilization |
| `DIE_AREA` | `0 0 400 400` | 400μm x 400μm |
| `PL_TARGET_DENSITY` | `0.45` | Placement density |
| `SYNTH_STRATEGY` | `AREA 0` | Tối ưu diện tích |

---

### ✅ Bước 5: Tạo file `constraints.sdc`

**Đường dẫn**: `OpenLane/designs/viterbi/constraints.sdc`

**Các constraint chính**:
- Clock: 50 MHz (period = 20 ns)
- Clock uncertainty: 0.25 ns
- Input/Output delay: 2.0 ns
- Reset `rst_n`: False path (async reset)

---

## 4. Các bước tiếp theo

### 📦 Bước 6: Copy design sang máy Ubuntu

```bash
# Trên Ubuntu (hoặc WSL)
# Copy thư mục viterbi vào OpenLane/designs/
cp -r /path/to/project/OpenLane/designs/viterbi ~/OpenLane/designs/
```

---

### 🔧 Bước 7: Sửa file `viterbi_core.v` (Comment includes)

File `viterbi_core.v` cũng chứa các dòng `include` cần comment:

```bash
cd ~/OpenLane/designs/viterbi/src
sed -i 's/^`include/\/\/ `include/' viterbi_core.v
```

---

### 🚀 Bước 8: Chạy OpenLane Flow

```bash
cd ~/OpenLane

# Khởi động Docker và chạy flow
make mount
./flow.tcl -design viterbi
```

**Hoặc chạy Interactive mode** (khuyến khích cho lần đầu):

```bash
make mount
./flow.tcl -design viterbi -interactive
```

Trong interactive mode:
```tcl
package require openlane
prep -design viterbi
run_synthesis
run_floorplan
run_placement
run_cts
run_routing
run_magic
run_lvs
run_drc
```

---

### 📊 Bước 9: Kiểm tra kết quả

```bash
# Xem synthesis report
cat runs/*/reports/synthesis/1-synthesis.stat.rpt

# Xem timing report
cat runs/*/reports/signoff/*sta.max.rpt

# Xem DRC violations
cat runs/*/reports/signoff/*drc.rpt

# Mở layout trong Klayout
klayout runs/*/results/final/gds/*.gds
```

---

### 📝 Bước 10: Tối ưu hóa (nếu cần)

**Nếu gặp timing violation**:
```tcl
# Tăng clock period (giảm tần số)
set ::env(CLOCK_PERIOD) "25.0"  # 40 MHz

# Hoặc tối ưu delay
set ::env(SYNTH_STRATEGY) "DELAY 0"
```

**Nếu gặp DRC violation**:
```tcl
# Tăng die area
set ::env(DIE_AREA) "0 0 500 500"

# Giảm utilization
set ::env(FP_CORE_UTIL) 35
```

---

## 5. Cấu trúc thư mục

```
Viterbi-Decoder-Implementation-and-Verification/
├── design/                     # RTL gốc (9 file .v)
│   ├── system_top.v
│   ├── viterbi_core.v
│   ├── sync_fifo.v
│   ├── piso.v, sipo.v
│   └── bmu.v, acsu.v, pmu.v, tbu.v
│
├── testbench/                  # Testbench cho simulation
│   ├── tb_system_top.sv
│   └── ...
│
├── OpenLane/                   # Cấu hình OpenLane
│   └── designs/
│       └── viterbi/
│           ├── config.tcl      ✅ Đã tạo
│           ├── constraints.sdc ✅ Đã tạo
│           └── src/            ✅ Đã copy RTL
│               ├── system_top.v    (đã sửa include)
│               └── ...
│
├── main (2).tex                # Báo cáo LaTeX
└── README.md
```

---

## 6. Các lỗi thường gặp

| Lỗi | Nguyên nhân | Giải pháp |
|-----|-------------|-----------|
| Clock not found | Tên clock sai | Kiểm tra `CLOCK_PORT` trong config.tcl |
| Module not found | Thiếu file .v | Copy đầy đủ file vào `src/` |
| PDK mismatch | PDK chưa cài | Kiểm tra `$PDK_ROOT` |
| Timing violation | Tần số quá cao | Tăng `CLOCK_PERIOD` |
| DRC violations | Die area nhỏ | Tăng `DIE_AREA`, giảm `FP_CORE_UTIL` |
| LVS mismatch | Port bị thiếu | Xem report chi tiết |

---

## 📚 Tham khảo

- [OpenLane Documentation](https://openlane.readthedocs.io/)
- [SKY130 PDK](https://skywater-pdk.readthedocs.io/)
- [Viterbi Algorithm - Wikipedia](https://en.wikipedia.org/wiki/Viterbi_algorithm)
