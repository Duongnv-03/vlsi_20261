# 📊 KẾT QUẢ TỔNG HỢP OPENLANE - VITERBI DECODER

Dưới đây là báo cáo chi tiết kết quả chạy RTL-to-GDSII cho thiết kế **Viterbi Decoder** bằng công cụ OpenLane sử dụng PDK SKY130.

---

## 🚀 Thông tin chung
- **Dự án**: Viterbi Decoder (n=2, k=1, m=2)
- **Top Module**: `system_top`
- **PDK**: `sky130A`
- **Ngày thực hiện**: 2026-01-21
- **Run ID**: `RUN_2026.01.20_20.44.17`
- **Trạng thái**: ✅ **FLOW COMPLETED**

---

## 📈 Thông số kỹ thuật quan trọng

| Thông số | Kết quả | Trạng thái |
| :--- | :--- | :--- |
| **Tần số mục tiêu** | 50 MHz (Period: 20ns) | ✅ Đạt (Setup WNS: 0.0) |
| **Magic DRC** | 0 violations | ✅ Sạch |
| **LVS** | 0 errors | ✅ Khớp (Netlist vs Layout) |
| **Antenna Violations** | 0 violations | ✅ Sạch |
| **Setup Slack (WNS)** | 0.00 ns | ✅ Đạt |
| **Hold Slack (WNS)** | 0.00 ns | ✅ Đạt |

---

## Diện tích và Tài nguyên (Area & Resource)

- **Diện tích Die (Die Area)**: $400 \times 400 = 0.16 \text{ mm}^2$
- **Diện tích Core (Core Area)**: $146,959.7 \text{ um}^2$
- **Tỷ lệ sử dụng (Final Utilization)**: $21.46\%$
- **Số lượng Standard Cells (Synthesis)**: $2,032$
- **Tổng số Cell (bao gồm cả Physical cells)**: $17,961$
- **Tổng chiều dài dây (Wire Length)**: $65,249 \text{ um}$
- **Số lượng Via**: $17,418$

---

## ⚡ Công suất tiêu thụ (Power Analysis)

*Dựa trên các thông số thư viện Typical (nominal corner):*

- **Internal Power (Công suất nội tại)**: $3.74 \text{ mW}$
- **Switching Power (Công suất chuyển mạch)**: $2.49 \text{ mW}$
- **Leakage Power (Công suất rò rỉ)**: $0.559 \text{ uW}$
- **Tổng công suất**: $\approx 6.23 \text{ mW}$

---

## 📁 Danh sách Output chính

Các file kết quả được lưu tại:
`/home/iot/Study/VLSI/Open_Lane/Viterbi-Decoder-Implementation-and-Verification/OpenLane/designs/viterbi/runs/RUN_2026.01.20_20.44.17/`

- **Layout cuối cùng (GDSII)**: `results/final/gds/system_top.gds`
- **Netlist tổng hợp (Gate-level)**: `results/final/verilog/pnl/system_top.pnl.v`
- **Báo cáo chi tiết metrics**: `reports/metrics.csv`
- **Báo cáo Timing chi tiết**: `reports/signoff/system_top-sta-rcx_nom/summary.rpt`

---

## 🛠️ Ghi chú quá trình Synthesis & Routing
- **Synthesis Strategy**: `AREA 0` (Tối ưu hóa diện tích).
- **Diode Insertion**: Đã tích hợp (Strategy 4) để khắc phục lỗi Antenna.
- **Clock Tree Synthesis (CTS)**: Đã hoàn thành với zero timing violation.

---
*Báo cáo được tạo tự động bởi Antigravity Assistant.*
