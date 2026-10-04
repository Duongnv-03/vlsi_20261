# 🔧 Viterbi Decoder - RTL to GDSII

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![HDL: Verilog](https://img.shields.io/badge/HDL-Verilog-blue.svg)]()
[![PDK: SKY130](https://img.shields.io/badge/PDK-SKY130-green.svg)]()

Thiết kế và tổng hợp bộ giải mã Viterbi từ RTL đến GDSII sử dụng OpenLane và PDK SKY130.

## 📋 Mục lục

- [Tổng quan](#-tổng-quan)
- [Thông số kỹ thuật](#-thông-số-kỹ-thuật)
- [Kiến trúc](#-kiến-trúc)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Simulation](#-simulation)
- [Physical Design với OpenLane](#-physical-design-với-openlane)
- [Test Cases](#-test-cases)
- [Tác giả](#-tác-giả)

---

## 🎯 Tổng quan

Dự án này triển khai một bộ giải mã **Viterbi Decoder** cho mã tích chập (Convolutional Code) với các đặc điểm:

- **Loại mã**: Convolutional Code (2, 1, 2)
- **Code Rate**: R = 1/2
- **Constraint Length**: K = 3
- **Đa thức sinh**: G1 = 7₈, G2 = 5₈
- **Khả năng sửa lỗi**: 1 bit/symbol

---

## 📊 Thông số kỹ thuật

| Thông số | Giá trị |
|----------|---------|
| Top Module | `system_top` |
| Input Width | 16 bits (encoded) |
| Output Width | 8 bits (decoded) |
| Target Clock | 50 MHz |
| Target PDK | SKY130 |
| Die Area | 400μm × 400μm |

### Interface

```verilog
module system_top (
    input  wire        clk,         // Clock 50MHz
    input  wire        rst_n,       // Reset Active Low
    input  wire        dvalid_i,    // Data Valid
    input  wire [15:0] data_i,      // Encoded Input
    output wire [7:0]  data_o,      // Decoded Output
    output wire        valid_o,     // Output Valid
    output wire        busy_o       // FIFO Full
);
```

---

## 🏗 Kiến trúc

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

### Các module con

| Module | Chức năng |
|--------|-----------|
| `sync_fifo` | Input buffer (16 entries × 16 bits) |
| `piso` | Parallel-In Serial-Out (16b → 2b) |
| `viterbi_core` | Core giải mã Viterbi |
| ├─ `bmu` | Branch Metric Unit |
| ├─ `acsu` | Add-Compare-Select Unit |
| ├─ `pmu` | Path Metric Unit |
| └─ `tbu` | Traceback Unit (Register Exchange) |
| `sipo` | Serial-In Parallel-Out (1b → 8b) |

---

## 📁 Cấu trúc thư mục

```
Viterbi-Decoder-Implementation-and-Verification/
│
├── design/                     # RTL Source Files
│   ├── system_top.v           # Top module
│   ├── viterbi_core.v         # Viterbi core
│   ├── sync_fifo.v            # Synchronous FIFO
│   ├── piso.v                 # Parallel to Serial
│   ├── sipo.v                 # Serial to Parallel
│   ├── bmu.v                  # Branch Metric Unit
│   ├── acsu.v                 # Add-Compare-Select
│   ├── pmu.v                  # Path Metric Unit
│   └── tbu.v                  # Traceback Unit
│
├── testbench/                  # Testbenches
│   ├── tb_system_top.sv       # System testbench
│   ├── tb_fifo.sv             # FIFO testbench
│   ├── tb_piso.sv             # PISO testbench
│   └── ...
│
├── OpenLane/                   # Physical Design
│   └── designs/
│       └── viterbi/
│           ├── config.tcl     # OpenLane config
│           ├── constraints.sdc # Timing constraints
│           └── src/           # RTL for synthesis
│
├── GUIDE.md                    # Hướng dẫn chi tiết
├── test_case_viterbi*.csv      # Test cases
└── README.md                   # File này
```

---

## 🧪 Simulation

### Yêu cầu

- [Icarus Verilog](http://iverilog.icarus.com/) hoặc
- [Cadence Incisive](https://www.cadence.com/)
- [GTKWave](http://gtkwave.sourceforge.net/) (xem waveform)

### Chạy simulation với Icarus Verilog

```bash
# Di chuyển vào thư mục testbench
cd testbench

# Compile và simulate
iverilog -g2012 -o sim.out \
    ../design/system_top.v \
    ../design/viterbi_core.v \
    ../design/sync_fifo.v \
    ../design/piso.v \
    ../design/sipo.v \
    ../design/bmu.v \
    ../design/acsu.v \
    ../design/pmu.v \
    ../design/tbu.v \
    tb_system_top.sv

# Chạy simulation
vvp sim.out

# Xem waveform
gtkwave system_wave.vcd
```

### Kết quả mong đợi

```
[INFO] Starting Viterbi Decoder Test
[INFO] Test vector 1: PASS
[INFO] Test vector 2: PASS
...
[PASS] ALL TESTS PASSED! (1025/1025)
```

---

## ⚙ Physical Design với OpenLane

### Yêu cầu

- [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane) (Docker)
- [SKY130 PDK](https://github.com/google/skywater-pdk)

### Các bước thực hiện

#### 1. Copy design vào OpenLane

```bash
# Trên Ubuntu/WSL
cp -r OpenLane/designs/viterbi ~/OpenLane/designs/
```

#### 2. Comment các dòng `include` (nếu chưa làm)

```bash
cd ~/OpenLane/designs/viterbi/src
sed -i 's/^`include/\/\/ `include/' system_top.v
sed -i 's/^`include/\/\/ `include/' viterbi_core.v
```

#### 3. Chạy OpenLane

```bash
cd ~/OpenLane
make mount
./flow.tcl -design viterbi
```

#### 4. Kiểm tra kết quả

```bash
# Synthesis report
cat runs/*/reports/synthesis/1-synthesis.stat.rpt

# Timing report
cat runs/*/reports/signoff/*sta.max.rpt

# Xem layout
klayout runs/*/results/final/gds/*.gds
```

### Cấu hình OpenLane

| Parameter | Value | Description |
|-----------|-------|-------------|
| `CLOCK_PERIOD` | 20.0 ns | 50 MHz |
| `FP_CORE_UTIL` | 40% | Core utilization |
| `DIE_AREA` | 400×400 μm | Die size |
| `PL_TARGET_DENSITY` | 0.45 | Placement density |

---

## ✅ Test Cases

Dự án bao gồm **44+ test cases** cho verification:

| Test Suite | Số TCs | Mô tả |
|------------|--------|-------|
| FIFO | 5 | Reset, Write/Read, Integrity |
| PISO | 5 | Bit patterns (0xAAAA, 0x5555, etc.) |
| BMU | 5 | Hamming distance calculations |
| ACSU | 5 | Add-Compare-Select logic |
| PMU | 5 | Path Metric storage |
| TBU | 6 | Traceback với Register Exchange |
| SIPO | 5 | Serial to Parallel |
| SYSTEM | 8+ | Integration tests |

### Error Correction

| Error Type | Bits | Result |
|------------|------|--------|
| No error | 0 | ✅ Correct |
| Single bit | 1 | ✅ Correctable |
| Double bit | 2 | ⚠️ May fail |
| Burst (3+) | 3+ | ❌ Expected fail |

Chi tiết xem tại [GUIDE.md](GUIDE.md)

---

## 👥 Tác giả

| Họ tên | MSSV |
|--------|------|
| Phạm Chí Dũng | 20200106 |
| Võ Ngọc Vinh | 20227447 |
| Nguyễn Văn Dương | 20241713E |

**Giảng viên hướng dẫn**: TS. Nguyễn Vũ Thắng

**Môn học**: Thiết kế VLSI (ET4340) - Đại học Bách khoa Hà Nội

---

## 📄 License

MIT License - Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

---

## 🔗 Tài liệu tham khảo

- [OpenLane Documentation](https://openlane.readthedocs.io/)
- [SKY130 PDK](https://skywater-pdk.readthedocs.io/)
- [Viterbi Algorithm - Wikipedia](https://en.wikipedia.org/wiki/Viterbi_algorithm)
