#!/bin/bash

# Tên file chính (không có phần mở rộng)
FILENAME="main (2)"

echo "------------------------------------------"
echo "Đang biên dịch báo cáo LaTeX: $FILENAME.tex"
echo "Sử dụng: xelatex"
echo "------------------------------------------"

# Chạy xelatex lần 1
xelatex -interaction=nonstopmode "$FILENAME.tex"

# Chạy xelatex lần 2 (để cập nhật Mục lục và các tham chiếu chéo)
if [ $? -eq 0 ]; then
    echo "Lần 1 thành công. Đang chạy lần 2 để cập nhật mục lục..."
    xelatex -interaction=nonstopmode "$FILENAME.tex"
    
    if [ $? -eq 0 ]; then
        echo "------------------------------------------"
        echo "BIÊN DỊCH THÀNH CÔNG!"
        echo "File đầu ra: $FILENAME.pdf"
        echo "------------------------------------------"
    else
        echo "Lỗi ở lần biên dịch thứ 2."
    fi
else
    echo "------------------------------------------"
    echo "LỖI: Biên dịch thất bại. Kiểm tra file log để biết thêm chi tiết."
    echo "------------------------------------------"
    exit 1
fi

# Tùy chọn: Xóa các file rác sau khi biên dịch
# rm -f *.aux *.log *.toc *.out *.lof *.lot
