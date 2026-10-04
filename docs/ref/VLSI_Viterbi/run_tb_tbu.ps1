# Script PowerShell chạy testbench TBU
# Sử dụng Icarus Verilog

# Fix encoding để hiển thị tiếng Việt đúng
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Refresh PATH để tìm iverilog nếu vừa cài đặt
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Chạy testbench TBU" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra xem iverilog có sẵn không
$iverilog = Get-Command iverilog -ErrorAction SilentlyContinue
if (-not $iverilog) {
    Write-Host "ERROR: Icarus Verilog chưa được cài đặt!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Cách cài đặt Icarus Verilog:" -ForegroundColor Yellow
    Write-Host "1. Tải từ: http://bleyer.org/icarus/" -ForegroundColor Yellow
    Write-Host "   Hoặc: https://github.com/steveicarus/iverilog/releases" -ForegroundColor Yellow
    Write-Host "2. Hoặc dùng Chocolatey: choco install iverilog" -ForegroundColor Yellow
    Write-Host "3. Hoặc dùng Scoop: scoop install iverilog" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Xem file HUONG_DAN_CAI_DAT.md để biết chi tiết." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Hoặc chạy online tại: https://www.edaplayground.com/" -ForegroundColor Cyan
    exit 1
}

Write-Host "Đang biên dịch..." -ForegroundColor Green
$compileResult = & iverilog -o tb_tbu.exe pmu.v tbu.v tb_tbu.v 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Biên dịch thất bại!" -ForegroundColor Red
    Write-Host $compileResult
    exit 1
}

Write-Host ""
Write-Host "Đang chạy testbench..." -ForegroundColor Green
Write-Host ""
& vvp tb_tbu.exe

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Chạy testbench thất bại!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Hoàn thành!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

