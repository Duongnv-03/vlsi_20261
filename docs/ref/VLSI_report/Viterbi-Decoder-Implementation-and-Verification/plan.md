# 📋 KẾ HOẠCH CHẠY OPENLANE CHO VITERBI DECODER

**Dự án**: Viterbi Decoder Implementation and Verification  
**Target**: SKY130 PDK - RTL to GDSII  
**Ngày tạo**: 2026-01-21  
**Trạng thái**: Ready to Execute

---

## 🔍 KIỂM TRA MÔI TRƯỜNG

### ✅ Đã có sẵn:

| Thành phần | Trạng thái | Chi tiết |
|------------|-----------|----------|
| **Docker** | ✅ Installed | Version 28.2.2 |
| **OpenLane Docker Image** | ✅ Available | `ghcr.io/efabless/openlane2:2.3.10` (5.33GB) |
| **Design Files** | ✅ Ready | 9 RTL files trong `OpenLane/designs/viterbi/src/` |
| **Config Files** | ✅ Ready | `config.tcl`, `constraints.sdc` |

### ⚠️ Cần chuẩn bị:

| Thành phần | Trạng thái | Hành động cần thiết |
|------------|-----------|---------------------|
| **OpenLane Repository** | ❌ Not Found | Cần clone OpenLane repo |
| **PDK_ROOT** | ❌ Not Set | Cần cài đặt SKY130 PDK |
| **viterbi_core.v** | ⚠️ Needs Fix | Cần comment các dòng `include` |

---

## 📝 KẾ HOẠCH THỰC HIỆN

### **GIAI ĐOẠN 1: CHUẨN BỊ MÔI TRƯỜNG** ⏱️ 30-60 phút

#### **Bước 1.1: Clone OpenLane Repository**

```bash
cd ~
git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane
git checkout 2.3.10  # Khớp với Docker image version
```

**Mục tiêu**: Có thư mục `~/OpenLane` với scripts và Makefile

---

#### **Bước 1.2: Cài đặt SKY130 PDK**

**Option A - Sử dụng OpenLane built-in PDK installer:**
```bash
cd ~/OpenLane
make pdk
```

**Option B - Manual installation:**
```bash
export PDK_ROOT=$HOME/pdk
mkdir -p $PDK_ROOT

# Clone SKY130 PDK
git clone https://github.com/google/skywater-pdk.git $PDK_ROOT/skywater-pdk
cd $PDK_ROOT/skywater-pdk
git submodule update --init libraries/sky130_fd_sc_hd/latest

# Clone Open PDKs
git clone https://github.com/RTimothyEdwards/open_pdks.git $PDK_ROOT/open_pdks
cd $PDK_ROOT/open_pdks
./configure --enable-sky130-pdk=$PDK_ROOT/skywater-pdk/libraries
make
make install
```

**Kiểm tra:**
```bash
ls $PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/
# Phải thấy: lib/, lef/, gds/, techlef/, ...
```

**Thêm vào `~/.bashrc`:**
```bash
echo 'export PDK_ROOT=$HOME/pdk' >> ~/.bashrc
source ~/.bashrc
```

---

#### **Bước 1.3: Sửa file viterbi_core.v**

**Vấn đề hiện tại:**
```verilog
`include "bmu.v"
`include "acsu.v"
`include "pmu.v"
`include "tbu.v"
```

**Cần sửa thành:**
```verilog
// `include "bmu.v"      // Commented for OpenLane - auto-compiled
// `include "acsu.v"     // Commented for OpenLane - auto-compiled
// `include "pmu.v"      // Commented for OpenLane - auto-compiled
// `include "tbu.v"      // Commented for OpenLane - auto-compiled
```

**Lệnh tự động:**
```bash
cd /home/iot/Study/VLSI/Open_Lane/Viterbi-Decoder-Implementation-and-Verification
sed -i 's/^`include/\/\/ `include/' OpenLane/designs/viterbi/src/viterbi_core.v
```

**Kiểm tra:**
```bash
grep "include" OpenLane/designs/viterbi/src/viterbi_core.v
# Phải thấy: // `include "bmu.v" ...
```

---

#### **Bước 1.4: Copy design vào OpenLane**

```bash
# Copy toàn bộ design folder vào OpenLane
cp -r /home/iot/Study/VLSI/Open_Lane/Viterbi-Decoder-Implementation-and-Verification/OpenLane/designs/viterbi \
      ~/OpenLane/designs/
