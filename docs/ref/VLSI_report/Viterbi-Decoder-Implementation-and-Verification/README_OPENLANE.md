# 📚 TÀI LIỆU HƯỚNG DẪN CHẠY OPENLANE

## 🎯 Mục đích

Bộ tài liệu này hướng dẫn chi tiết cách chạy OpenLane flow cho dự án **Viterbi Decoder**, từ RTL đến GDSII sử dụng PDK SKY130.

---

## 📖 Danh sách tài liệu

### 1. **QUICK_START.md** ⚡
**Dành cho**: Người muốn bắt đầu nhanh  
**Nội dung**: Các lệnh ngắn gọn, quick reference  
**Thời gian đọc**: 5 phút

👉 **Đọc file này trước tiên nếu bạn đã có kinh nghiệm với OpenLane**

```bash
cat QUICK_START.md
```

---

### 2. **HUONG_DAN_CHAY_OPENLANE.md** 📘
**Dành cho**: Người mới bắt đầu  
**Nội dung**: Hướng dẫn chi tiết từng bước, giải thích đầy đủ  
**Thời gian đọc**: 20-30 phút

**Bao gồm**:
- ✅ Yêu cầu hệ thống
- ✅ Chuẩn bị môi trường (Docker, OpenLane, PDK)
- ✅ Các bước chạy OpenLane (Automatic & Interactive)
- ✅ Cách kiểm tra kết quả (Synthesis, Timing, DRC, LVS)
- ✅ Xử lý lỗi thường gặp
- ✅ Tối ưu hóa thiết kế

👉 **Đọc file này nếu bạn chưa từng chạy OpenLane**

```bash
cat HUONG_DAN_CHAY_OPENLANE.md
```

---

### 3. **run_openlane.sh** 🤖
**Dành cho**: Tất cả mọi người  
**Nội dung**: Script tự động hóa toàn bộ quy trình  
**Thời gian sử dụng**: 1 phút setup, 30-60 phút chạy

**Tính năng**:
- ✅ Kiểm tra môi trường tự động
- ✅ Chuẩn bị design tự động
- ✅ Chạy OpenLane (Automatic hoặc Interactive)
- ✅ Hiển thị kết quả tự động
- ✅ Giao diện menu thân thiện

👉 **Sử dụng script này để tiết kiệm thời gian**

```bash
# Chạy menu tương tác
./run_openlane.sh

# Hoặc chạy tự động toàn bộ
./run_openlane.sh auto
```

---

### 4. **CHECKLIST.md** ✅
**Dành cho**: Người muốn theo dõi tiến độ  
**Nội dung**: Checklist chi tiết từng bước  
**Thời gian sử dụng**: Sử dụng xuyên suốt quá trình

**Bao gồm**:
- ✅ Checklist chuẩn bị môi trường
- ✅ Checklist chuẩn bị design
- ✅ Checklist chạy flow
- ✅ Checklist kiểm tra kết quả
- ✅ Checklist tối ưu hóa
- ✅ Form ghi chú kết quả

👉 **In file này ra và đánh dấu từng mục khi hoàn thành**

```bash
cat CHECKLIST.md
```

---

### 5. **GUIDE.md** 📋
**Dành cho**: Tham khảo tổng quan  
**Nội dung**: Tài liệu gốc về verification và cấu trúc dự án  
**Thời gian đọc**: 15-20 phút

**Bao gồm**:
- ✅ Thông tin dự án (Viterbi Decoder specs)
- ✅ Chiến lược Verification (44+ test cases)
- ✅ Cấu trúc module RTL
- ✅ Các bước đã thực hiện
- ✅ Lỗi thường gặp

```bash
cat GUIDE.md
```

---

## 🚀 Quy trình đề xuất

### Cho người mới bắt đầu:

