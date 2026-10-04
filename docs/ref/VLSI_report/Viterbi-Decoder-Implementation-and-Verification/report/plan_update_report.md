# Kế hoạch cập nhật Báo cáo Viterbi Decoder (RTL đến GDSII)

Tài liệu này vạch ra các bước cần thiết để chỉnh sửa file `main (2).tex` sao cho khớp hoàn toàn với mã nguồn Verilog thực tế và kết quả từ OpenLane.

## 1. Cập nhật Chương 2: Thiết kế chi tiết (Khớp với `design/*.v`)

### 1.1. Cấu trúc hệ thống Top-Level (`system_top.v`)

* **Mô tả mới**: Hệ thống không chỉ có bộ giải mã mà là một SoC con hoàn chỉnh với:
  * **Sync FIFO**: Đệm dữ liệu đầu vào (16x16 bit), giải quyết vấn đề bất đối xứng tốc độ.
  * **PISO (Parallel-In Serial-Out)**: Chuyển đổi gói tin 16-bit thành dòng bit (cặp 2 bit) để đưa vào Core.
  * **SIPO (Serial-In Parallel-Out)**: Đóng gói dòng bit đã giải mã thành kết quả 8-bit (Byte).
* **Hình vẽ**: Cần sơ đồ khối thể hiện luồng: `Data In -> FIFO -> PISO -> Core -> SIPO -> Data Out`.

### 1.2. Kiến trúc Viterbi Core (`viterbi_core.v`)

* **BMU (Branch Metric Unit)**: Tính toán khoảng cách Hamming của 8 nhánh dựa trên đầu vào 2-bit.
* **ACSU (Add-Compare-Select Unit)**: Tính toán Path Metric mới cho 4 trạng thái (S0-S3) và xuất ra 4 bit quyết định (`dec_bits`).
* **PMU (Path Metric Unit)**: Chỉ đóng vai trò thanh ghi lưu trữ giá trị Path Metric hiện tại.
* **TBU (Traceback/Survivor Unit)**: **QUAN TRỌNG** - Thay đổi hoàn toàn từ "Traceback" sang **"Register Exchange"**.
  * Giải thích cơ chế dịch lịch sử bit trực tiếp trong các thanh ghi `history_s0` đến `history_s3`.
  * Độ dài thanh ghi (Constraint length): TBL = 15.
  * Lợi ích: Xuất dữ liệu ngay lập tức sau mỗi chu kỳ, không cần chu kỳ truy vết ngược.

## 2. Cập nhật Chương 3: Kết quả triển khai (Khớp với OpenLane `metrics.csv`)

Sử dụng số liệu thực tế từ lần chạy `RUN_2026.01.21_02.17.41`:

* **Công cụ**: OpenLane Flow, Sky130 PDK.
* **Diện tích (Area)**: 0.16 mm² (Die area).
* **Số lượng Cell**: ~2032 cells.
* **Mật độ (Core Utilization)**: 40%.
* **Thời gian/Tần số**: Tần số hoạt động 50 MHz (Clock period 20ns).
* **Công suất (Power)**: Tổng công suất ước tính khoảng 0.007 mW.
* **Vi phạm (Violations)**: 0 vi phạm (Setup, Hold, DRC, LVS).

## 3. Các chỉnh sửa nhỏ khác

* **Font chữ**: Giữ nguyên `Liberation Serif` để tương thích hệ thống.
* **Bảng biểu**: Cập nhật bảng tín hiệu vào/ra của `system_top` (thêm `busy_o`, `dvalid_i`).
* **Tóm tắt**: Nhấn mạnh việc sử dụng thành công quy trình Open Source (OpenLane) thay vì chỉ dùng Cadence như lý thuyết cũ.

## 5. Mục lục dự kiến MỚI (Cập nhật theo feedback Leader)

Cấu trúc báo cáo sẽ được mở rộng thành 4 chương chính để tách biệt rõ ràng giữa Thiết kế, Kiểm tra chức năng và Triển khai vật lý:

* **TÓM TẮT NỘI DUNG**
* **CHƯƠNG 1: TỔNG QUAN VỀ MÃ TÍCH CHẬP VÀ GIẢI MÃ VITERBI**
  * 1.1. Giới thiệu mã tích chập (n, k, m) và đa thức sinh.
  * 1.2. Thuật toán Viterbi và nguyên lý tìm đường Maximum Likelihood.