```

**Kiểm tra:**
```bash
ls ~/OpenLane/designs/viterbi/
# Phải thấy: config.tcl, constraints.sdc, src/
```

---

### **GIAI ĐOẠN 2: CHẠY OPENLANE FLOW** ⏱️ 1-2 giờ

#### **Bước 2.1: Khởi động OpenLane Docker**

```bash
cd ~/OpenLane
make mount
```

**Kết quả mong đợi:**
- Docker container khởi động
- Mount thư mục designs và PDK
- Vào shell của OpenLane

---

#### **Bước 2.2: Chạy Interactive Mode (Khuyến khích cho lần đầu)**

**Trong OpenLane shell:**
```tcl
# Load OpenLane package
package require openlane

# Prepare design
prep -design viterbi

# Chạy từng bước để dễ debug
run_synthesis
run_floorplan
run_placement
run_cts
run_routing
run_magic
run_lvs
run_drc

# Tạo final output
run_magic_spice_export
run_magic_gds
```

**Hoặc chạy Automatic Mode:**
```bash
cd ~/OpenLane
make mount
./flow.tcl -design viterbi
```

---

#### **Bước 2.3: Theo dõi quá trình**

**Các bước sẽ chạy:**

| Bước | Tên | Thời gian ước tính | Mô tả |
|------|-----|-------------------|-------|
| 1 | **Synthesis** | 2-5 phút | Chuyển RTL → netlist |
| 2 | **Floorplan** | 1-2 phút | Lập kế hoạch mặt bằng |
| 3 | **Placement** | 3-5 phút | Đặt các standard cells |
| 4 | **CTS** | 2-3 phút | Clock Tree Synthesis |
| 5 | **Routing** | 10-20 phút | Routing các nets |
| 6 | **Magic DRC** | 2-3 phút | Design Rule Check |
| 7 | **LVS** | 2-3 phút | Layout vs Schematic |
| 8 | **Antenna Check** | 1-2 phút | Kiểm tra antenna effect |

**Tổng thời gian**: ~30-45 phút (tùy cấu hình máy)

---

### **GIAI ĐOẠN 3: KIỂM TRA KẾT QUẢ** ⏱️ 30 phút

#### **Bước 3.1: Kiểm tra Synthesis Report**

```bash
cd ~/OpenLane/designs/viterbi/runs/RUN_*/
cat reports/synthesis/1-synthesis.stat.rpt
```

**Thông tin cần xem:**
- **Number of cells**: Số lượng standard cells
- **Chip area**: Diện tích chip (μm²)
- **Number of wires**: Số lượng nets
- **Number of registers**: Số flip-flops

**Ví dụ output:**
```
Chip area for module '\system_top': 5234.567890
Number of cells:        1234
  sky130_fd_sc_hd__dfxtp_1    123
  sky130_fd_sc_hd__nand2_1     45
  ...
