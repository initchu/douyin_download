#!/bin/bash

# 抖音视频下载器 - Linux启动脚本
# 支持Ubuntu, CentOS, Debian等主流Linux发行版

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_message $YELLOW "警告：检测到root权限，建议使用普通用户运行"
        read -p "是否继续？(y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 检查Python版本
check_python() {
    print_message $BLUE "检查Python环境..."
    
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        print_message $GREEN "✅ 检测到Python3: $PYTHON_VERSION"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
        PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
        print_message $GREEN "✅ 检测到Python: $PYTHON_VERSION"
    else
        print_message $RED "❌ 未检测到Python"
        echo
        print_message $YELLOW "请安装Python 3.7或更高版本："
        echo
        print_message $CYAN "Ubuntu/Debian:"
        echo "  sudo apt update"
        echo "  sudo apt install python3 python3-pip"
        echo
        print_message $CYAN "CentOS/RHEL:"
        echo "  sudo yum install python3 python3-pip"
        echo "  或"
        echo "  sudo dnf install python3 python3-pip"
        echo
        print_message $CYAN "Arch Linux:"
        echo "  sudo pacman -S python python-pip"
        echo
        exit 1
    fi
    
    # 检查Python版本是否满足要求
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    
    if [[ $PYTHON_MAJOR -lt 3 ]] || [[ $PYTHON_MAJOR -eq 3 && $PYTHON_MINOR -lt 7 ]]; then
        print_message $RED "❌ Python版本过低，需要Python 3.7+"
        print_message $YELLOW "当前版本: $PYTHON_VERSION"
        exit 1
    fi
}

# 检查pip
check_pip() {
    print_message $BLUE "检查pip包管理器..."
    
    if command -v pip3 &> /dev/null; then
        PIP_CMD="pip3"
        print_message $GREEN "✅ 检测到pip3"
    elif command -v pip &> /dev/null; then
        PIP_CMD="pip"
        print_message $GREEN "✅ 检测到pip"
    else
        print_message $RED "❌ 未检测到pip"
        print_message $YELLOW "请安装pip："
        echo
        print_message $CYAN "Ubuntu/Debian:"
        echo "  sudo apt install python3-pip"
        echo
        print_message $CYAN "CentOS/RHEL:"
        echo "  sudo yum install python3-pip"
        echo
        exit 1
    fi
}

# 升级pip
upgrade_pip() {
    print_message $BLUE "升级pip包管理器..."
    
    if $PIP_CMD install --upgrade pip --user &> /dev/null; then
        print_message $GREEN "✅ pip升级完成"
    else
        print_message $YELLOW "⚠️  pip升级失败，继续安装依赖..."
    fi
}

# 检查并安装依赖
check_dependencies() {
    print_message $BLUE "检查Python依赖包..."
    
    # 检查是否已安装yt-dlp
    if $PIP_CMD show yt-dlp &> /dev/null; then
        print_message $GREEN "✅ 依赖包已安装"
        return 0
    fi
    
    print_message $YELLOW "正在安装依赖包..."
    print_message $CYAN "这可能需要几分钟时间，请耐心等待..."
    
    # 安装依赖
    if $PIP_CMD install -r requirements.txt --user; then
        print_message $GREEN "✅ 依赖安装完成"
    else
        print_message $RED "❌ 依赖安装失败"
        echo
        print_message $YELLOW "可能的原因："
        echo "1. 网络连接问题"
        echo "2. Python版本不兼容"
        echo "3. 权限不足"
        echo
        print_message $CYAN "尝试使用系统包管理器安装："
        echo
        print_message $CYAN "Ubuntu/Debian:"
        echo "  sudo apt install python3-requests python3-colorama"
        echo "  pip3 install yt-dlp --user"
        echo
        print_message $CYAN "CentOS/RHEL:"
        echo "  sudo yum install python3-requests python3-colorama"
        echo "  pip3 install yt-dlp --user"
        echo
        exit 1
    fi
}

# 创建下载目录
create_download_dir() {
    print_message $BLUE "创建下载目录..."
    
    if [[ ! -d "downloads" ]]; then
        mkdir -p downloads
        print_message $GREEN "✅ 下载目录创建完成"
    else
        print_message $GREEN "✅ 下载目录已存在"
    fi
}

# 设置权限
set_permissions() {
    print_message $BLUE "设置文件权限..."
    
    # 设置脚本执行权限
    chmod +x douyin_downloader.py
    
    # 设置下载目录权限
    chmod 755 downloads
    
    print_message $GREEN "✅ 权限设置完成"
}

# 显示系统信息
show_system_info() {
    print_message $CYAN "系统信息："
    echo "操作系统: $(uname -s) $(uname -r)"
    echo "架构: $(uname -m)"
    echo "Python: $PYTHON_VERSION"
    echo "pip: $PIP_CMD"
    echo "工作目录: $(pwd)"
    echo
}

# 主函数
main() {
    clear
    
    print_message $CYAN "╔══════════════════════════════════════════════════════════════╗"
    print_message $CYAN "║                    抖音视频下载器 - Linux版                ║"
    print_message $CYAN "║                    支持单视频和合集下载                    ║"
    print_message $CYAN "╚══════════════════════════════════════════════════════════════╝"
    echo
    
    # 检查系统环境
    check_root
    check_python
    check_pip
    upgrade_pip
    check_dependencies
    create_download_dir
    set_permissions
    
    echo
    print_message $GREEN "========================================"
    print_message $GREEN "           环境检查完成！"
    print_message $GREEN "========================================"
    echo
    
    show_system_info
    
    # 询问是否启动程序
    read -p "是否现在启动下载器？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message $BLUE "启动抖音视频下载器..."
        echo
        $PYTHON_CMD douyin_downloader.py
    else
        print_message $YELLOW "您可以稍后运行以下命令启动程序："
        echo
        print_message $CYAN "  $PYTHON_CMD douyin_downloader.py"
        echo
        print_message $CYAN "或者直接运行此脚本："
        echo
        print_message $CYAN "  ./run.sh"
        echo
    fi
}

# 错误处理
trap 'echo -e "\n${RED}程序被中断${NC}"; exit 1' INT TERM

# 运行主函数
main "$@"
