# Tên file chính (không có phần mở rộng)
$FILENAME = "main (2)"

Write-Output "------------------------------------------"
Write-Output "Đang biên dịch báo cáo LaTeX: $FILENAME.tex"
Write-Output "Sử dụng: xelatex"
Write-Output "------------------------------------------"

# Chạy xelatex lần 1
xelatex -interaction=nonstopmode "$FILENAME.tex"

if ($LASTEXITCODE -eq 0) {
    Write-Output "Lần 1 thành công. Đang chạy lần 2 để cập nhật mục lục..."
    xelatex -interaction=nonstopmode "$FILENAME.tex"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Output "------------------------------------------"
        Write-Output "BIÊN DỊCH THÀNH CÔNG!"
        Write-Output "File đầu ra: $FILENAME.pdf"
        Write-Output "------------------------------------------"
    } else {
        Write-Output "Lỗi ở lần biên dịch thứ 2."
    }
} else {
    Write-Output "------------------------------------------"
    Write-Output "LỖI: Biên dịch thất bại. Kiểm tra file log để biết thêm chi tiết."
    Write-Output "------------------------------------------"
    exit 1
}