```

---

#### **Bước 3.2: Kiểm tra Timing Report**

```bash
cat reports/signoff/*sta.max.rpt
```

**Kiểm tra:**
- **Setup time**: Phải PASS (slack ≥ 0)
- **Hold time**: Phải PASS (slack ≥ 0)
- **Clock period**: 20ns (50MHz)

**Ví dụ:**
```
Startpoint: _123_ (rising edge-triggered flip-flop clocked by clk)
Endpoint: _456_ (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: max

  Delay    Time   Description
---------------------------------------------------------
  0.00    0.00   clock clk (rise edge)
  ...
  18.50   18.50  data arrival time

  20.00   20.00  clock clk (rise edge)
  -0.25   19.75  clock uncertainty
  ...
  19.75   19.75  data required time
---------------------------------------------------------
          1.25   slack (MET)  ✅
```

**Nếu slack < 0**: Timing violation ❌ → Cần tối ưu

---

#### **Bước 3.3: Kiểm tra DRC Violations**

```bash
cat reports/signoff/*drc.rpt
```

**Mục tiêu**: `Total violations = 0`

**Nếu có violations:**
```
[INFO] Total DRC violations: 5
  - Metal spacing violation: 3
  - Via overlap: 2
```

→ Cần tăng die area hoặc giảm utilization

---

#### **Bước 3.4: Kiểm tra LVS**

```bash
cat reports/signoff/*lvs.rpt
```

**Mục tiêu**: `Circuits match uniquely.`

**Nếu mismatch:**
- Kiểm tra port names
- Kiểm tra module hierarchy

---

#### **Bước 3.5: Xem Layout**

```bash
# Mở GDSII trong Klayout
klayout results/final/gds/system_top.gds

# Hoặc xem screenshot
eog results/final/gds/system_top.gds.png
```

---

### **GIAI ĐOẠN 4: TỐI ƯU HÓA (NẾU CẦN)** ⏱️ 1-3 giờ

#### **Kịch bản 1: Timing Violation (Setup)**

**Triệu chứng:**
```
slack (VIOLATED) -2.35
```

**Giải pháp:**

**Option A - Giảm tần số:**
```tcl
# Trong config.tcl
set ::env(CLOCK_PERIOD) "25.0"  # 40 MHz thay vì 50 MHz
```

**Option B - Tối ưu delay:**
```tcl
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(SYNTH_SIZING) 1
set ::env(SYNTH_BUFFERING) 1
```

**Option C - Tăng placement density:**
```tcl
set ::env(PL_TARGET_DENSITY) 0.35  # Giảm từ 0.45
```

---

#### **Kịch bản 2: DRC Violations**

**Triệu chứng:**
```
Total DRC violations: 15
```

**Giải pháp:**

**Option A - Tăng die area:**
```tcl
set ::env(DIE_AREA) "0 0 500 500"  # Tăng từ 400x400
```

**Option B - Giảm utilization:**
```tcl
set ::env(FP_CORE_UTIL) 35  # Giảm từ 40
```

**Option C - Tăng routing resources:**
```tcl
set ::env(GLB_RT_ADJUSTMENT) 0.1
set ::env(GLB_RT_OVERFLOW_ITERS) 100
```

---

#### **Kịch bản 3: Congestion (Routing failed)**

**Triệu chứng:**
```
[ERROR] Routing overflow detected
```

**Giải pháp:**

```tcl
# Tăng die area
set ::env(DIE_AREA) "0 0 600 600"

# Giảm density
set ::env(FP_CORE_UTIL) 30
set ::env(PL_TARGET_DENSITY) 0.35

# Tăng routing layers
set ::env(RT_MAX_LAYER) "met5"
```

---

#### **Kịch bản 4: LVS Mismatch**

**Triệu chứng:**
```
Circuits do not match
```

**Giải pháp:**

1. Kiểm tra port names trong RTL
2. Kiểm tra module hierarchy
3. Xem chi tiết:
```bash
cat results/final/lvs/system_top.lvs.out
```

---

### **GIAI ĐOẠN 5: XUẤT KẾT QUẢ CUỐI CÙNG** ⏱️ 15 phút

#### **Bước 5.1: Thu thập các file quan trọng**

```bash
cd ~/OpenLane/designs/viterbi/runs/RUN_*/

# Tạo thư mục output
mkdir -p ~/viterbi_output

# Copy GDSII
cp results/final/gds/system_top.gds ~/viterbi_output/

# Copy netlist
cp results/final/verilog/gl/system_top.v ~/viterbi_output/system_top_gl.v

# Copy reports
cp -r reports ~/viterbi_output/

# Copy DEF
cp results/final/def/system_top.def ~/viterbi_output/

# Copy LEF
cp results/final/lef/system_top.lef ~/viterbi_output/
```

---

#### **Bước 5.2: Tạo summary report**

```bash
cat > ~/viterbi_output/SUMMARY.md << 'EOF'
# VITERBI DECODER - OPENLANE SUMMARY

## Design Information
- **Design Name**: system_top
- **Technology**: SKY130 (130nm)
- **Clock Frequency**: 50 MHz
- **Date**: $(date)

## Synthesis Results
$(cat reports/synthesis/1-synthesis.stat.rpt | grep "Chip area")
$(cat reports/synthesis/1-synthesis.stat.rpt | grep "Number of cells")

