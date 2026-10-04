@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

:: Tên file chính (không có phần mở rộng)
set "FILENAME=main (2)"

echo ------------------------------------------
echo Đang biên dịch báo cáo LaTeX: !FILENAME!.tex
echo Sử dụng: xelatex
echo ------------------------------------------

:: Chạy xelatex lần 1
xelatex -interaction=nonstopmode "!FILENAME!.tex"

if !ERRORLEVEL! EQU 0 (
    echo Lần 1 thành công. Đang chạy lần 2 để cập nhật mục lục...
    xelatex -interaction=nonstopmode "!FILENAME!.tex"
    
    if !ERRORLEVEL! EQU 0 (
        echo ------------------------------------------
        echo BIÊN DỊCH THÀNH CÔNG!
        echo File đầu ra: !FILENAME!.pdf
        echo ------------------------------------------
    ) else (
        echo Lỗi ở lần biên dịch thứ 2.
    )
) else (
    echo ------------------------------------------
    echo LỖI: Biên dịch thất bại. Kiểm tra file log để biết thêm chi tiết.
    echo ------------------------------------------
    exit /b 1
)

endlocal
