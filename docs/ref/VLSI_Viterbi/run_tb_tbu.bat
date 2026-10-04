@echo off
REM Script chạy testbench TBU trên Windows
REM Sử dụng Icarus Verilog

echo ========================================
echo Chạy testbench TBU
echo ========================================
echo.

REM Kiểm tra xem iverilog có sẵn không
where iverilog >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Icarus Verilog chua duoc cai dat!
    echo Vui long cai dat Icarus Verilog hoac su dung ModelSim/QuestaSim
    pause
    exit /b 1
)

echo Dang bien dich...
iverilog -o tb_tbu.exe pmu.v tbu.v tb_tbu.v

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Bien dich that bai!
    pause
    exit /b 1
)

echo.
echo Dang chay testbench...
echo.
vvp tb_tbu.exe

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Chay testbench that bai!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Hoan thanh!
echo ========================================
pause

