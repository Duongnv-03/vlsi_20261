#!/bin/bash
# Script chạy testbench TBU trên Linux/Mac
# Sử dụng Icarus Verilog

echo "========================================"
echo "Chạy testbench TBU"
echo "========================================"
echo ""

# Kiểm tra xem iverilog có sẵn không
if ! command -v iverilog &> /dev/null; then
    echo "ERROR: Icarus Verilog chưa được cài đặt!"
    echo "Vui lòng cài đặt Icarus Verilog hoặc sử dụng ModelSim/QuestaSim"
    exit 1
fi

echo "Đang biên dịch..."
iverilog -o tb_tbu pmu.v tbu.v tb_tbu.v

if [ $? -ne 0 ]; then
    echo "ERROR: Biên dịch thất bại!"
    exit 1
fi

echo ""
echo "Đang chạy testbench..."
echo ""
vvp tb_tbu

if [ $? -ne 0 ]; then
    echo "ERROR: Chạy testbench thất bại!"
    exit 1
fi

echo ""
echo "========================================"
echo "Hoàn thành!"
echo "========================================"

