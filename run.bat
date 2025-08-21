@echo off
chcp 65001 >nul
title 抖音视频下载器
echo 正在启动抖音视频下载器...
echo.

REM 检查Python是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误：未检测到Python，请先安装Python 3.7+
    echo 下载地址：https://www.python.org/downloads/
    pause
    exit /b 1
)

REM 检查依赖是否安装
echo 检查依赖包...
pip show yt-dlp >nul 2>&1
if errorlevel 1 (
    echo 正在安装依赖包...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo 依赖安装失败，请检查网络连接
        pause
        exit /b 1
    )
)

REM 运行程序
echo 启动程序...
python douyin_downloader.py

echo.
echo 程序已结束，按任意键退出...
pause >nul
