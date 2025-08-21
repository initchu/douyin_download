@echo off
chcp 65001 >nul
title 抖音下载器 - 自动安装
echo ========================================
echo           抖音视频下载器安装程序
echo ========================================
echo.

REM 检查Python版本
echo [1/4] 检查Python环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：未检测到Python
    echo.
    echo 请先安装Python 3.7或更高版本：
    echo 下载地址：https://www.python.org/downloads/
    echo.
    echo 安装时请勾选"Add Python to PATH"选项
    echo.
    pause
    exit /b 1
)

python --version
echo ✅ Python环境检查通过
echo.

REM 升级pip
echo [2/4] 升级pip包管理器...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo ⚠️  pip升级失败，继续安装依赖...
) else (
    echo ✅ pip升级完成
)
echo.

REM 安装依赖
echo [3/4] 安装Python依赖包...
echo 正在安装，请稍候...
pip install -r requirements.txt
if errorlevel 1 (
    echo ❌ 依赖安装失败
    echo.
    echo 可能的原因：
    echo 1. 网络连接问题
    echo 2. Python版本不兼容
    echo 3. 权限不足
    echo.
    echo 请尝试以管理员身份运行此脚本
    echo.
    pause
    exit /b 1
)

echo ✅ 依赖安装完成
echo.

REM 创建下载目录
echo [4/4] 创建下载目录...
if not exist "downloads" (
    mkdir downloads
    echo ✅ 下载目录创建完成
) else (
    echo ✅ 下载目录已存在
)
echo.

echo ========================================
echo           安装完成！
echo ========================================
echo.
echo 现在您可以：
echo 1. 双击 run.bat 启动程序
echo 2. 或在命令行运行：python douyin_downloader.py
echo.
echo 下载的视频将保存在 downloads 文件夹中
echo.
pause