* **CHƯƠNG 2: ĐẶC TẢ KỸ THUẬT VÀ THIẾT KẾ RTL (Specifications & RTL Design)**
  * 2.1. Đặc tả kỹ thuật (Specifications):
    * Các tham số thiết kế (K=3, Rate=1/2, Polynomials).
    * Bảng đặc tả tín hiệu vào/ra (Interface Specification).
  * 2.2. Kiến trúc hệ thống (System Architecture):
    * Sơ đồ khối Top-level (System Top).
    * Luồng dữ liệu (Dataflow): FIFO -> PISO -> Core -> SIPO.
  * 2.3. Triển khai RTL (RTL Implementation):
    * Mô tả chi tiết và trích dẫn mã RTL quan trọng cho từng khối:
      * BMU (Branch Metric Unit).
      * ACSU (Add-Compare-Select Unit).
      * TBU (Traceback Unit) - Nhấn mạnh giải thuật Register Exchange.
* **CHƯƠNG 3: KIỂM TRA CHỨC NĂNG MẠCH (Functional Verification)**
  * 3.1. Môi trường kiểm chứng (Testbench Environment):
    * Cấu trúc Testbench (`tb_system_top`).
    * Kịch bản kiểm tra (Test Cases): Random inputs, so sánh kết quả tự động.
  * 3.2. Kết quả mô phỏng (Simulation Results):
    * Dạng sóng tín hiệu (Waveforms).
    * Log kiểm tra dữ liệu.
* **cal Design)**
  * 4.1. Quy trình OpenLane Flow (RTL-to-GDSII).
  * 4.2. Kết quả tổng hợp (Synthesis Results):
    * Báo cáo diện tích (Area) và tài nguyên sử dụng.
    * Báo cáo công suất (Power Analysis).
    * Phân tích thời gian (Timing Analysis).
  * 4.3. Kết quả thiết kế vật lý (Physical Layout):
    * Floorplan và Power Distribution Network (PDN).
    * Placement và Routing.
    * Hình ảnh Layout GDSII cuối cùng.
* **KẾT LUẬN**
* **TÀI LIỆU THAM KHẢO**

% ====================================================================
% CHƯƠNG 3
% ====================================================================
\chapter{KIỂM TRA CHỨC NĂNG MẠCH}

\section{Chiến lược và Môi trường kiểm chứng}
Quy trình kiểm tra được thực hiện theo chiến lược **Bottom-Up**: bắt đầu từ việc xác minh chức năng của từng khối con (Unit Level) để đảm bảo tính đúng đắn ở mức thấp nhất, sau đó mới tiến hành tích hợp và kiểm tra toàn bộ hệ thống (System Level).

Môi trường kiểm tra (Testbench) được xây dựng với các thành phần chính:
\begin{itemize}
    \item \textbf{Generator}: Tạo các mẫu dữ liệu ngẫu nhiên và các trường hợp biên (Corner cases).
    \item \textbf{Driver}: Lái tín hiệu vào DUT (Device Under Test) theo đúng giao thức bắt tay (Valid/Ready).
    \item \textbf{Monitor}: Thu thập dữ liệu ngõ ra để phân tích.
    \item \textbf{Scoreboard}: So sánh kết quả thực tế với mô hình tham chiếu (Golden Model) để đưa ra kết luận PASS/FAIL.
\end{itemize}

\section{Kết quả mô phỏng cấp độ khối (Unit Level Verification)}
Dưới đây là chi tiết kết quả mô phỏng cho từng module. Do dữ liệu log kiểm tra dài, một số hình ảnh được chia nhỏ để đảm bảo tính trực quan.

% --------------------------------------------------------------------
% 3.2.1 FIFO
% --------------------------------------------------------------------
\subsection{Khối đệm dữ liệu (FIFO)}
Khối FIFO được kiểm tra qua 5 vòng lặp (Rounds) với việc ghi đầy và đọc cạn để kiểm tra các cờ trạng thái \texttt{Full} và \texttt{Empty}.

\begin{figure}[H]
    \centering
    % Log dài quá thì cắt làm 2 phần
    \includegraphics[width=0.95\textwidth]{fifo_log_part1.png}
    \vspace{0.2cm} % Tạo khoảng cách nhỏ
    \includegraphics[width=0.95\textwidth]{fifo_log_part2.png}
    \caption{Log kiểm tra dữ liệu và trạng thái FIFO (Phần 1 & 2)}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{fifo_wave.png}
    \caption{Giản đồ xung tín hiệu giao tiếp FIFO}
\end{figure}

% --------------------------------------------------------------------
% 3.2.2 PISO
% --------------------------------------------------------------------
\subsection{Khối chuyển đổi PISO}
Kết quả cho thấy PISO tách chính xác từ mã 16-bit thành các cặp Symbol 2-bit liên tiếp.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.95\textwidth]{piso_log_part1.png}
    \vspace{0.2cm}
    \includegraphics[width=0.95\textwidth]{piso_log_part2.png}
    \caption{Log kiểm tra logic dịch bit của PISO}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{piso_wave.png}
    \caption{Dạng sóng minh họa quá trình song song sang nối tiếp}
\end{figure}

