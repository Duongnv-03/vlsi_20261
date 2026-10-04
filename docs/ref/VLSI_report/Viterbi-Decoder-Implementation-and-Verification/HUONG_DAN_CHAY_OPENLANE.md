# 🚀 HƯỚNG DẪN CHẠY OPENLANE CHO VITERBI DECODER

**Dự án**: Viterbi Decoder RTL-to-GDSII
**PDK**: SKY130
**Top Module**: `system_top`
**Tần số mục tiêu**: 50 MHz

---

## 📋 Mục lục

1. [Yêu cầu hệ thống](#1-yêu-cầu-hệ-thống)
2. [Chuẩn bị môi trường](#2-chuẩn-bị-môi-trường)
3. [Các bước chạy OpenLane](#3-các-bước-chạy-openlane)
4. [Kiểm tra kết quả](#4-kiểm-tra-kết-quả)
5. [Xử lý lỗi thường gặp](#5-xử-lý-lỗi-thường-gặp)
6. [Tối ưu hóa thiết kế](#6-tối-ưu-hóa-thiết-kế)

---

## 1. Yêu cầu hệ thống

### Phần cứng tối thiểu:

- **RAM**: 8GB (khuyến nghị 16GB)
- **Disk**: 50GB trống
- **CPU**: 4 cores (khuyến nghị 8 cores)

### Phần mềm:

- **OS**: Ubuntu 20.04/22.04 hoặc WSL2
- **Docker**: Version 20.10+
- **OpenLane**: Version 2 (khuyến nghị)
- **PDK**: SKY130A

---

## 2. Chuẩn bị môi trường

### Bước 2.1: Kiểm tra Docker

```bash
# Kiểm tra Docker đã cài đặt chưa
docker --version

# Nếu chưa có, cài đặt Docker
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Thêm user vào group docker (không cần sudo)
sudo usermod -aG docker $USER
newgrp docker
```

### Bước 2.2: Cài đặt OpenLane (nếu chưa có)

**Option 1: Sử dụng OpenLane v2 (khuyến nghị)**

```bash
cd ~
git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane
make
```

**Option 2: Sử dụng OpenLane v1**

```bash
cd ~
git clone --depth 1 https://github.com/efabless/openlane.git
cd openlane
make
```

### Bước 2.3: Kiểm tra PDK

```bash
# Kiểm tra biến môi trường PDK_ROOT
echo $PDK_ROOT

# Nếu chưa có, OpenLane sẽ tự động tải PDK khi chạy lần đầu
# Hoặc cài thủ công:
cd ~/OpenLane
make pdk
```

---

## 3. Các bước chạy OpenLane

### 🔧 Bước 3.1: Copy design vào OpenLane

```bash
# Di chuyển đến thư mục dự án
cd /home/iot/Study/VLSI/Open_Lane/Viterbi-Decoder-Implementation-and-Verification

# Copy design vào thư mục OpenLane (nếu OpenLane ở ~/OpenLane)
cp -r OpenLane/designs/viterbi ~/OpenLane/designs/

# Hoặc tạo symbolic link (khuyến nghị)
ln -s $(pwd)/OpenLane/designs/viterbi ~/OpenLane/designs/viterbi
```

### 🚀 Bước 3.2: Chạy OpenLane Flow

#### **Phương pháp 1: Automatic Flow (Khuyến nghị cho lần đầu)**

```bash
cd ~/OpenLane

# Khởi động Docker container
make mount

# Trong container, chạy flow tự động
./flow.tcl -design viterbi
```

**Lưu ý**: Flow này sẽ chạy tất cả các bước từ synthesis đến GDSII tự động.

#### **Phương pháp 2: Interactive Flow (Khuyến nghị để debug)**

```bash
cd ~/OpenLane

# Khởi động Docker container
make mount

# Trong container, chạy interactive mode
./flow.tcl -design viterbi -interactive
```

Trong interactive mode, chạy từng bước:

```tcl
# 1. Load OpenLane package
package require openlane 0.9

# 2. Chuẩn bị design
prep -design viterbi

# 3. Synthesis (Tổng hợp RTL thành netlist)
run_synthesis

# 4. Floorplanning (Lập kế hoạch mặt bằng)
run_floorplan

# 5. Placement (Đặt các cell)
run_placement

# 6. Clock Tree Synthesis (Tạo cây clock)
run_cts

# 7. Routing (Định tuyến dây nối)
run_routing

# 8. Magic DRC (Kiểm tra Design Rule)
run_magic

# 9. LVS (Layout vs Schematic)
run_lvs

# 10. Antenna Check
run_antenna_check

# 11. Tạo GDSII final
run_magic_spice_export
run_magic_drc
```

### 📊 Bước 3.3: Theo dõi tiến trình

Trong quá trình chạy, bạn sẽ thấy các log như:

```
[INFO]: Running Synthesis...
[INFO]: Synthesis was successful
[INFO]: Running Floorplan...
[INFO]: Floorplan was successful
[INFO]: Running Placement...
[INFO]: Placement was successful
...
```

**Thời gian ước tính**:

- Synthesis: 2-5 phút
- Floorplan: 1-2 phút
- Placement: 5-10 phút
- CTS: 3-5 phút
- Routing: 10-30 phút
- DRC/LVS: 5-10 phút

**Tổng thời gian**: 30-60 phút (tùy cấu hình máy)

---

## 4. Kiểm tra kết quả

### Bước 4.1: Xem tổng quan kết quả

```bash
cd ~/OpenLane/designs/viterbi

# Tìm thư mục run mới nhất
ls -lt runs/

# Ví dụ: runs/RUN_2026.01.21_02.51.09
cd runs/RUN_2026.01.21_02.51.09
```

### Bước 4.2: Kiểm tra Synthesis Report

```bash
# Xem thống kê synthesis
cat reports/synthesis/1-synthesis.stat.rpt

# Các thông tin quan trọng:
# - Number of cells
# - Number of nets
# - Chip area
# - Number of wires
```

**Ví dụ output**:

```
=== system_top ===
   Number of wires:               1234
   Number of wire bits:           1234
   Number of public wires:         123
   Number of public wire bits:     123
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                567
     sky130_fd_sc_hd__a21o_1         12
     sky130_fd_sc_hd__a22o_1          8
     ...
   Chip area for module '\system_top': 15234.567890
```

### Bước 4.3: Kiểm tra Timing Report

```bash
# Xem timing summary
cat reports/signoff/system_top-sta-rcx_nom/summary.rpt

# Hoặc xem chi tiết
cat reports/signoff/system_top-sta-rcx_nom/max_ss_100C_1v60/checks.rpt
```

**Kiểm tra các thông số**:

- ✅ **Setup slack**: Phải > 0 (nếu âm = timing violation)
- ✅ **Hold slack**: Phải > 0
- ✅ **Clock period**: Đạt 20ns (50MHz)

### Bước 4.4: Kiểm tra DRC Violations

```bash
# Xem DRC report
cat reports/signoff/system_top-drc.rpt

# Kết quả mong đợi:
# Total DRC violations: 0
```

### Bước 4.5: Kiểm tra LVS

```bash
# Xem LVS report
cat reports/signoff/system_top-lvs.rpt

# Tìm dòng:
# Circuits match uniquely.
```

### Bước 4.6: Xem Layout (GDSII)

```bash
# Sử dụng KLayout để xem layout
klayout results/final/gds/system_top.gds

# Hoặc xem screenshot (nếu đã enable TAKE_LAYOUT_SCROT)
ls results/final/png/
```

### Bước 4.7: Xem tổng hợp metrics

```bash
# File CSV chứa tất cả metrics
cat reports/metrics.csv

# Hoặc xem dạng JSON
cat reports/metrics.json
```

**Các metrics quan trọng**:

- `DIEAREA_mm^2`: Diện tích die
- `CellPer_mm^2`: Mật độ cell
- `OpenDP_Util`: Utilization thực tế
- `wire_length`: Tổng chiều dài dây
- `wns`: Worst Negative Slack (timing)
- `CLOCK_PERIOD`: Clock period đạt được

---

## 5. Xử lý lỗi thường gặp

### ❌ Lỗi 1: "Clock port not found"

**Nguyên nhân**: Tên clock port trong `config.tcl` không khớp với RTL

**Giải pháp**:

```bash
# Kiểm tra tên clock trong RTL
grep -n "input.*clk" ~/OpenLane/designs/viterbi/src/system_top.v

# Sửa config.tcl
nano ~/OpenLane/designs/viterbi/config.tcl
# Đảm bảo: set ::env(CLOCK_PORT) "clk"
```

### ❌ Lỗi 2: "Timing violation" (Setup/Hold slack âm)

**Nguyên nhân**: Clock period quá ngắn (tần số quá cao)

**Giải pháp**:

```tcl
# Trong config.tcl, tăng clock period
set ::env(CLOCK_PERIOD) "25.0"  # Giảm từ 50MHz xuống 40MHz

# Hoặc thay đổi synthesis strategy
set ::env(SYNTH_STRATEGY) "DELAY 0"  # Tối ưu delay thay vì area
```

### ❌ Lỗi 3: "DRC violations"

**Nguyên nhân**: Die area quá nhỏ, routing quá chật

**Giải pháp**:

```tcl
# Tăng die area
set ::env(DIE_AREA) "0 0 500 500"  # Tăng từ 400x400 lên 500x500

# Giảm utilization
set ::env(FP_CORE_UTIL) 35  # Giảm từ 40% xuống 35%

# Giảm placement density
set ::env(PL_TARGET_DENSITY) 0.40  # Giảm từ 0.45 xuống 0.40
```

### ❌ Lỗi 4: "Module not found"

**Nguyên nhân**: Thiếu file RTL hoặc `include` chưa được comment

**Giải pháp**:

```bash
# Kiểm tra tất cả file .v đã có
ls ~/OpenLane/designs/viterbi/src/

# Kiểm tra và comment tất cả dòng `include
grep -n "^\`include" ~/OpenLane/designs/viterbi/src/*.v

# Nếu có, comment chúng:
sed -i 's/^`include/\/\/ `include/' ~/OpenLane/designs/viterbi/src/*.v
```

### ❌ Lỗi 5: "Antenna violations"

**Nguyên nhân**: Dây dài tích tụ điện tích

**Giải pháp**:

```tcl
# Trong config.tcl
set ::env(DIODE_INSERTION_STRATEGY) 4
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
```

---

## 6. Tối ưu hóa thiết kế

### 🎯 Mục tiêu tối ưu

| Mục tiêu                    | Tham số cần điều chỉnh                          |
| ----------------------------- | ---------------------------------------------------- |
| **Giảm diện tích**   | `SYNTH_STRATEGY = AREA 0`, tăng `FP_CORE_UTIL`  |
| **Tăng tốc độ**     | `SYNTH_STRATEGY = DELAY 0`, giảm `CLOCK_PERIOD` |
| **Giảm công suất**   | `SYNTH_STRATEGY = AREA 0`, giảm `CLOCK_PERIOD`  |
| **Cải thiện routing** | Tăng `DIE_AREA`, giảm `PL_TARGET_DENSITY`      |

### 📈 Quy trình tối ưu

1. **Chạy baseline flow** (với config mặc định)
2. **Phân tích metrics** (area, timing, power)
3. **Điều chỉnh config.tcl** theo mục tiêu
4. **Chạy lại flow**
5. **So sánh kết quả**
6. **Lặp lại** cho đến khi đạt yêu cầu

### 🔧 Các tham số nâng cao

```tcl
# Tối ưu synthesis
set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_SIZING) 1
set ::env(SYNTH_MAX_FANOUT) 6

# Tối ưu placement
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1

# Tối ưu routing
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(ROUTING_OPT_ITERS) 64
```

---

## 📚 Tài liệu tham khảo

- [OpenLane Documentation](https://openlane.readthedocs.io/)
- [OpenLane GitHub](https://github.com/The-OpenROAD-Project/OpenLane)
- [SKY130 PDK](https://skywater-pdk.readthedocs.io/)
- [OpenROAD Flow](https://openroad.readthedocs.io/)

---

## 🎓 Checklist hoàn thành

- [ ] Docker đã cài đặt và chạy được
- [ ] OpenLane đã cài đặt
- [ ] PDK SKY130 đã có
- [ ] Design đã copy vào `~/OpenLane/designs/viterbi`
- [ ] Đã chạy synthesis thành công
- [ ] Đã chạy floorplan thành công
- [ ] Đã chạy placement thành công
- [ ] Đã chạy CTS thành công
- [ ] Đã chạy routing thành công
- [ ] Timing đạt yêu cầu (slack > 0)
- [ ] DRC violations = 0
- [ ] LVS pass (circuits match)
- [ ] Đã xem layout trong KLayout
- [ ] Đã lưu GDSII file

---

## 💡 Tips & Tricks

1. **Sử dụng interactive mode** cho lần chạy đầu tiên để dễ debug
2. **Backup config.tcl** trước khi thay đổi
3. **So sánh nhiều runs** bằng cách xem `metrics.csv`
4. **Sử dụng `make mount`** thay vì `docker run` thủ công
5. **Đọc log files** trong `logs/` nếu gặp lỗi
6. **Tham khảo designs mẫu** trong `~/OpenLane/designs/spm/` hoặc `picorv32a/`

---

**Chúc bạn thành công! 🚀**

Nếu gặp vấn đề, hãy kiểm tra:

1. Log files trong `runs/*/logs/`
2. Reports trong `runs/*/reports/`
3. OpenLane GitHub Issues
4. SKY130 PDK documentation
