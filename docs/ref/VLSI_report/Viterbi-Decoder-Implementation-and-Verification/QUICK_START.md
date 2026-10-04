# ⚡ QUICK REFERENCE - CHẠY OPENLANE

## 🚀 Cách nhanh nhất để bắt đầu

### Option 1: Sử dụng Script tự động (Khuyến nghị)

```bash
cd /home/iot/Study/VLSI/Open_Lane/Viterbi-Decoder-Implementation-and-Verification

# Chạy menu tương tác
./run_openlane.sh

# Hoặc chạy tự động toàn bộ
./run_openlane.sh auto
```

### Option 2: Chạy thủ công từng bước

```bash
# Bước 1: Kiểm tra môi trường
./run_openlane.sh check

# Bước 2: Chuẩn bị design
./run_openlane.sh prepare

# Bước 3: Chạy OpenLane
./run_openlane.sh run

# Bước 4: Xem kết quả
./run_openlane.sh results
```

### Option 3: Chạy trực tiếp OpenLane (Không dùng script)

```bash
# Di chuyển đến OpenLane
cd ~/OpenLane

# Tạo symbolic link (chỉ cần làm 1 lần)
ln -s /home/iot/Study/VLSI/Open_Lane/Viterbi-Decoder-Implementation-and-Verification/OpenLane/designs/viterbi ~/OpenLane/designs/viterbi

# Chạy automatic flow
make mount
# Trong container:
./flow.tcl -design viterbi

# Hoặc chạy interactive mode
make mount
# Trong container:
./flow.tcl -design viterbi -interactive
```

---

## 📊 Các lệnh quan trọng trong Interactive Mode

```tcl
# 1. Load package
package require openlane 0.9

# 2. Chuẩn bị design
prep -design viterbi

# 3. Chạy từng bước
run_synthesis          # Tổng hợp RTL → Netlist
run_floorplan          # Lập kế hoạch mặt bằng
run_placement          # Đặt các cell
run_cts                # Tạo cây clock
run_routing            # Định tuyến dây nối
run_magic              # DRC check
run_lvs                # Layout vs Schematic
run_antenna_check      # Kiểm tra antenna

# 4. Tạo GDSII
run_magic_spice_export
run_magic_drc
```

---

## 🔍 Kiểm tra kết quả nhanh

```bash
# Tìm run directory mới nhất
cd ~/OpenLane/designs/viterbi
ls -lt runs/

# Giả sử run mới nhất là RUN_2026.01.21_02.51.09
cd runs/RUN_2026.01.21_02.51.09

# Xem synthesis stats
cat reports/synthesis/1-synthesis.stat.rpt | grep "Chip area"

# Xem timing summary
cat reports/signoff/system_top-sta-rcx_nom/summary.rpt

# Kiểm tra DRC
cat reports/signoff/system_top-drc.rpt | grep -i violation

# Kiểm tra LVS
cat reports/signoff/system_top-lvs.rpt | grep -i "match"

# Xem tất cả metrics
cat reports/metrics.csv

# Mở layout
klayout results/final/gds/system_top.gds
```

---

## ⚙️ Các tham số quan trọng trong config.tcl

```tcl
# Tên design
set ::env(DESIGN_NAME) "system_top"

# Clock (50 MHz = 20ns)
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "20.0"

# Diện tích
set ::env(DIE_AREA) "0 0 400 400"        # 400μm x 400μm
set ::env(FP_CORE_UTIL) 40               # 40% utilization

# Tối ưu hóa
set ::env(SYNTH_STRATEGY) "AREA 0"       # AREA 0-3 hoặc DELAY 0-4
set ::env(PL_TARGET_DENSITY) 0.45        # Placement density
```

---

## 🐛 Xử lý lỗi nhanh

| Lỗi | Giải pháp nhanh |
|-----|-----------------|
| **Timing violation** | Tăng `CLOCK_PERIOD` từ 20.0 → 25.0 |
| **DRC violations** | Tăng `DIE_AREA` từ 400x400 → 500x500 |
| **Module not found** | Kiểm tra file .v trong `src/`, comment `include` |
| **Clock not found** | Kiểm tra `CLOCK_PORT` khớp với RTL |
| **Docker error** | `sudo systemctl start docker` |

---

## 📈 Metrics quan trọng cần kiểm tra

✅ **Setup Slack** > 0 (timing OK)  
✅ **Hold Slack** > 0 (timing OK)  
✅ **DRC Violations** = 0  
✅ **LVS** = "Circuits match uniquely"  
✅ **Chip Area** < DIE_AREA  
✅ **Core Utilization** ≈ FP_CORE_UTIL  

---

## 🎯 Workflow đề xuất cho lần đầu

1. **Chạy script tự động**
   ```bash
   ./run_openlane.sh auto
   ```

2. **Nếu thành công** → Xem kết quả, phân tích metrics

3. **Nếu có lỗi** → Đọc log, sửa config.tcl, chạy lại

4. **Tối ưu hóa** → Điều chỉnh tham số, so sánh runs

---

## 📁 Cấu trúc thư mục kết quả

```
runs/RUN_YYYY.MM.DD_HH.MM.SS/
├── logs/                    # Log files của từng bước
├── reports/                 # Reports (synthesis, timing, DRC, LVS)
│   ├── synthesis/
│   ├── signoff/
│   └── metrics.csv         # ⭐ Tất cả metrics ở đây
├── results/
│   ├── final/
│   │   ├── gds/           # ⭐ GDSII file
│   │   ├── def/
│   │   ├── lef/
│   │   └── verilog/       # Netlist cuối cùng
│   └── ...
└── tmp/                    # Temporary files
```

---

## 💡 Tips

- ✅ Luôn chạy **interactive mode** cho lần đầu để dễ debug
- ✅ **Backup config.tcl** trước khi thay đổi
- ✅ So sánh **metrics.csv** giữa các runs
- ✅ Đọc **logs/** nếu gặp lỗi
- ✅ Tham khảo design mẫu: `~/OpenLane/designs/spm/`

---

## 🆘 Cần trợ giúp?

1. Đọc file `HUONG_DAN_CHAY_OPENLANE.md` (hướng dẫn chi tiết)
2. Xem log files trong `runs/*/logs/`
3. Kiểm tra [OpenLane Docs](https://openlane.readthedocs.io/)
4. Tìm kiếm lỗi trên [GitHub Issues](https://github.com/The-OpenROAD-Project/OpenLane/issues)

---

**Chúc bạn thành công! 🚀**