% --------------------------------------------------------------------
% 3.2.3 BMU
% --------------------------------------------------------------------
\subsection{Khối tính toán nhánh (BMU)}
BMU được kiểm tra với các trường hợp: Đảo bit (Inverse Case), Lỗi 1 bit và Dữ liệu ngẫu nhiên (Random Stress).

\begin{figure}[H]
    \centering
    \includegraphics[width=0.95\textwidth]{bmu_log_part1.png}
    \vspace{0.2cm}
    \includegraphics[width=0.95\textwidth]{bmu_log_part2.png}
    \caption{Kết quả tính toán khoảng cách Hamming của BMU}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{bmu_wave.png}
    \caption{Dạng sóng ngõ ra của BMU ứng với các cặp bit vào}
\end{figure}

% --------------------------------------------------------------------
% 3.2.4 ACSU
% --------------------------------------------------------------------
\subsection{Khối Cộng - So sánh - Chọn (ACSU)}
ACSU hoạt động đúng trong các trường hợp biên (Boundary Case) và khi reset về 0 (Zero Case), đảm bảo đường dẫn tốt nhất luôn được chọn.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.95\textwidth]{acsu_log_part1.png}
    \vspace{0.2cm}
    \includegraphics[width=0.95\textwidth]{acsu_log_part2.png}
    \caption{Log kiểm tra quá trình cập nhật Path Metric}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{acsu_wave.png}
    \caption{Giản đồ xung hoạt động của ACSU}
\end{figure}

% --------------------------------------------------------------------
% 3.2.5 PMU
% --------------------------------------------------------------------
\subsection{Khối quản lý Metric (PMU)}
PMU thực hiện chuẩn hóa Metric chính xác, ngăn chặn hiện tượng tràn số học trong quá trình cộng dồn.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.95\textwidth]{pmu_log_part1.png}
    \vspace{0.2cm}
    \includegraphics[width=0.95\textwidth]{pmu_log_part2.png}
    \caption{Log kiểm tra các trạng thái chuẩn hóa của PMU}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{pmu_wave.png}
    \caption{Dạng sóng các tín hiệu điều khiển trong PMU}
\end{figure}

% --------------------------------------------------------------------
% 3.2.6 TBU
% --------------------------------------------------------------------
\subsection{Khối truy vết (TBU)}
TBU sử dụng kỹ thuật Register Exchange, được kiểm tra kỹ về khả năng điền đầy Pipeline (Filling Pipeline) và khả năng chuyển đổi người chiến thắng (Winner Switching).

\begin{figure}[H]
    \centering
    \includegraphics[width=0.95\textwidth]{tbu_log_part1.png}
    \vspace{0.2cm}
    \includegraphics[width=0.95\textwidth]{tbu_log_part2.png}
    \caption{Kết quả kiểm tra chức năng Traceback}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{tbu_wave.png}
    \caption{Dạng sóng ngõ ra bit giải mã (Decoded Bit) của TBU}
\end{figure}

% --------------------------------------------------------------------
% 3.2.7 SIPO
% --------------------------------------------------------------------
\subsection{Khối chuyển đổi SIPO}
SIPO gom thành công 8-bit dữ liệu từ dòng bit nối tiếp và phát tín hiệu \texttt{Byte Ready} đúng thời điểm.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.95\textwidth]{sipo_log_part1.png}
    \vspace{0.2cm}
    \includegraphics[width=0.95\textwidth]{sipo_log_part2.png}
    \caption{Log kiểm tra các kịch bản nhận byte (0xA5, 0xFF, 0x00)}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{sipo_wave.png}
    \caption{Dạng sóng tín hiệu đầu ra của SIPO}
\end{figure}

% --------------------------------------------------------------------
% 3.3 SYSTEM LEVEL
% --------------------------------------------------------------------
\section{Kết quả mô phỏng toàn hệ thống (System Level Verification)}
Sau khi xác minh từng khối thành phần, hệ thống được tích hợp tại \texttt{system\_top} và chạy với 1025 gói dữ liệu ngẫu nhiên.

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{system_waveform.png}
    \caption{Dạng sóng tổng thể của System Top}
\end{figure}

Phân tích dạng sóng cho thấy:
\begin{enumerate}
    \item \textbf{Input:} Khi \texttt{dvalid\_i} tích cực, dữ liệu 16-bit được nạp vào hệ thống.
    \item \textbf{Processing:} Hệ thống trải qua độ trễ (Latency) cố định do đường ống Pipeline và các bộ đệm.
    \item \textbf{Output:} Tín hiệu \texttt{valid\_o} tích cực báo hiệu dữ liệu ra hợp lệ. Dữ liệu \texttt{data\_o} khớp hoàn toàn với dữ liệu gốc ban đầu.
\end{enumerate}

File log tổng hợp ghi nhận trạng thái \textbf{"TEST PASSED"} cho toàn bộ các vector thử nghiệm, khẳng định hệ thống hoạt động chính xác và ổn định.
