# Script refresh PATH để tìm iverilog
# Chạy script này trước khi dùng iverilog nếu gặp lỗi "command not found"

$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "Đã refresh PATH!" -ForegroundColor Green
Write-Host ""

# Kiểm tra iverilog
$iverilog = Get-Command iverilog -ErrorAction SilentlyContinue
if ($iverilog) {
    Write-Host "✓ Tìm thấy Icarus Verilog tại: $($iverilog.Source)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Bây giờ bạn có thể chạy:" -ForegroundColor Cyan
    Write-Host "  iverilog -v" -ForegroundColor Yellow
    Write-Host "  .\run_tb_tbu.ps1" -ForegroundColor Yellow
} else {
    Write-Host "✗ Không tìm thấy Icarus Verilog trong PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Thử tìm trong các vị trí thường gặp..." -ForegroundColor Yellow
    
    $commonPaths = @(
        "D:\iverilog\bin\iverilog.exe",
        "C:\iverilog\bin\iverilog.exe",
        "$env:ProgramFiles\Icarus Verilog\bin\iverilog.exe",
        "$env:LOCALAPPDATA\Programs\Icarus Verilog\bin\iverilog.exe"
    )
    
    $found = $false
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            Write-Host "✓ Tìm thấy tại: $path" -ForegroundColor Green
            Write-Host ""
            Write-Host "Thêm vào PATH tạm thời:" -ForegroundColor Cyan
            $dir = Split-Path $path
            $env:PATH = "$dir;$env:PATH"
            Write-Host "  \$env:PATH = `"$dir;`$env:PATH`"" -ForegroundColor Yellow
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        Write-Host "✗ Không tìm thấy Icarus Verilog" -ForegroundColor Red
        Write-Host ""
        Write-Host "Vui lòng:" -ForegroundColor Yellow
        Write-Host "1. Xem file HUONG_DAN_CAI_DAT.md để cài đặt" -ForegroundColor Yellow
        Write-Host "2. Hoặc restart PowerShell sau khi cài đặt" -ForegroundColor Yellow
    }
}