```
1. Đọc QUICK_START.md (5 phút)
   ↓
2. Đọc HUONG_DAN_CHAY_OPENLANE.md (30 phút)
   ↓
3. In CHECKLIST.md ra giấy
   ↓
4. Chạy ./run_openlane.sh
   ↓
5. Đánh dấu checklist khi hoàn thành từng bước
```

### Cho người có kinh nghiệm:

```
1. Đọc QUICK_START.md (5 phút)
   ↓
2. Chạy ./run_openlane.sh auto
   ↓
3. Kiểm tra kết quả
```

---

## 📂 Cấu trúc thư mục dự án

```
Viterbi-Decoder-Implementation-and-Verification/
│
├── 📄 README.md                          # File này
├── 📄 QUICK_START.md                     # Quick reference
├── 📄 HUONG_DAN_CHAY_OPENLANE.md        # Hướng dẫn chi tiết
├── 📄 CHECKLIST.md                       # Checklist theo dõi
├── 📄 GUIDE.md                           # Tài liệu gốc
├── 🔧 run_openlane.sh                    # Script tự động
│
├── 📁 design/                            # RTL gốc (9 file .v)
│   ├── system_top.v
│   ├── viterbi_core.v
│   ├── sync_fifo.v
│   ├── piso.v, sipo.v
│   └── bmu.v, acsu.v, pmu.v, tbu.v
│
├── 📁 testbench/                         # Testbench cho simulation
│   └── ...
│
├── 📁 OpenLane/                          # Cấu hình OpenLane
│   └── designs/
│       └── viterbi/
│           ├── config.tcl               # ⭐ Cấu hình chính
│           ├── constraints.sdc          # ⭐ Timing constraints
│           └── src/                     # ⭐ RTL files (copy từ design/)
│               ├── system_top.v
│               └── ...
│
└── 📁 report/                            # Báo cáo, tài liệu
    └── ...
```

---

## 🎯 Mục tiêu dự án

| Thông số | Mục tiêu |
|----------|----------|
| **Top Module** | `system_top` |
| **PDK** | SKY130A |
| **Clock Frequency** | 50 MHz (20ns period) |
| **Die Area** | 400μm x 400μm |
| **Core Utilization** | 40% |
| **Timing** | Setup/Hold slack > 0 |
| **DRC** | 0 violations |
| **LVS** | Circuits match |

---

## 🛠️ Công cụ cần thiết

| Công cụ | Phiên bản | Mục đích |
|---------|-----------|----------|
| **Docker** | 20.10+ | Container runtime |
| **OpenLane** | v2 (latest) | RTL-to-GDSII flow |
| **PDK** | SKY130A | Process Design Kit |
| **KLayout** | Latest | Layout viewer (optional) |

---

## 📊 Quy trình OpenLane Flow

```
RTL Files (.v)
    ↓
┌─────────────────┐
│   SYNTHESIS     │  → Netlist (.v)
└─────────────────┘
    ↓
┌─────────────────┐
│   FLOORPLAN     │  → Die area, core area
└─────────────────┘
    ↓
┌─────────────────┐
│   PLACEMENT     │  → Cell positions
└─────────────────┘
    ↓
┌─────────────────┐
│      CTS        │  → Clock tree
└─────────────────┘
    ↓
┌─────────────────┐
│    ROUTING      │  → Wire connections
└─────────────────┘
    ↓
┌─────────────────┐
│   MAGIC DRC     │  → Design Rule Check
└─────────────────┘
    ↓
┌─────────────────┐
│      LVS        │  → Layout vs Schematic
└─────────────────┘
    ↓
GDSII File (.gds)
```

---

## ⏱️ Thời gian ước tính

| Bước | Thời gian |
|------|-----------|
| **Cài đặt môi trường** | 30-60 phút (chỉ 1 lần) |
| **Chuẩn bị design** | 5-10 phút |
| **Chạy OpenLane flow** | 30-60 phút |
| **Kiểm tra kết quả** | 10-15 phút |
| **Tối ưu hóa (nếu cần)** | 1-2 giờ |

