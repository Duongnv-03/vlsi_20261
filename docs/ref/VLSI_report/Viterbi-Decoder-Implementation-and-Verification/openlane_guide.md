# Hướng Dẫn Sử Dụng OpenLane: Quy Trình RTL-to-GDSII

## 1. Tổng Quan
**OpenLane** là một luồng (flow) thiết kế tự động mã nguồn mở giúp chuyển đổi mã **RTL** (Verilog) thành **GDSII** (bản vẽ layout cuối cùng để sản xuất chip). Nó tích hợp và điều phối nhiều công cụ EDA (Electronic Design Automation) mạnh mẽ khác nhau để thực hiện toàn bộ quy trình thiết kế ASIC.

## 2. Các Thành Phần Cốt Lõi (Core Components)
OpenLane đóng vai trò là "người quản lý", kết nối các công cụ sau:

*   **Yosys**: Thực hiện **Synthesis** (Tổng hợp). Chuyển đổi code Verilog (RTL) thành danh sách các cổng logic (Netlist) dựa trên thư viện công nghệ (PDK).
*   **OpenROAD**: Công cụ chủ lực thực hiện các bước thiết kế vật lý (Physical Design):
    *   Floorplanning (Quy hoạch mặt bằng chip).
    *   Placement (Sắp xếp linh kiện).
    *   Clock Tree Synthesis (CTS - Tạo cây đồng hồ).
    *   Optimization (Tối ưu hóa timing/công suất).
    *   Routing (Đi dây).
*   **Magic**: Công cụ layout VLSI, dùng cho **Signoff** (kiểm tra cuối) và chỉnh sửa layout. Nó thực hiện DRC (kiểm tra luật thiết kế), Antenna check và xuất file GDSII.
*   **Netgen**: Thực hiện **LVS** (Layout vs. Schematic) - so sánh xem mạch layout sau khi đi dây có khớp với mạch nguyên lý (netlist) hay không.
*   **KLayout**: Trình xem và chỉnh sửa file GDSII, cũng có thể chạy DRC/LVS.
*   **CVC (Circuit Validity Checker)**: Kiểm tra tính hợp lệ của mạch (lỗi điện áp, nguồn).
*   **SPEF-Extractor**: Trích xuất các tham số ký sinh (điện trở, tụ điện của dây dẫn) để phân tích timing chính xác.

## 3. Quy Trình Thiết Kế Chi Tiết (The OpenLane Flow)
Khi chạy lệnh `./flow.tcl -design <tên_design>`, OpenLane sẽ thực hiện tuần tự các bước sau:

### Bước 1: Synthesis (Tổng hợp logic)
*   **RTL Synthesis**: `Yosys` biên dịch code Verilog sang cổng logic cơ bản.
*   **Technology Mapping**: Ánh xạ các cổng logic vào thư viện chuẩn (Standard Cells) của foundry (ví dụ SkyWater 130nm) bằng `ABC`.
*   **Kết quả**: File Netlist (danh sách các cell và kết nối).

### Bước 2: Floorplan (Quy hoạch mặt bằng)
*   **Init Floorplan**: Định nghĩa kích thước Core (khu vực chứa logic) và Die (toàn bộ chip), xác định vị trí các chân IO.
*   **IO Placer**: Sắp xếp tối ưu vị trí các chân Input/Output xung quanh chip.
*   **PDN Generation**: Tạo mạng lưới cấp nguồn (Power Distribution Network - VDD/VSS) dạng lưới (grid) để cấp điện cho toàn bộ chip.
*   **Tap/Decap Insertion**: Chèn các cell đặc biệt để ổn định điện áp và ngăn chặn hiện tượng Latch-up.

### Bước 3: Placement (Sắp xếp linh kiện)
*   **Global Placement**: Tìm vị trí tối ưu sơ bộ cho hàng ngàn cell logic (cho phép chồng lấn để tìm vị trí tốt nhất về độ dài dây).
*   **Resizer**: Tự động thay đổi kích thước cổng logic hoặc chèn buffer để sửa lỗi setup time/hold time.
*   **Detailed Placement**: Sắp xếp chính xác các cell vào các hàng (rows) hợp lệ, đảm bảo không có sự chồng lấn nào.

### Bước 4: Clock Tree Synthesis (CTS)
*   Tạo mạng phân phối xung Clock (Clock Tree) hình cây để đưa tín hiệu clock đến tất cả các Flip-Flop cùng một lúc (giảm thiểu Clock Skew và Latency).

### Bước 5: Routing (Đi dây)
*   **Global Routing**: Lên kế hoạch đi dây sơ bộ, chia chip thành các ô lưới và xác định hướng đi của dây.
*   **Detailed Routing**: `TritonRoute` (trong OpenROAD) thực hiện nối dây chi tiết từng lớp kim loại (Metal layers), đảm bảo tuân thủ các luật thiết kế (DRC).

### Bước 6: Signoff (Kiểm tra và Xác nhận)
*   **DRC (Design Rule Check)**: `Magic` kiểm tra xem layout có vi phạm luật (khoảng cách tối thiểu, độ rộng dây...) của nhà máy không.
*   **LVS (Layout vs Schematic)**: `Netgen` so sánh Netlist ban đầu và Layout cuối cùng để đảm bảo chức năng không bị sai lệch.
*   **Antenna Check**: Kiểm tra lỗi "hiệu ứng ăng-ten" (dây dẫn quá dài tích tụ điện tích khi chế tạo làm hỏng cổng gate).
*   **RC Extraction & STA**: Trích xuất ký sinh và phân tích timing tĩnh (Static Timing Analysis) lần cuối để đảm bảo chip chạy đúng tần số yêu cầu.

### Bước 7: GDSII Streaming
*   Xuất file `.gds` (GDSII) - Đây là sản phẩm cuối cùng dùng để gửi đi sản xuất (Tape-out).

## 4. Cấu Trúc Làm Việc
Khi làm việc với OpenLane cho dự án của bạn:

*   **`designs/`**: Thư mục chứa các dự án. Bạn sẽ tạo một thư mục cho Viterbi Decoder ở đây.
*   **`config.tcl`**: File quan trọng nhất. Đây là nơi bạn cấu hình toàn bộ thiết kế (tần số clock, mật độ cell, tên file Verilog, v.v.).
*   **`runs/`**: Mỗi lần chạy `flow.tcl`, một thư mục mới sẽ được tạo ra trong `runs/` (ví dụ: `runs/RUN_2024_01_24_...`).
    *   Chứa toàn bộ Log, Report (báo cáo diện tích, công suất, timing) và Result (file .def, .gds, .leff).

## 5. Tài Liệu Tham Khảo (References)
*   **GitHub Repository**: [https://github.com/The-OpenROAD-Project/OpenLane](https://github.com/The-OpenROAD-Project/OpenLane)
*   **Tài liệu hướng dẫn (ReadTheDocs)**: [https://openlane.readthedocs.io/](https://openlane.readthedocs.io/)
*   **SkyWater 130nm PDK**: [https://github.com/google/skywater-pdk](https://github.com/google/skywater-pdk)