## Timing Results
$(cat reports/signoff/*sta.max.rpt | grep "slack")

## DRC Results
$(cat reports/signoff/*drc.rpt | grep "Total violations")

## LVS Results
$(cat reports/signoff/*lvs.rpt | grep "match")

## Files Generated
- GDSII: system_top.gds
- Gate-level Netlist: system_top_gl.v
- DEF: system_top.def
- LEF: system_top.lef
EOF
```

---

#### **Bước 5.3: Copy về project folder**

```bash
# Copy output về project folder
cp -r ~/viterbi_output/* \
      /home/iot/Study/VLSI/Open_Lane/Viterbi-Decoder-Implementation-and-Verification/output/
```

---

## 📊 CHECKLIST HOÀN THÀNH

### Giai đoạn 1: Chuẩn bị
- [ ] Clone OpenLane repository
- [ ] Cài đặt SKY130 PDK
- [ ] Set biến môi trường PDK_ROOT
- [ ] Sửa file viterbi_core.v (comment includes)
- [ ] Copy design vào ~/OpenLane/designs/

### Giai đoạn 2: Chạy Flow
- [ ] Khởi động Docker (make mount)
- [ ] Chạy prep -design viterbi
- [ ] Chạy run_synthesis
- [ ] Chạy run_floorplan
- [ ] Chạy run_placement
- [ ] Chạy run_cts
- [ ] Chạy run_routing
- [ ] Chạy run_magic, run_lvs, run_drc

### Giai đoạn 3: Kiểm tra
- [ ] Synthesis report: OK
- [ ] Timing report: Setup slack ≥ 0
- [ ] Timing report: Hold slack ≥ 0
- [ ] DRC violations: 0
- [ ] LVS: Circuits match
- [ ] Layout: Xem được trong Klayout

### Giai đoạn 4: Tối ưu (nếu cần)
- [ ] Fix timing violations
- [ ] Fix DRC violations
- [ ] Fix LVS mismatch
- [ ] Re-run flow

### Giai đoạn 5: Xuất kết quả
- [ ] Copy GDSII
- [ ] Copy gate-level netlist
- [ ] Copy reports
- [ ] Tạo summary report
- [ ] Archive toàn bộ run

---

## 🚨 XỬ LÝ LỖI THƯỜNG GẶP

### Lỗi 1: Docker permission denied

**Triệu chứng:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Giải pháp:**
```bash
sudo usermod -aG docker $USER
newgrp docker
# Hoặc logout/login lại
```

---

### Lỗi 2: PDK not found

**Triệu chứng:**
```
[ERROR] PDK_ROOT not set or SKY130 not found
```

**Giải pháp:**
```bash
export PDK_ROOT=$HOME/pdk
echo 'export PDK_ROOT=$HOME/pdk' >> ~/.bashrc
```

---

### Lỗi 3: Module not found during synthesis

**Triệu chứng:**
```
[ERROR] Cannot find module 'bmu'
```

**Giải pháp:**
```bash
# Kiểm tra tất cả file .v có trong src/
ls ~/OpenLane/designs/viterbi/src/
# Phải có: bmu.v, acsu.v, pmu.v, tbu.v, ...
```

---

### Lỗi 4: Clock not found

**Triệu chứng:**
```
[ERROR] Clock 'clk' not found
```

**Giải pháp:**
```tcl
# Kiểm tra config.tcl
set ::env(CLOCK_PORT) "clk"  # Phải khớp với port trong RTL
```

---

### Lỗi 5: Out of memory

**Triệu chứng:**
```
[ERROR] Killed (out of memory)
```

**Giải pháp:**
```bash
# Tăng Docker memory limit
# Hoặc giảm ROUTING_CORES
set ::env(ROUTING_CORES) 2
```

---

## 📈 METRICS MỤC TIÊU

| Metric | Target | Acceptable Range |
|--------|--------|------------------|
| **Clock Frequency** | 50 MHz | 40-60 MHz |
| **Setup Slack** | ≥ 0 ns | ≥ -0.5 ns |
| **Hold Slack** | ≥ 0 ns | ≥ 0 ns (strict) |
| **DRC Violations** | 0 | 0 (strict) |
| **LVS** | Match | Match (strict) |
| **Core Utilization** | 40% | 30-50% |
| **Die Area** | 400×400 μm² | 400-600 μm² |
| **Total Cells** | TBD | - |
| **Power** | TBD | - |

---

## 📚 TÀI LIỆU THAM KHẢO

1. **OpenLane Documentation**: https://openlane.readthedocs.io/
2. **SKY130 PDK**: https://skywater-pdk.readthedocs.io/
3. **OpenLane GitHub**: https://github.com/The-OpenROAD-Project/OpenLane
4. **Efabless Platform**: https://efabless.com/
5. **OpenROAD**: https://theopenroadproject.org/

---

## 📞 HỖ TRỢ

**Nếu gặp vấn đề:**
1. Kiểm tra log files trong `runs/RUN_*/logs/`
2. Tìm kiếm lỗi trên OpenLane GitHub Issues
3. Hỏi trên OpenLane Slack/Discord community

---

## 📝 GHI CHÚ

- **Lần chạy đầu tiên** có thể mất 1-2 giờ
- **Docker image** khá lớn (5.33GB), cần đủ disk space
- **PDK installation** cần ~10GB disk space
- **Khuyến khích chạy interactive mode** để dễ debug
- **Backup config.tcl** trước khi thay đổi tham số

---

**Chúc bạn thành công! 🚀**
