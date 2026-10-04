# 📊 BÁO CÁO DỰ ÁN: VITERBI DECODER IMPLEMENTATION AND VERIFICATION

**Ngày báo cáo**: 21/01/2026  
**Trạng thái**: ✅ RTL hoàn thành | 🔄 Đang chuẩn bị Physical Design

---

## 📋 Mục lục

1. [Thông tin chung](#1-thông-tin-chung)
2. [Lý thuyết nền tảng](#2-lý-thuyết-nền-tảng)
3. [Kiến trúc thiết kế](#3-kiến-trúc-thiết-kế)
4. [Chi tiết các module](#4-chi-tiết-các-module)
5. [Kết quả RTL Simulation](#5-kết-quả-rtl-simulation)
6. [Trạng thái Physical Design](#6-trạng-thái-physical-design)
7. [Tổng kết](#7-tổng-kết)

---

## 1. Thông tin chung

### 1.1 Thông tin đề tài

| Thông tin | Chi tiết |
|-----------|----------|
| **Đề tài** | Thiết kế và Tổng hợp Viterbi Decoder từ RTL đến GDSII |
| **Môn học** | Thiết kế VLSI (ET4340) |
| **Lớp** | 163187 |
| **Trường** | Đại học Bách khoa Hà Nội - Trường Điện - Điện Tử |

### 1.2 Thành viên nhóm

| Họ tên | MSSV | Vai trò |
|--------|------|---------|
| Phạm Chí Dũng | 20200106 | Thành viên |
| Võ Ngọc Vinh | 20227447 | Thành viên |
| Nguyễn Văn Dương | 20241713E | Thành viên |

**Giảng viên hướng dẫn**: TS. Nguyễn Vũ Thắng

### 1.3 Công cụ sử dụng

| Giai đoạn | Công cụ |
|-----------|---------|
| RTL Design | Verilog/SystemVerilog |
| RTL Simulation | Icarus Verilog, Cadence Incisive |
| Waveform Viewer | GTKWave |
| Physical Design | OpenLane (planned) |
| Target PDK | SKY130 |

---

## 2. Lý thuyết nền tảng

### 2.1 Mã tích chập (Convolutional Code)

Mã tích chập là dạng mã tuyến tính hoạt động như bộ lọc số, sử dụng phép tích chập. Đây là một trong những phương pháp mã hóa kênh phổ biến nhất trong viễn thông.

### 2.2 Thông số mã hóa

| Tham số | Ký hiệu | Giá trị | Mô tả |
|---------|---------|---------|-------|
| Số bit đầu vào | k | 1 | 1 bit input/chu kỳ |
| Số bit đầu ra | n | 2 | 2 bit output/chu kỳ |
| Số thanh ghi | m | 2 | 2 flip-flop |
| Constraint Length | K | 3 | K = m + 1 |
| Code Rate | R | 1/2 | R = k/n |

### 2.3 Đa thức sinh (Generator Polynomials)

```
G1 = 1 + x + x² = (111)₂ = 7₈
G2 = 1 + x²     = (101)₂ = 5₈
```

**Công thức đệ quy**:
```
V1 = U₀ ⊕ U₁ ⊕ U₂
V2 = U₀ ⊕ U₂
```

### 2.4 Sơ đồ trạng thái

```
             Input=0 (00)        Input=1 (11)
        ┌──────────────────┐ ┌──────────────────┐
        ▼                  │ │                  ▼
       ┌──┐               ┌──┐               ┌──┐               ┌──┐
       │00│──────────────▶│10│──────────────▶│01│──────────────▶│11│
       └──┘◀──────────────└──┘◀──────────────└──┘◀──────────────└──┘
             Input=0 (11)        Input=0 (01)        Input=1 (10)
```

---

## 3. Kiến trúc thiết kế

### 3.1 Sơ đồ khối hệ thống

```
                    ┌─────────────────────────────────────────────────────────┐
                    │                     SYSTEM_TOP                          │
                    │                                                         │
  data_i[15:0] ────▶│  ┌──────────┐   ┌──────┐   ┌──────────────┐   ┌──────┐ │───▶ data_o[7:0]
  dvalid_i ────────▶│  │SYNC_FIFO │──▶│ PISO │──▶│ VITERBI_CORE │──▶│ SIPO │ │───▶ valid_o
                    │  └──────────┘   └──────┘   └──────────────┘   └──────┘ │
  clk ─────────────▶│                                                         │◀─── busy_o
  rst_n ───────────▶│                                                         │
                    └─────────────────────────────────────────────────────────┘
```

### 3.2 Chi tiết Viterbi Core

```
                    ┌─────────────────────────────────────────────┐
                    │              VITERBI_CORE                   │
                    │                                             │
  piso_data_i[1:0]─▶│  ┌─────┐   ┌──────┐   ┌─────┐   ┌─────┐   │───▶ core_data_o
  valid_i ─────────▶│  │ BMU │──▶│ ACSU │──▶│ PMU │──▶│ TBU │   │───▶ core_valid_o
                    │  └─────┘   └──────┘   └─────┘   └─────┘   │
  clk ─────────────▶│     │          │          │         │     │
  rst_n ───────────▶│     └──────────┴──────────┴─────────┘     │
                    │              (Pipeline registers)          │
                    └─────────────────────────────────────────────┘
```

### 3.3 Interface signals

| Port | Hướng | Bit Width | Mô tả |
|------|-------|-----------|-------|
| `clk` | Input | 1 | Clock (50 MHz target) |
| `rst_n` | Input | 1 | Reset Active Low |
| `dvalid_i` | Input | 1 | Data Valid (Write Enable) |
| `data_i` | Input | 16 | Input Data |
| `data_o` | Output | 8 | Decoded Output Data |
| `valid_o` | Output | 1 | Output Valid |
| `busy_o` | Output | 1 | FIFO Full flag |

---

## 4. Chi tiết các module

### 4.1 SYNC_FIFO (Input Buffer)

| Đặc điểm | Giá trị |
|----------|---------|
| Data Width | 16 bits |
| Depth | 16 entries |
| Capacity | 256 bits (16 × 16) |
| Chức năng | Buffer đầu vào, tránh mất data |

### 4.2 PISO (Parallel-In Serial-Out)

| Đặc điểm | Giá trị |
|----------|---------|
| Input | 16 bits parallel |
| Output | 2 bits serial |
| Cycles/word | 8 cycles |
| Mode | Active (tự động đọc từ FIFO) |

### 4.3 BMU (Branch Metric Unit)

Tính Hamming distance giữa received symbols và expected symbols.

| Nhánh | From → To | Expected Output |
|-------|-----------|-----------------|
| bm_s0_s0 | S0 → S0 | 00 |
| bm_s0_s2 | S0 → S2 | 11 |
| bm_s1_s0 | S1 → S0 | 11 |
| bm_s1_s2 | S1 → S2 | 00 |
| bm_s2_s1 | S2 → S1 | 10 |
| bm_s2_s3 | S2 → S3 | 01 |
| bm_s3_s1 | S3 → S1 | 01 |
| bm_s3_s3 | S3 → S3 | 10 |

### 4.4 ACSU (Add-Compare-Select Unit)

Thực hiện thuật toán Viterbi:
1. **Add**: Cộng Branch Metric với Path Metric hiện tại
2. **Compare**: So sánh 2 đường đến cùng state
3. **Select**: Chọn đường có metric nhỏ hơn (survivor path)

### 4.5 PMU (Path Metric Unit)

| Đặc điểm | Giá trị |
|----------|---------|
| Bit Width | 8 bits / state |
| Số states | 4 (S0, S1, S2, S3) |
| Chức năng | Lưu trữ path metrics |

### 4.6 TBU (Traceback Unit)

| Đặc điểm | Giá trị |
|----------|---------|
| Traceback Length | 48 symbols |
| Method | Register Exchange |
| Output | 1 bit/cycle |

### 4.7 SIPO (Serial-In Parallel-Out)

| Đặc điểm | Giá trị |
|----------|---------|
| Input | 1 bit serial |
| Output | 8 bits parallel |
| Bit Order | Shift Right |

---

## 5. Kết quả RTL Simulation

### 5.1 Tổng quan Test Plan

Dự án sử dụng phương pháp **Unit Testing + System Integration Testing** với **44+ test cases**.

| Test Suite | Số TCs | Module được test |
|------------|--------|------------------|
| FIFO | 5 | sync_fifo |
| PISO | 5 | piso |
| BMU | 5 | bmu |
| ACSU | 5 | acsu |
| PMU | 5 | pmu |
| TBU | 6 | tbu |
| SIPO | 5 | sipo |
| SYSTEM | 8+ | system_top |
| **Tổng** | **44+** | |

### 5.2 Chi tiết Unit Tests

#### FIFO Tests
| ID | Kịch bản | Tiêu chí PASS |
|----|----------|---------------|
| TC_01 | Reset & Initialization | `empty_o=1`, `full_o=0` |
| TC_02 | Write until Full | `full_o` lên 1 khi đủ 16 entries |
| TC_03 | Read until Empty | Data FIFO đọc đúng thứ tự |
| TC_04 | Data Integrity (5 Rounds) | `error_count = 0` |
| TC_05 | Timing & Latency Check | Data ổn định sau 2ns |

#### PISO Tests
| ID | Input | Expected Output |
|----|-------|-----------------|
| TC_01 | 0xAAAA | 10,10,10,10,10,10,10,10 |
| TC_02 | 0x5555 | 01,01,01,01,01,01,01,01 |
| TC_03 | 0xFFFF | 11,11,11,11,11,11,11,11 |
| TC_04 | 0x0000 | 00,00,00,00,00,00,00,00 |
| TC_05 | Random | `error_count = 0` |

#### BMU Tests (Branch Metric Unit)
| ID | Input | Mô tả |
|----|-------|-------|
| TC_01 | 2'b00 | Hamming distance = 0 cho nhánh S0→S0 |
| TC_02 | 2'b11 | Hamming distance = 0 cho nhánh S0→S2 |
| TC_03 | 2'b01 | Test single bit error |
| TC_04 | 2'b10 | Test single bit error (inversed) |
| TC_05 | Random | `error_count = 0` |

#### ACSU Tests (Add-Compare-Select)
| ID | Kịch bản | Tiêu chí |
|----|----------|----------|
| TC_01 | Min Path Case | Chọn đúng nhánh có PM+BM nhỏ nhất |
| TC_02 | Switching Winner | DEC bit đổi khi nhánh thắng thay đổi |
| TC_03 | Boundary Case | PM = 250 (gần tràn 8-bit) |
| TC_04 | Zero Case | Không có Unknown (X) ở output |
| TC_05 | Random Stress | `error_count = 0` |

#### PMU Tests (Path Metric Unit)
| ID | Kịch bản | Tiêu chí |
|----|----------|----------|
| TC_01 | Reset Check | S0=0, S1-S3=255 sau reset |
| TC_02 | Update Enable | Cập nhật đúng khi `valid_i=1` |
| TC_03 | Keep Data | Giữ data khi `valid_i=0` |
| TC_04 | Zero Stream | Clear về 0 |
| TC_05 | Random Stress | `error_count = 0` |

#### TBU Tests (Traceback Unit)
| ID | Kịch bản | Tiêu chí |
|----|----------|----------|
| TC_01 | Reset Check | `valid_o=0`, history cleared |
| TC_02 | Pipeline Filling | Nạp 14 cycles, `valid_o` giữ 0 |
| TC_03 | Start Decoding | Cycle 15: `valid_o=1` |
| TC_04 | Data Traceback | Register Exchange hoạt động đúng |
| TC_05 | Valid_i Gating | Tạm dừng khi input invalid |
| TC_06 | Winner Switching | Chọn best path từ state có PM nhỏ nhất |

#### SIPO Tests
| ID | Input | Expected Output |
|----|-------|-----------------|
| TC_01 | Reset | `byte_ready_o=0`, `data_parallel_o=0` |
| TC_02 | 0xA5 | `data_parallel_o=0xA5` |
| TC_03 | 0xFF | `data_parallel_o=0xFF` |
| TC_04 | 0x00 | `data_parallel_o=0x00` |
| TC_05 | Random | `error_count = 0` |

### 5.3 System Integration Tests

| ID | Kịch bản | Mục đích | Expected |
|----|----------|----------|----------|
| SYS_01 | Sanity Check | Kiểm tra logic cơ bản | 0x00, 0xFF, 0xAA, 0x55 đúng |
| SYS_02 | Full Range Sweep | Test 0x00 → 0xFF | 256 bytes đúng 100% |
| SYS_03 | Single Bit Error | Lật 1 bit bất kỳ | Hệ thống tự sửa |
| SYS_04 | Double Bit Error | Lật 2 bit ngẫu nhiên | Có thể fail |
| SYS_05 | Burst Error | Lật 3-4 bit liên tiếp | Expected fail |
| SYS_06 | Busy Violation | Gửi data khi busy=1 | Phải bị ignore |
| SYS_07 | Continuous Streaming | 100 bytes back-to-back | Không mất gói |
| SYS_08 | Hard Reset | Reset giữa chừng | FSM về IDLE |

### 5.4 Error Correction Capability

| Loại lỗi | Số bit | Kết quả |
|----------|--------|---------|
| No error | 0 | ✅ Correct (100%) |
| Single bit | 1 | ✅ Correctable |
| Double bit | 2 | ⚠️ May fail |
| Burst (3+) | 3+ | ❌ Expected fail |

> **Lưu ý**: Viterbi (2,1,2) sửa được **1 bit lỗi** trong mỗi cặp symbol.

### 5.5 Công cụ và kết quả

| Metric | Giá trị |
|--------|---------|
| Simulator | Icarus Verilog / Cadence Incisive |
| Testbench | `tb_system_top.sv` |
| Test vectors | 1025 chuỗi 16-bit |
| **Pass rate** | **100%** |
| Output file | `output_result.txt` |
| Reference | ✅ Identical (Diffchecker) |

### 5.6 Waveform Files

- File VCD: `testbench/system_wave.vcd`
- Simulation log: `testbench/log_system`
- Tất cả tín hiệu hoạt động đúng theo timing diagram

---

## 6. Trạng thái Physical Design

### 6.1 Tiến độ chuẩn bị OpenLane

| Bước | Mô tả | Trạng thái |
|------|-------|------------|
| 1 | Tạo thư mục OpenLane/designs/viterbi | ✅ Hoàn thành |
| 2 | Copy RTL files | ✅ Hoàn thành |
| 3 | Comment `include directives | ✅ Hoàn thành |
| 4 | Tạo config.tcl | ✅ Hoàn thành |
| 5 | Tạo constraints.sdc | ✅ Hoàn thành |
| 6 | Copy sang Ubuntu | ⏳ Chờ thực hiện |
| 7 | Chạy synthesis | ⏳ Chờ thực hiện |
| 8 | Chạy PnR | ⏳ Chờ thực hiện |
| 9 | Chạy signoff | ⏳ Chờ thực hiện |

### 6.2 Target specifications

| Thông số | Giá trị mục tiêu |
|----------|------------------|
| PDK | SKY130 |
| Clock frequency | 50 MHz |
| Die area | 400μm × 400μm |
| Core utilization | 40% |
| Placement density | 45% |

### 6.3 Files đã tạo

```
OpenLane/designs/viterbi/
├── config.tcl           (1,553 bytes)
├── constraints.sdc      (1,075 bytes)
└── src/
    ├── system_top.v     (đã sửa include)
    ├── viterbi_core.v
    ├── sync_fifo.v
    ├── piso.v
    ├── sipo.v
    ├── bmu.v
    ├── acsu.v
    ├── pmu.v
    └── tbu.v
```

---

## 7. Tổng kết

### 7.1 Những gì đã hoàn thành

✅ **RTL Design**: Thiết kế hoàn chỉnh Viterbi Decoder (2,1,2)  
✅ **RTL Verification**: 100% test pass với 1025 test vectors  
✅ **Documentation**: Báo cáo LaTeX chi tiết  
✅ **OpenLane Prep**: Cấu hình và file SDC đã sẵn sàng

### 7.2 Công việc tiếp theo

1. Copy design sang máy Ubuntu có OpenLane
2. Comment `include` trong `viterbi_core.v`
3. Chạy OpenLane flow (synthesis → PnR → signoff)
4. Phân tích timing và DRC
5. Tối ưu hóa nếu cần
6. Xuất GDSII hoàn chỉnh

### 7.3 Đánh giá rủi ro

| Rủi ro | Mức độ | Giải pháp |
|--------|--------|-----------|
| Timing violation | Trung bình | Giảm clock frequency |
| DRC violations | Thấp | Tăng die area |
| LVS mismatch | Thấp | Kiểm tra kỹ port names |

---

## 📚 Tài liệu tham khảo

1. [OpenLane Documentation](https://openlane.readthedocs.io/)
2. [SKY130 PDK Documentation](https://skywater-pdk.readthedocs.io/)
3. Báo cáo BTL VLSI - `main (2).tex`
4. Viterbi Algorithm - Maximum Likelihood Decoding

---

*Báo cáo được tạo tự động bởi Antigravity Assistant*