**Tổng thời gian**: 2-4 giờ (cho lần đầu tiên)

---

## 🆘 Hỗ trợ & Tài liệu tham khảo

### Tài liệu chính thức:
- [OpenLane Documentation](https://openlane.readthedocs.io/)
- [OpenLane GitHub](https://github.com/The-OpenROAD-Project/OpenLane)
- [SKY130 PDK](https://skywater-pdk.readthedocs.io/)
- [OpenROAD](https://openroad.readthedocs.io/)

### Tài liệu trong dự án:
- `QUICK_START.md` - Quick reference
- `HUONG_DAN_CHAY_OPENLANE.md` - Hướng dẫn chi tiết
- `CHECKLIST.md` - Checklist theo dõi
- `GUIDE.md` - Tài liệu gốc

### Khi gặp lỗi:
1. Kiểm tra `HUONG_DAN_CHAY_OPENLANE.md` → Mục "Xử lý lỗi thường gặp"
2. Xem log files trong `~/OpenLane/designs/viterbi/runs/*/logs/`
3. Tìm kiếm trên [GitHub Issues](https://github.com/The-OpenROAD-Project/OpenLane/issues)
4. Hỏi trên [OpenLane Discussions](https://github.com/The-OpenROAD-Project/OpenLane/discussions)

---

## 🎓 Kiến thức cần có

### Cơ bản (bắt buộc):
- ✅ Hiểu biết về Verilog/RTL
- ✅ Biết sử dụng Linux command line
- ✅ Hiểu khái niệm ASIC design flow

### Nâng cao (khuyến nghị):
- ⭐ Timing analysis (Setup/Hold)
- ⭐ Physical design concepts
- ⭐ Design Rule Check (DRC)
- ⭐ Layout vs Schematic (LVS)

---

## 📝 Ghi chú quan trọng

### ⚠️ Lưu ý:
1. **Luôn backup** `config.tcl` trước khi thay đổi
2. **Đọc log files** nếu gặp lỗi
3. **So sánh metrics** giữa các runs
4. **Không xóa** thư mục `runs/` nếu chưa backup

### 💡 Tips:
1. Chạy **interactive mode** cho lần đầu tiên
2. Sử dụng **script tự động** sau khi đã quen
3. **In checklist** ra giấy để theo dõi
4. **Ghi chú** các vấn đề gặp phải

---

## 🎉 Kết quả mong đợi

Sau khi hoàn thành, bạn sẽ có:

✅ **GDSII file** (`system_top.gds`) - Layout cuối cùng  
✅ **Netlist** - Mạch đã được tổng hợp  
✅ **Reports** - Synthesis, Timing, DRC, LVS  
✅ **Metrics** - Diện tích, công suất, tần số  
✅ **Layout screenshot** - Hình ảnh layout  

---

## 📞 Liên hệ & Đóng góp

Nếu bạn gặp vấn đề hoặc có đề xuất cải thiện tài liệu, vui lòng:
- Tạo issue trên GitHub repository
- Hoặc liên hệ trực tiếp với người duy trì dự án

---

## 📜 Lịch sử phiên bản

| Phiên bản | Ngày | Thay đổi |
|-----------|------|----------|
| 1.0 | 2026-01-21 | Tạo tài liệu ban đầu |

---

**Chúc bạn thành công với dự án Viterbi Decoder! 🚀**

---

## 🔗 Quick Links

- [QUICK_START.md](./QUICK_START.md) - Bắt đầu nhanh
- [HUONG_DAN_CHAY_OPENLANE.md](./HUONG_DAN_CHAY_OPENLANE.md) - Hướng dẫn chi tiết
- [CHECKLIST.md](./CHECKLIST.md) - Checklist theo dõi
- [GUIDE.md](./GUIDE.md) - Tài liệu gốc
- [run_openlane.sh](./run_openlane.sh) - Script tự động
